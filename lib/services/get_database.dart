
import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/app_model/top_banner_model.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/Services/auth_services.dart';

const String dbName = "SBO";

class GetDatabase extends ChangeNotifier {
  final DatabaseReference _refDb = FirebaseDatabase.instance.ref(dbName);

  // Helper method to check if user is authenticated (not guest)
  bool get isUserAuthenticated =>
      AuthServices().fireAuth.currentUser != null &&
          !AuthServices().fireAuth.currentUser!.isAnonymous;

  // Helper method to check if user is guest
  bool get isGuestUser =>
      AuthServices().fireAuth.currentUser?.isAnonymous == true ||
          AuthServices().fireAuth.currentUser == null;

  //get my profile - Modified for guest users
  Stream<UserModel?> getMyUser() async* {
    if (!isUserAuthenticated) {
      log("Guest user - cannot get profile");
      yield null;
      return;
    }

    try {
      Query query = _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
      DatabaseEvent databaseEvent = await query.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Object? users = dataSnapshot.value;
        if (users != null && users is Map<dynamic, dynamic>) {
          Map<String, dynamic> usersMap =
          users.map((key, value) => MapEntry(key.toString(), value));
          notifyListeners();
          yield UserModel.fromJson(usersMap);
        }
      } else {
        log("No user data found");
        yield null;
      }
    } catch (e) {
      log("Error getting user profile: $e");
      yield null;
    }
  }

  Stream<UserModel?> userProfile({required String uid}) async* {
    try {
      Query query = _refDb.child("Users/$uid");
      DatabaseEvent databaseEvent = await query.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Object? user = dataSnapshot.value;
        if (user != null && user is Map<dynamic, dynamic>) {
          Map<String, dynamic> userMap =
          user.map((key, value) => MapEntry(key.toString(), value));
          yield UserModel.fromJson(userMap);
        }
      } else {
        yield null;
      }
    } catch (e) {
      log("Error getting user profile: $e");
      yield null;
    }
  }

  final StreamController<List<UserModel>> usersController =
  StreamController<List<UserModel>>.broadcast();
  Stream<List<UserModel>> get usersStream => usersController.stream;

  //get Owner permission - Modified for guest users
  void getUsers() async {
    if (!isUserAuthenticated) {
      log("Guest user - cannot access users list");
      usersController.add([]);
      return;
    }

    try {
      Query query = _refDb.child("Users");
      DatabaseEvent databaseEvent = await query.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Map data = dataSnapshot.value as Map;
        List<UserModel> users = data.values
            .map((userValue) => UserModel.fromJson(userValue))
            .toList();
        usersController.add(users);
      } else {
        usersController.add([]);
        log("No users found");
      }
    } catch (e) {
      log("Error getting users: $e");
      usersController.add([]);
    }
    notifyListeners();
  }

  final StreamController<List<UserReqModel>> userReqController =
  StreamController<List<UserReqModel>>.broadcast();
  Stream<List<UserReqModel>> get userReqStream => userReqController.stream;

  //get Agents Members - Modified for guest users
  void getMembers() async {
    if (!isUserAuthenticated) {
      log("Guest user - cannot access members");
      userReqController.add([]);
      return;
    }

    try {
      Query query = _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
      DatabaseEvent databaseEvent = await query.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Map data = dataSnapshot.value as Map;
        List<UserReqModel> requests = data.values
            .map((userValue) => UserReqModel.fromJson(userValue))
            .toList();
        userReqController.add(requests);
      } else {
        log("No members found");
        userReqController.add([]);
      }
    } catch (e) {
      log("Error getting members: $e");
      userReqController.add([]);
    }
    notifyListeners();
  }

  //check user subscriber - Modified for guest users
  bool _subscribed = false;
  bool get subscriber => _subscribed;

  Future<void> loadIsRead() async {
    if (!isUserAuthenticated) {
      _subscribed = false;
      notifyListeners();
      return;
    }

    try {
      await checkExpire();

      final tokenExist = await _refDb
          .child('Users/${AuthServices().fireAuth.currentUser!.uid}/subscription')
          .once();

      if (tokenExist.snapshot.value != null) {
        final subscribe = tokenExist.snapshot.value as Map;
        _subscribed = subscribe['subscribed'] == true;
      } else {
        _subscribed = false;
      }
      notifyListeners();
    } catch (e) {
      log("Error getting subscription database: $e");
      _subscribed = false;
      notifyListeners();
    }
  }

  Future<void> checkExpire() async {
    if (!isUserAuthenticated) return;

    try {
      final uid = AuthServices().fireAuth.currentUser!.uid;
      DateTime currentDate = DateTime.parse(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      final tokenExist = await _refDb.child('Users/$uid/subscription').get();
      if (tokenExist.exists) {
        final subscribe = tokenExist.value as Map;

        if (subscribe['subscribed'] == true) {
          try {
            DateTime expirationDate = DateTime.parse(subscribe['expireDate']);

            if (currentDate.isAfter(expirationDate)) {
              await _refDb.child("Users/$uid/subscription").update({
                'subscribed': false,
              });
              _subscribed = false;
            } else {
              _subscribed = true;
            }
          } catch (e) {
            log("Date format error: ${e.toString()}");
            _subscribed = false;
          }
        } else {
          _subscribed = false;
        }
        notifyListeners();
      }
    } catch (e) {
      log("Error checking subscription expiration: $e");
    }
  }

  Future<void> updateSubscribedUser({
    required String subname,
    required bool inSubscribed,
    required String expiredDate,
  }) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update subscription");
      return;
    }

    try {
      final uid = AuthServices().fireAuth.currentUser!.uid;
      final tokenExist = await _refDb.child('Users/$uid/subscription').once();

      if (!tokenExist.snapshot.exists) {
        log("Subscription node does not exist for user: $uid");
        return;
      }

      final subscriptionData = tokenExist.snapshot.value as Map<String, dynamic>?;
      if (subscriptionData != null && subscriptionData['subscribed'] == false) {
        log("User $uid already unsubscribed. Skipping update.");
        return;
      }

      await _refDb.child("Users/$uid/subscription").update({
        'subname': subname,
        'subscribed': inSubscribed,
        'expireDate': expiredDate,
      });

      _subscribed = inSubscribed;
      notifyListeners();
      log("User $uid subscription updated successfully.");
    } catch (e) {
      log("Error updating subscription: $e");
    }
  }

  //for home page get banner - No modification needed (guests can view banners)
  Stream<List<TopBannerModel>> getBanners() async* {
    try {
      Query query = _refDb.child("TopBanner");
      DatabaseEvent databaseEvent = await query.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Map data = dataSnapshot.value as Map;
        notifyListeners();
        yield data.values
            .map((bannerValue) => TopBannerModel.fromJson(bannerValue))
            .toList();
      } else {
        log("No banners found");
        yield [];
      }
    } catch (e) {
      log("Error getting banners: $e");
      yield [];
    }
  }

  //get All Books - No modification needed (guests can view books)
  final StreamController<List<BookModel>> bookController =
  StreamController<List<BookModel>>.broadcast();
  Stream<List<BookModel>> get bookStream => bookController.stream;

  final StreamController<List<BookModel>> allBookAgentController =
  StreamController<List<BookModel>>.broadcast();
  Stream<List<BookModel>> get allBookAgentStream => allBookAgentController.stream;

  void getBooks({required String category, String? myBooks}) {
    try {
      Query query = _refDb.child("Books/$category");

      query.onValue.listen((DatabaseEvent event) {
        DataSnapshot dataSnapshot = event.snapshot;

        if (dataSnapshot.value != null) {
          Map data = dataSnapshot.value as Map;
          List<BookModel> books = data.values
              .map((bookValue) => BookModel.fromJson(bookValue))
              .toList();
          bookController.add(books);
        } else {
          log("No books found in category: $category");
          bookController.add([]);
        }
      }, onError: (error) {
        log("Error listening to books: $error");
        bookController.add([]);
      });
      _refDb.keepSynced(true);
    } catch (e) {
      log("Error setting up books listener: $e");
      bookController.add([]);
    }
  }

  void getAllAgentBooks() async {
    if (!isUserAuthenticated) {
      log("Guest user - limited access to agent books");
      allBookAgentController.add([]);
      return;
    }

    try {
      DataSnapshot snapshot = await _refDb.child("Books").get();
      List<BookModel> allBooks = [];

      if (snapshot.value != null) {
        log("Getting all agent books");
        Map<String, dynamic> categories =
        Map<String, dynamic>.from(snapshot.value as Map);

        for (String categoryKey in categories.keys) {
          Map<String, dynamic> booksInCategory =
          Map<String, dynamic>.from(categories[categoryKey]);

          allBooks.addAll(
            booksInCategory.values.map((bookData) {
              return BookModel.fromJson(Map<String, dynamic>.from(bookData));
            }),
          );
        }
        allBookAgentController.add(allBooks);
      } else {
        log("No categories found.");
        allBookAgentController.add([]);
      }
    } catch (e) {
      log("Error getting all agent books: $e");
      allBookAgentController.add([]);
    }
  }

  Future<void> updateBookStatus({
    required String category,
    required String bookId,
    required String status,
  }) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update book status");
      return;
    }

    try {
      await _refDb.child("Books/$category/$bookId").update({
        'status': status,
      });
      notifyListeners();
    } catch (e) {
      log("Error updating book status: $e");
    }
  }

  // No modification needed for viewing top books
  Stream<List<BookModel>> getTopBooks({required String category}) async* {
    try {
      Query query = _refDb.child("Books/$category").limitToFirst(10);
      final DatabaseEvent event = await query.once();
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        Map data = dataSnapshot.value as Map;
        List<BookModel> books = data.values
            .map((bookValue) => BookModel.fromJson(bookValue))
            .toList();
        yield books;
      } else {
        log("No top books found");
        yield [];
      }
    } catch (e) {
      log("Error getting top books: $e");
      yield [];
    }
  }

  // No modification needed for viewing single book
  Stream<BookModel?> getLinkBook({
    required String category,
    required String bookId
  }) async* {
    try {
      Query query = _refDb.child("Books/$category/$bookId");
      final DatabaseEvent event = await query.once();
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        BookModel book = BookModel.fromJson(dataSnapshot.value as Map);
        yield book;
      } else {
        log("No Book Found with ID: $bookId");
        yield null;
      }
    } catch (e) {
      log("Error getting book: $e");
      yield null;
    }
  }

  //for book category list - No modification needed
  Stream<List<String>> getCategory(List<String> myCat) async* {
    try {
      Query query = _refDb.child("Categories");
      DatabaseEvent databaseEvent = await query.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Map category = dataSnapshot.value as Map;
        List<String> categories = [];
        category.values.forEach((catValue) => categories.add(catValue.toString()));
        notifyListeners();
        yield categories;
      } else {
        log("No categories found");
        yield [];
      }
    } catch (e) {
      log("Error getting categories: $e");
      yield [];
    }
  }

  //For Home Page - No modification needed
  Stream<List<MyCategories>> getCategories() async* {
    try {
      Query query = _refDb.child("Categories");
      DatabaseEvent databaseEvent = await query.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Map category = dataSnapshot.value as Map;
        yield category.values
            .map((catValue) => MyCategories.fromJson(catValue))
            .toList();
      } else {
        log("No categories found");
        yield [];
      }
    } catch (e) {
      log("Error getting categories: $e");
      yield [];
    }
  }

  // searching - No modification needed
  Future<List<BookModel>> getSearchAllBooks() async {
    try {
      List<BookModel> allBooks = [];
      DataSnapshot snapshot = await _refDb.child("Books").get();

      if (snapshot.value != null) {
        Map<String, dynamic> categories =
        Map<String, dynamic>.from(snapshot.value as Map);

        for (String categoryKey in categories.keys) {
          Map<String, dynamic> booksInCategory =
          Map<String, dynamic>.from(categories[categoryKey]);

          for (String bookId in booksInCategory.keys) {
            Map<String, dynamic> bookData =
            Map<String, dynamic>.from(booksInCategory[bookId]);
            allBooks.add(BookModel.fromJson(bookData));
          }
        }
      }
      return allBooks;
    } catch (e) {
      log("Error searching books: $e");
      return [];
    }
  }

  //Update my profile - Modified for guest users
  Future<void> updateMyUser({required String fullName, required String phone}) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update profile");
      return;
    }

    try {
      final dbEvent = _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
      await dbEvent.update({"name": fullName, "phone": int.parse(phone)});
      await AuthServices().fireAuth.currentUser!.updateDisplayName(fullName);
      notifyListeners();
    } catch (e) {
      log("Error updating user profile: $e");
    }
  }

  //Update Lucky - Modified for guest users
  Future<void> updateLucky({required int lucky}) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update lucky number");
      return;
    }

    try {
      final dbEvent = _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
      await dbEvent.update({"lucky": lucky});
      notifyListeners();
    } catch (e) {
      log("Error updating lucky number: $e");
    }
  }

  //Update Lucky Number - Modified for guest users
  Future<void> updateLuckyNumber({required int lucky}) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update lucky number");
      return;
    }

    try {
      final dbEvent = _refDb.child("luckyUser");
      await dbEvent.update({"lucky": lucky, "weekWin": false});
      notifyListeners();
    } catch (e) {
      log("Error updating lucky number: $e");
    }
  }

  //Update Lucky Switch - Modified for guest users
  Future<void> updateLuckySwitch({required bool isOn}) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update lucky switch");
      return;
    }

    try {
      final dbEvent = _refDb.child("luckyUser");
      await dbEvent.update({"isOn": isOn});
      notifyListeners();
    } catch (e) {
      log("Error updating lucky switch: $e");
    }
  }

  //Update Lucky Week Winner - Modified for guest users
  Future<void> updateLuckyWeekWinner({required bool weekWinner}) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update lucky week winner");
      return;
    }

    try {
      final dbEvent = _refDb.child("luckyUser");
      await dbEvent.update({"weekWin": weekWinner});
      notifyListeners();
    } catch (e) {
      log("Error updating lucky week winner: $e");
    }
  }

  //Update Lucky Win User - Modified for guest users
  Future<void> updateLuckyWinUser({required String winUser}) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update lucky win user");
      return;
    }

    try {
      final dbEvent = _refDb.child("luckyUser");
      await dbEvent.update({"winUser": winUser});
      notifyListeners();
    } catch (e) {
      log("Error updating lucky win user: $e");
    }
  }

  //likes - RESTRICTED FOR GUEST USERS
  Future<void> likeActions({
    required bool isLiked,
    required int likes,
    required String category,
    required String bookId,
    required String uid,
    required String name,
  }) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot like books - authentication required");
      showAuthenticationRequired();
      return;
    }

    try {
      final bookLike = _refDb.child('Books/$category/$bookId/likes/$uid');
      final bookLikes = _refDb.child('Books/$category/$bookId');

      if (isLiked) {
        await bookLike.remove();
        await bookLikes.update({'like': likes - 1});
      } else {
        await bookLike.set({
          'uid': uid,
          'name': name,
          'like': true,
        });
        await bookLikes.update({'like': likes + 1});
      }
      notifyListeners();
      log("Like action completed: $isLiked, $likes, $category, $bookId, $uid, $name");
    } catch (e) {
      log("Error in like action: $e");
    }
  }

  //update Version - Modified for guest users
  Future<void> updateAppVersions({
    String? newVersion,
    bool? updating,
    bool? waiting,
  }) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update app versions");
      return;
    }

    try {
      Map<String, dynamic> updates = {};

      if (newVersion != null) updates['version'] = newVersion;
      if (updating != null) updates['updating'] = updating;
      if (waiting != null) updates['waiting'] = waiting;

      if (updates.isNotEmpty) {
        await _refDb.child('$dbName/updates').update(updates);
        notifyListeners();
      }
    } catch (e) {
      log("Error updating app versions: $e");
    }
  }

  //Rate - RESTRICTED FOR GUEST USERS
  Future<void> ratingActions({
    required bool isRated,
    required int totalRates,
    required double averageRate,
    String? uid,
    String? username,
    required double rate,
    String? category,
    String? bookId,
  }) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot rate books - authentication required");
      showAuthenticationRequired();
      return;
    }

    try {
      final bookUserRates = _refDb.child('Books/$category/$bookId/rates/$uid');
      final bookTotalAvgRate = _refDb.child('Books/$category/$bookId');

      if (!isRated) {
        // Adding a new rate
        totalRates += 1;
        averageRate = ((averageRate * (totalRates - 1)) + rate) / totalRates;
        averageRate = averageRate > 5.0 ? 5.0 : averageRate;

        await bookUserRates.set({
          'uid': uid,
          'name': username,
          'rate': "$rate",
        });

        await bookTotalAvgRate.update({
          'totalRates': "$totalRates",
          'averageRate': "$averageRate",
        });
      } else {
        // Updating an existing rate
        DataSnapshot snapshot = await bookUserRates.get();
        if (snapshot.exists) {
          double oldRate = double.parse(snapshot.child('rate').value.toString());
          averageRate = ((averageRate * totalRates) - oldRate + rate) / totalRates;
          averageRate = averageRate > 5.0 ? 5.0 : averageRate;

          await bookUserRates.update({'rate': "$rate"});
          await bookTotalAvgRate.update({'averageRate': "$averageRate"});
        }
      }
      notifyListeners();
    } catch (e) {
      log("Error in rating action: $e");
    }
  }

  //check user Role - Modified for guest users
  Future<bool> checkUser() async {
    if (!isUserAuthenticated) {
      return false; // Guest users are not banned
    }

    try {
      DataSnapshot dataSnapshot = await _refDb
          .child('Users/${AuthServices().fireAuth.currentUser!.uid}')
          .get();

      if (dataSnapshot.value != null) {
        final Map role = dataSnapshot.value as Map;
        return role['role'] == "Banned";
      }
      return false;
    } catch (e) {
      log("Error checking user role: $e");
      return false;
    }
  }

  Future<void> userPrevilage(String userId, String newValue) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot change user privileges");
      return;
    }

    try {
      await _refDb.child('Users/$userId').update({"role": newValue});
    } catch (e) {
      log("Error updating user privilege: $e");
    }
  }

  //Agents Operations - Modified for guest users
  Future<void> opMembers(String userId, String status) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot manage members");
      return;
    }

    try {
      final agent = _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
      final user = _refDb.child("Users");

      await agent.child(userId).update({"status": status});
      await user.child(userId).update({"uploader": status == "Active"});
      notifyListeners();
    } catch (e) {
      log("Error managing member: $e");
    }
  }

  Future<void> deleteMember(String userId) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot delete members");
      return;
    }

    try {
      final agent = _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
      final user = _refDb.child("Users");

      await agent.child(userId).remove();
      await user.child(userId).update({"uploader": false});
      notifyListeners();
    } catch (e) {
      log("Error deleting member: $e");
    }
  }

  //Request user uploader - Modified for guest users
  Future<void> sendRequest({
    required String name,
    required String email,
    required String phone,
    required String ldrName,
    required String selectedAgent,
    required bool isRequested,
  }) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot send upload requests - authentication required");
      showAuthenticationRequired();
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = _refDb.child("Agents/$selectedAgent/$uid");

      await ref.set({
        "uid": uid,
        "name": name,
        "email": email,
        "phone": phone,
        "sub": selectedAgent,
        "status": "Inactive",
      });

      await _refDb.child("Users/$uid").update({'uprequest': true});
      notifyListeners();
    } catch (e) {
      log("Error sending request: $e");
    }
  }

  // No modification needed for viewing agents
  Future<void> getAgents({required Map<String, String> menuItems}) async {
    try {
      final ref = _refDb.child("Agents");
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final leaders = event.snapshot.value as Map;
          leaders.forEach((key, value) {
            final agent = value as Map<dynamic, dynamic>;
            if (agent['role'].toString() == 'Agent') {
              menuItems[agent['uid'].toString()] = agent['name'].toString();
              notifyListeners();
            }
          });
        }
      });
    } catch (e) {
      log("Error getting agents: $e");
    }
  }

  Future<void> addNewBanner({
    required String title,
    required String imgLink,
    required bool status,
    String? actionLink,
  }) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot add banners");
      return;
    }

    try {
      await _refDb.child("TopBanner").push().set({
        "title": title,
        "imgLink": imgLink,
        "toGoLink": actionLink ?? "",
        "status": status ? "on" : "off",
      });
    } catch (e) {
      log("Error adding banner: $e");
    }
  }

  //Delete topBanner - Modified for guest users
  Future<void> deleteBanner(String title) async {
    if (!isUserAuthenticated) {
      log("Guest user cannot delete banners");
      return;
    }

    try {
      DataSnapshot dataSnapshot = await _refDb.child("TopBanner").get();
      if (dataSnapshot.value != null) {
        Map data = dataSnapshot.value as Map;
        data.forEach((key, value) {
          if (value['title'] == title) {
            _refDb.child("TopBanner/$key").remove();
          }
        });
      } else {
        log("No banners found");
      }
    } catch (e) {
      log("Error deleting banner: $e");
    }
  }

  //checkAndUpdateLuckyDate - Modified for guest users
  Future<void> checkAndUpdateLuckyDate() async {
    if (!isUserAuthenticated) {
      log("Guest user cannot update lucky date");
      return;
    }

    try {
      final dbEvent = _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
      DateTime today = DateTime.now();
      String todayStr = DateFormat('yyyy-MM-dd').format(today);
      await dbEvent.update({"luckyDate": todayStr});
      log("luckyDate updated to $todayStr");
      notifyListeners();
    } catch (e) {
      log("Error updating lucky date: $e");
    }
  }

  // Helper method to show authentication required dialog/message
  void showAuthenticationRequired() {
    // You can implement this to show a dialog or navigate to login
    log("Authentication required - please login to perform this action");
    // Consider adding a callback or event to notify UI components
  }

  @override
  void dispose() {
    bookController.close();
    userReqController.close();
    usersController.close();
    allBookAgentController.close();
    super.dispose();
  }
}

// import 'dart:async';
// import 'dart:developer';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:sboapp/app_model/book_model.dart';
// import 'package:sboapp/app_model/top_banner_model.dart';
// import 'package:sboapp/app_model/user_model.dart';
// import 'package:sboapp/Services/auth_services.dart';
//
// const String dbName = "SBO";
//
// class GetDatabase extends ChangeNotifier {
//   final DatabaseReference _refDb = FirebaseDatabase.instance.ref(dbName);
//
//   //final DatabaseReference _refDb = FirebaseDatabase.instance.ref("SBOTest");
//
//   // Helper method to check if user is authenticated (not guest)
//   bool get isUserAuthenticated => AuthServices().fireAuth.currentUser != null && !AuthServices().fireAuth.currentUser!.isAnonymous;
//
//   // Helper method to check if user is guest
//   bool get isGuestUser => AuthServices().fireAuth.currentUser?.isAnonymous == true || AuthServices().fireAuth.currentUser == null;
//
//   //get my profile - Modified for guest users
//   Stream<UserModel> getMyUser() async* {
//     if (!isUserAuthenticated) {
//       // Return a default guest user model or handle accordingly
//       log("Guest user - cannot get profile");
//       return;
//     }
//
//     Query query =
//     _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Object? users = dataSnapshot.value;
//       if (users != null && users is Map<dynamic, dynamic>) {
//         Map<String, dynamic> usersMap =
//         users.map((key, value) => MapEntry(key.toString(), value));
//
//         //Map role = usersMap.values as Map;
//         notifyListeners();
//         yield UserModel.fromJson(usersMap);
//       }
//     } else {
//       log("No Rows Found");
//     }
//   }
//
//   Stream<UserModel> userProfile({required String uid}) async* {
//     Query query = _refDb.child("Users/$uid");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Object? user = dataSnapshot.value;
//       if (user != null && user is Map<dynamic, dynamic>) {
//         Map<String, dynamic> userMap =
//         user.map((key, value) => MapEntry(key.toString(), value));
//         yield UserModel.fromJson(userMap);
//       }
//     }
//   }
//
//   final StreamController<List<UserModel>> usersController =
//   StreamController<List<UserModel>>.broadcast();
//   Stream<List<UserModel>> get usersStream => usersController.stream;
//
//   //get Owner permission - Modified for guest users:
//   Stream<List<UserModel>> getUsers() async* {
//     if (!isUserAuthenticated) {
//       log("Guest user - cannot access users list");
//       usersController.add([]);
//       return;
//     }
//
//     Query query = _refDb.child("Users");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       //notifyListeners();
//       List<UserModel> users = data.values
//           .map((bookValue) => UserModel.fromJson(bookValue))
//           .toList();
//       usersController.add(users);
//       /*data.values
//           .map((userValue) => UserModel.fromJson(userValue))
//           .toList();*/
//     } else {
//       usersController.add([]);
//       log("No Rows Found");
//     }
//     notifyListeners();
//   }
//
//   final StreamController<List<UserReqModel>> userReqController =
//   StreamController<List<UserReqModel>>.broadcast();
//   Stream<List<UserReqModel>> get userReqStream => userReqController.stream;
//
//   //get Agents Members - Modified for guest users:
//   Stream<List<UserReqModel>> getMembers() async* {
//     if (!isUserAuthenticated) {
//       log("Guest user - cannot access members");
//       userReqController.add([]);
//       return;
//     }
//
//     Query query =
//     _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       List<UserReqModel> requests = data.values
//           .map((userValue) => UserReqModel.fromJson(userValue))
//           .toList();
//       userReqController.add(requests);
//
//     } else {
//       log("No Rows Found");
//       userReqController.add([]);
//     }
//     notifyListeners();
//   }
//
//   //check user subcriber - Modified for guest users;
//   bool _subscribed = false;
//   bool get subscriber => _subscribed;
//   Future<void> loadIsRead() async {
//     if (!isUserAuthenticated) {
//       _subscribed = false;
//       notifyListeners();
//       return;
//     }
//
//     try {
//       checkExpire();
//       if (AuthServices().fireAuth.currentUser != null) {
//         final tokenExist = await _refDb
//             .child(
//             'Users/${AuthServices().fireAuth.currentUser!.uid}/subscription')
//             .once();
//         if (tokenExist.snapshot.value != null) {
//           final subscribe = tokenExist.snapshot.value as Map;
//           if (subscribe['subscribed'] != null &&
//               subscribe['subscribed'] != false) {
//             _subscribed = subscribe['subscribed'];
//             notifyListeners();
//           } else {
//             _subscribed = false;
//             notifyListeners();
//           }
//         }
//       }
//     } catch (e) {
//       log("error for geting subscription database $e");
//       rethrow;
//     }
//   }
//
//   Future<void> checkExpire() async {
//     if (!isUserAuthenticated) return;
//
//     try {
//       if (AuthServices().fireAuth.currentUser != null) {
//         final uid = AuthServices().fireAuth.currentUser!.uid;
//
//         // Parse current date to only include year, month, and day
//         DateTime currentDate = DateTime.parse(
//           DateFormat('yyyy-MM-dd').format(DateTime.now()),
//         );
//
//         final tokenExist = await _refDb.child('Users/$uid/subscription').get();
//         if (tokenExist.exists) {
//           final subscribe = tokenExist.value as Map;
//
//           if (subscribe['subscribed'] == true) {
//             try {
//               // Parse expireDate and ensure it's in yyyy-MM-dd format
//               DateTime expirationDate = DateTime.parse(subscribe['expireDate']);
//
//               // Update Firebase with subscription status based on expiration
//               if (currentDate.isAfter(expirationDate)) {
//                 await _refDb.child("Users/$uid/subscription").update({
//                   'subscribed': false,
//                 });
//               }
//               notifyListeners();
//             } catch (e) {
//               log("Date format error: ${e.toString()}");
//             }
//           } else {
//             _subscribed = false;
//             notifyListeners();
//           }
//         }
//       }
//     } catch (e) {
//       log("Error for getting subscription database: $e");
//       rethrow;
//     }
//   }
//
//   Future<void> updateSubscribedUser({
//     required String subname,
//     required bool inSubscribed,
//     required String expiredDate,
//   }) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update subscription");
//       return;
//     }
//
//     final uid = AuthServices().fireAuth.currentUser!.uid;
//
//     // Fetch the subscription details
//     final tokenExist = await _refDb.child('Users/$uid/subscription').once();
//
//     // If the subscription node doesn't exist, skip the update
//     if (!tokenExist.snapshot.exists) {
//       log("Subscription node does not exist for user: $uid");
//       return;
//     }
//
//     // Check if `subscribed` is already false and skip update
//     final subscriptionData = tokenExist.snapshot.value as Map<String, dynamic>?;
//     if (subscriptionData != null && subscriptionData['subscribed'] == false) {
//       log("User $uid already unsubscribed. Skipping update.");
//       return;
//     }
//
//     // Proceed to update the subscription
//     await _refDb.child("Users/$uid/subscription").update({
//       'subname': subname,
//       'subscribed': inSubscribed,
//       'expireDate': expiredDate,
//     });
//
//     // Update the local state
//     _subscribed = inSubscribed;
//     notifyListeners();
//
//     log("User $uid subscription updated successfully.");
//   }
//
//   //for home page get banner!. - No modification needed (guests can view banners)
//   Stream<List<TopBannerModel>> getBanners() async* {
//     //DataSnapshot dataSnapshot = await _refDb.child("TopBanner").get();
//     Query query = _refDb.child("TopBanner");
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       notifyListeners();
//       yield data.values
//           .map((bannerValue) => TopBannerModel.fromJson(bannerValue))
//           .toList();
//     } else {
//       log("No Rows Found");
//     }
//   }
//
//   //get All Books - No modification needed (guests can view books)
//
//   final StreamController<List<BookModel>> bookController =
//   StreamController<List<BookModel>>.broadcast();
//   Stream<List<BookModel>> get bookStream => bookController.stream;
//
//   final StreamController<List<BookModel>> allBookAgentController =
//   StreamController<List<BookModel>>.broadcast();
//   Stream<List<BookModel>> get allBookAgentStream => bookController.stream;
//
//   void getBooks({required String category, String? myBooks}) {
//     Query query = _refDb.child("Books/$category");
//
//     // Listen for changes in the database
//     query.onValue.listen((DatabaseEvent event) {
//       DataSnapshot dataSnapshot = event.snapshot;
//
//       if (dataSnapshot.value != null) {
//         Map data = dataSnapshot.value as Map;
//         List<BookModel> books = data.values
//             .map((bookValue) => BookModel.fromJson(bookValue))
//             .toList();
//         bookController.add(books);
//       } else {
//         log("No Rows Found");
//         bookController.add([]);
//       }
//     });
//     _refDb.keepSynced(true);
//   }
//
//   void getAllAgentBooks() async {
//     if (!isUserAuthenticated) {
//       log("Guest user - limited access to agent books");
//       allBookAgentController.add([]);
//       return;
//     }
//
//     DataSnapshot snapshot = await _refDb.child("Books").get();
//     List<BookModel> allBooks = [];
//
//     if (snapshot.value != null) {
//       log("message snap is not null");
//       Map<String, dynamic> categories =
//       Map<String, dynamic>.from(snapshot.value as Map);
//
//       // Traverse each category and collect books in a single list
//       for (String categoryKey in categories.keys) {
//         Map<String, dynamic> booksInCategory =
//         Map<String, dynamic>.from(categories[categoryKey]);
//
//         // Convert each book in the category to BookModel and add to allBooks
//         allBooks.addAll(
//           booksInCategory.values.map((bookData) {
//             return BookModel.fromJson(Map<String, dynamic>.from(bookData));
//           }),
//         );
//       }
//
//       // Add the accumulated list of all books to the controller
//       allBookAgentController.add(allBooks);
//     } else {
//       log("No categories found.");
//       allBookAgentController.add([]);
//     }
//   }
//
//   Future<void> updateBookStatus({
//     required String category,
//     required String bookId,
//     required String status,
//   }) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update book status");
//       return;
//     }
//
//     _refDb.child("Books/$category/$bookId").update({
//       'status': status,
//     });
//     notifyListeners();
//   }
//
//   // No modification needed for viewing top books
//   Stream<List<BookModel>> getTopBooks({required String category}) async* {
//     Query query = _refDb.child("Books/$category").limitToFirst(
//         10); // Assuming 'likes' is a field in your book data.limitToFirst(10); // Get the top 10 books with the most likes
//
//     // Fetch the data once and return it as a future
//     final DatabaseEvent event = await query.once();
//     DataSnapshot dataSnapshot = event.snapshot;
//
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       // Convert the Firebase data into a list of BookModel
//       List<BookModel> books = data.values
//           .map((bookValue) => BookModel.fromJson(bookValue))
//           .toList();
//       yield books;
//     } else {
//       log("No Rows Found");
//       yield [];
//     }
//   }
//
//   // No modification needed for viewing single book
//   Stream<BookModel> getLinkBook(
//       {required String category, required String bookId}) async* {
//     Query query = _refDb.child("Books/$category/$bookId");
//
//     // Fetch the data once and return it as a future
//     final DatabaseEvent event = await query.once();
//     DataSnapshot dataSnapshot = event.snapshot;
//
//     if (dataSnapshot.value != null) {
//       // Convert the Firebase data to a BookModel instance
//       BookModel book = BookModel.fromJson(dataSnapshot.value as Map);
//       yield book;
//     } else {
//       log("No Book Found with ID: $bookId");
//     }
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     bookController.close();
//     userReqController.close();
//     usersController.close();
//   }
//
//   //for book category list - No modification needed
//   Stream<List<String>> getCategory(List<String> myCat) async* {
//     try {
//       Query query = _refDb.child("Categories");
//
//       DatabaseEvent databaseEvent = await query.once();
//       DataSnapshot dataSnapshot = databaseEvent.snapshot;
//
//       if (dataSnapshot.value != null) {
//         Map category = dataSnapshot.value as Map;
//         notifyListeners();
//         category.values.map((catValue) => myCat.add(catValue)).toList();
//         yield myCat;
//       } else {
//         log("No Rows Found");
//         yield [];
//       }
//     } catch (e) {
//       log(e.toString());
//     }
//   }
//
//   //For Home Page - No modification needed
//   Stream<List<MyCategories>> getCategories() async* {
//     Query query = _refDb.child("Categories");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//
//     if (dataSnapshot.value != null) {
//       Map category = dataSnapshot.value as Map;
//       yield category.values
//           .map((catValue) => MyCategories.fromJson(catValue))
//           .toList();
//     } else {
//       log("No Rows Found");
//       yield [];
//     }
//   }
//
//   // searching - No modification needed
//   Future<List<BookModel>> getSearchAllBooks() async {
//     List<BookModel> allBooks = [];
//
//     // Get the categories (e.g., Islamic, Science, etc.)
//     DataSnapshot snapshot = await _refDb.child("Books").get();
//     Map<String, dynamic> categories =
//     Map<String, dynamic>.from(snapshot.value as Map);
//
//     // Traverse through each category and fetch books
//     for (String categoryKey in categories.keys) {
//       Map<String, dynamic> booksInCategory =
//       Map<String, dynamic>.from(categories[categoryKey]);
//
//       for (String bookId in booksInCategory.keys) {
//         // Get the book details from the bookId
//         Map<String, dynamic> bookData =
//         Map<String, dynamic>.from(booksInCategory[bookId]);
//
//         // Convert to BookModel and add to list
//         allBooks.add(BookModel.fromJson(bookData));
//       }
//     }
//     return allBooks;
//   }
//
//   //methods
//
//   //Update my profile - Modified for guest users
//   void updateMyUser({required String fullName, required String phone}) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update profile");
//       return;
//     }
//
//     final dbEvent =
//     _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//     dbEvent
//         .update({"name": fullName, "phone": int.parse(phone)}).whenComplete(() {
//       AuthServices().fireAuth.currentUser!.updateDisplayName(fullName);
//       notifyListeners();
//     });
//   }
//
//   //Update Lucky - Modified for guest users
//   void updateLucky({required int lucky}) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update lucky number");
//       return;
//     }
//
//     final dbEvent =
//     _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//     dbEvent.update({
//       "lucky": lucky,
//     });
//     notifyListeners();
//   }
//
//   //Update Lucky - Modified for guest users
//   void updateLuckyNumber({required int lucky}) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update lucky number");
//       return;
//     }
//
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({"lucky": lucky, "weekWin": false});
//     notifyListeners();
//   }
//
//   //Update Lucky - Modified for guest users
//   void updateLuckySwitch({required bool isOn}) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update lucky switch");
//       return;
//     }
//
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({
//       "isOn": isOn,
//     });
//     notifyListeners();
//   }
//
//   //Update Lucky - Modified for guest users
//   void updateLuckyWeekWinner({required bool weekWinner}) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update lucky week winner");
//       return;
//     }
//
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({
//       "weekWin": weekWinner,
//     });
//     notifyListeners();
//   }
//
//   //Update Lucky win user!. - Modified for guest users
//   void updateLuckyWinUser({required String winUser}) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update lucky win user");
//       return;
//     }
//
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({
//       "winUser": winUser,
//     });
//     notifyListeners();
//   }
//
//   //likes - RESTRICTED FOR GUEST USERS
//   void likeActions(
//       {required bool isLiked,
//         required int likes,
//         required String category,
//         bookId,
//         uid,
//         name}) async {
//
//     if (!isUserAuthenticated) {
//       log("Guest user cannot like books - authentication required");
//       // You might want to show a dialog or navigate to login here
//       return;
//     }
//
//     final bookLike = _refDb.child('Books/$category/$bookId/likes/$uid');
//     final bookLikes = _refDb.child('Books/$category/$bookId');
//     try {
//       isLiked
//           ? await bookLike.remove()
//           : await bookLike.set({
//         'uid': uid,
//         'name': name,
//         'like': true,
//       }).whenComplete(() => notifyListeners());
//       isLiked
//           ? await bookLikes.update({'like': likes - 1})
//           : await bookLikes.update({'like': likes + 1}).whenComplete(
//               () => notifyListeners());
//       log("$isLiked, $likes, $category, $bookId, $uid, $name");
//     } catch (e) {
//       log("error");
//     }
//   }
//
//   //update Version - Modified for guest users
//   void updateAppVersions({
//     String? newVersion,
//     bool? updating,
//     bool? waiting,
//   }) {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update app versions");
//       return;
//     }
//
//     if(newVersion != null && updating != null && waiting != null){
//       _refDb.child('$dbName/updates').update({
//         'version' : newVersion,
//         'updating' : updating,
//         'waiting' : waiting,
//       });
//     }else {
//       if (newVersion != null) {
//         _refDb.child('$dbName/updates').update({
//           'version': newVersion,
//         });
//       }
//       if (updating != null) {
//         _refDb.child('$dbName/updates').update({
//           'updating': updating,
//         });
//       }
//       if (waiting != null) {
//         _refDb.child('$dbName/updates').update({
//           'waiting': waiting,
//         });
//       }
//     }
//     notifyListeners();
//   }
//
//   //Rate - RESTRICTED FOR GUEST USERS
//   void ratingActions({
//     required bool isRated,
//     required int totalRates,
//     required double averageRate,
//     String? uid,
//     String? username,
//     required double rate,
//     String? category,
//     String? bookId,
//   }) async {
//
//     if (!isUserAuthenticated) {
//       log("Guest user cannot rate books - authentication required");
//       // You might want to show a dialog or navigate to login here
//       return;
//     }
//
//     final bookUserRates = _refDb.child('Books/$category/$bookId/rates/$uid');
//     final bookTotalAvgRate = _refDb.child('Books/$category/$bookId');
//
//     try {
//       // Check if the user has already rated
//       if (!isRated) {
//         // Adding a new rate
//         totalRates += 1;
//         averageRate = ((averageRate * (totalRates - 1)) + rate) / totalRates;
//
//         // Ensure average does not exceed 5.0
//         averageRate = averageRate > 5.0 ? 5.0 : averageRate;
//
//         await bookUserRates.set({
//           'uid': uid,
//           'name': username,
//           'rate': "$rate",
//         });
//
//         // Update total rates and average rate
//         await bookTotalAvgRate.update({
//           'totalRates': "$totalRates",
//           'averageRate': "$averageRate",
//         });
//       } else {
//         // Updating an existing rate
//         DataSnapshot snapshot = await bookUserRates.get();
//         if (snapshot.exists) {
//           double oldRate =
//           double.parse(snapshot.child('rate').value.toString());
//           averageRate =
//               ((averageRate * totalRates) - oldRate + rate) / totalRates;
//
//           // Ensure average does not exceed 5.0
//           averageRate = averageRate > 5.0 ? 5.0 : averageRate;
//
//           await bookUserRates.update({
//             'rate': "$rate",
//           });
//
//           // Update average rate
//           await bookTotalAvgRate.update({
//             'averageRate': "$averageRate",
//           });
//         }
//       }
//       notifyListeners();
//     } catch (e) {
//       log("An error occurred: $e");
//       // Handle any additional error logging or recovery here if needed
//     }
//   }
//
//   //check user Role - Modified for guest users
//   Future<bool> checkUser() async {
//     if (!isUserAuthenticated) {
//       return false; // Guest users are not banned
//     }
//
//     bool isBanned = false;
//     if (AuthServices().fireAuth.currentUser != null) {
//       DataSnapshot dataSnapshot = await _refDb
//           .child('Users/${AuthServices().fireAuth.currentUser!.uid}')
//           .get();
//       if (dataSnapshot.value != null) {
//         final Map role = dataSnapshot.value as Map;
//         return isBanned = role['role'] == "Banned";
//       }
//     }
//     return isBanned;
//   }
//
//   Future<void> userPrevilage(userId, newValue) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot change user privileges");
//       return;
//     }
//
//     _refDb.child('Users/$userId').update({
//       "role": newValue.toString(),
//     });
//   }
//
//   //Agents Operations - Modified for guest users:
//   Future<void> opMembers(userId, status) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot manage members");
//       return;
//     }
//
//     final agent =
//     _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
//     final user = _refDb.child("Users");
//     agent.child(userId).update({"status": status});
//     user.child(userId).update({"uploader": status == "Active"});
//     notifyListeners();
//   }
//
//   Future<void> deleteMember(userId) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot delete members");
//       return;
//     }
//
//     final agent =
//     _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
//     final user = _refDb.child("Users");
//     agent.child(userId).remove();
//     user.child(userId).update({"uploader": false});
//     notifyListeners();
//   }
//
//   //Request user uploader - Modified for guest users
//   Future<void> sendRequest(
//       {name, email, phone, ldrName, selectedAgent, isRequested}) async {
//
//     if (!isUserAuthenticated) {
//       log("Guest user cannot send upload requests - authentication required");
//       return;
//     }
//
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final ref = _refDb.child("Agents/$selectedAgent/$uid");
//     ref.set({
//       "uid": uid,
//       "name": name,
//       "email": email,
//       "phone": phone,
//       "sub": selectedAgent,
//       "status": "Inactive",
//     }).whenComplete(() {
//       final ref = _refDb.child("Users/$uid");
//       ref.update({
//         'uprequest': true,
//       }).catchError((error) {});
//     }).whenComplete(() {
//       isRequested = true;
//       notifyListeners();
//     });
//   }
//
//   // No modification needed for viewing agents
//   Future<void> getAgents({required menuItems}) async {
//     final ref = _refDb.child("Agents");
//     ref.onValue.listen((event) async {
//       if (event.snapshot.value != null) {
//         final leaders = event.snapshot.value as Map;
//         leaders.forEach((key, value) async {
//           final agent = await value as Map<dynamic, dynamic>;
//           if (agent['role'].toString() == 'Agent') {
//             menuItems
//                 .addAll({agent['uid'].toString(): agent['name'].toString()});
//             notifyListeners();
//           }
//         });
//       }
//     });
//   }
//
//   void addNewBanner({
//     required String title,
//     required String imgLink,
//     required bool status,
//     String? actionLink,
//   }) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot add banners");
//       return;
//     }
//
//     _refDb.child("TopBanner").push().set({
//       "title": title,
//       "imgLink": imgLink,
//       "toGoLink": actionLink ?? "",
//       "status": status ? "on" : "off",
//     });
//   }
//
//   //Delete topBanner() - Modified for guest users
//   void deleteBanner(title) async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot delete banners");
//       return;
//     }
//
//     DataSnapshot dataSnapshot = await _refDb.child("TopBanner").get();
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       log(data.toString());
//       data.forEach((key, value) {
//         if (value['title'] == title) {
//           log(key.toString());
//         }
//       });
//     } else {
//       log("No Rows Found");
//     }
//   }
//
//   //getAndUpdateWin - Modified for guest users
//   Future<void> checkAndUpdateLuckyDate() async {
//     if (!isUserAuthenticated) {
//       log("Guest user cannot update lucky date");
//       return;
//     }
//
//     final dbEvent =
//     _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//     DateTime today = DateTime.now();
//     String todayStr = DateFormat('yyyy-MM-dd').format(today);
//     await dbEvent.update({"luckyDate": todayStr});
//     log("luckyDate updated to $todayStr");
//     notifyListeners();
//   }
//
//   // Helper method to show authentication required dialog/message
//   void showAuthenticationRequired() {
//     // You can implement this to show a dialog or navigate to login
//     log("Authentication required - please login to perform this action");
//   }
// }

// import 'dart:async';
// import 'dart:developer';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:sboapp/app_model/book_model.dart';
// import 'package:sboapp/app_model/top_banner_model.dart';
// import 'package:sboapp/app_model/user_model.dart';
// import 'package:sboapp/Services/auth_services.dart';
//
// const String dbName = "SBO";
//
// class GetDatabase extends ChangeNotifier {
//   final DatabaseReference _refDb = FirebaseDatabase.instance.ref(dbName);
//
//   //final DatabaseReference _refDb = FirebaseDatabase.instance.ref("SBOTest");
//
//   //get my profile
//   Stream<UserModel> getMyUser() async* {
//     Query query =
//         _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Object? users = dataSnapshot.value;
//       if (users != null && users is Map<dynamic, dynamic>) {
//         Map<String, dynamic> usersMap =
//             users.map((key, value) => MapEntry(key.toString(), value));
//
//         //Map role = usersMap.values as Map;
//         notifyListeners();
//         yield UserModel.fromJson(usersMap);
//       }
//     } else {
//       log("No Rows Found");
//     }
//   }
//
//   Stream<UserModel> userProfile({required String uid}) async* {
//     Query query = _refDb.child("Users/$uid");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Object? user = dataSnapshot.value;
//       if (user != null && user is Map<dynamic, dynamic>) {
//         Map<String, dynamic> userMap =
//             user.map((key, value) => MapEntry(key.toString(), value));
//         yield UserModel.fromJson(userMap);
//       }
//     }
//   }
//
//   final StreamController<List<UserModel>> usersController =
//   StreamController<List<UserModel>>.broadcast();
//   Stream<List<UserModel>> get usersStream => usersController.stream;
//   //get Owner permission:
//   Stream<List<UserModel>> getUsers() async* {
//     Query query = _refDb.child("Users");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       //notifyListeners();
//       List<UserModel> users = data.values
//           .map((bookValue) => UserModel.fromJson(bookValue))
//           .toList();
//       usersController.add(users);
//       /*data.values
//           .map((userValue) => UserModel.fromJson(userValue))
//           .toList();*/
//     } else {
//       usersController.add([]);
//       log("No Rows Found");
//     }
//     notifyListeners();
//   }
//
//   final StreamController<List<UserReqModel>> userReqController =
//   StreamController<List<UserReqModel>>.broadcast();
//   Stream<List<UserReqModel>> get userReqStream => userReqController.stream;
//   //get Agents Members:
//   Stream<List<UserReqModel>> getMembers() async* {
//     Query query =
//         _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       List<UserReqModel> requests = data.values
//           .map((userValue) => UserReqModel.fromJson(userValue))
//           .toList();
//       userReqController.add(requests);
//
//     } else {
//       log("No Rows Found");
//       userReqController.add([]);
//     }
//     notifyListeners();
//   }
//
//   //check user subcriber;
//   bool _subscribed = false;
//   bool get subscriber => _subscribed;
//   Future<void> loadIsRead() async {
//     try {
//       checkExpire();
//       if (AuthServices().fireAuth.currentUser != null) {
//         final tokenExist = await _refDb
//             .child(
//                 'Users/${AuthServices().fireAuth.currentUser!.uid}/subscription')
//             .once();
//         if (tokenExist.snapshot.value != null) {
//           final subscribe = tokenExist.snapshot.value as Map;
//           if (subscribe['subscribed'] != null &&
//               subscribe['subscribed'] != false) {
//             _subscribed = subscribe['subscribed'];
//             notifyListeners();
//           } else {
//             _subscribed = false;
//             notifyListeners();
//           }
//         }
//       }
//     } catch (e) {
//       log("error for geting subscription database $e");
//       rethrow;
//     }
//   }
//
//   Future<void> checkExpire() async {
//     try {
//       if (AuthServices().fireAuth.currentUser != null) {
//         final uid = AuthServices().fireAuth.currentUser!.uid;
//
//         // Parse current date to only include year, month, and day
//         DateTime currentDate = DateTime.parse(
//           DateFormat('yyyy-MM-dd').format(DateTime.now()),
//         );
//
//         final tokenExist = await _refDb.child('Users/$uid/subscription').get();
//         if (tokenExist.exists) {
//           final subscribe = tokenExist.value as Map;
//
//           if (subscribe['subscribed'] == true) {
//             try {
//               // Parse expireDate and ensure it's in yyyy-MM-dd format
//               DateTime expirationDate = DateTime.parse(subscribe['expireDate']);
//
//               // Update Firebase with subscription status based on expiration
//               if (currentDate.isAfter(expirationDate)) {
//                 await _refDb.child("Users/$uid/subscription").update({
//                   'subscribed': false,
//                 });
//               }
//               notifyListeners();
//             } catch (e) {
//               log("Date format error: ${e.toString()}");
//             }
//           } else {
//             _subscribed = false;
//             notifyListeners();
//           }
//         }
//       }
//     } catch (e) {
//       log("Error for getting subscription database: $e");
//       rethrow;
//     }
//   }
//
//   /*Future<void> checkExpire() async {
//
//     try {
//       if (AuthServices().fireAuth.currentUser != null) {
//         final uid = AuthServices().fireAuth.currentUser!.uid;
//
//         // Parse current date to only include year, month, and day
//         DateTime currentDate = DateFormat('yyyy-MM-dd').parse(
//             "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}");
//
//         final tokenExist = await _refDb.child('Users/$uid/subscription').once();
//
//         if (tokenExist.snapshot.value != null) {
//           final subscribe = tokenExist.snapshot.value as Map;
//
//           if (subscribe['subscribed'] != null ||
//               subscribe['subscribed'] != false) {
//             try {
//               // Parse expireDate and ensure it's in yyyy-MM-dd format
//               DateTime expirationDate = DateTime.parse(subscribe['expireDate']);
//
//               // Update Firebase with subscription status based on expiration
//               if (currentDate.isAfter(expirationDate)) {
//                 _refDb.child("Users/$uid/subscription").update({
//                   'subscribed': false,
//                 });
//               }
//               notifyListeners();
//             } catch (e) {
//               log("Date format error: ${e.toString()}");
//             }
//           } else {
//             _subscribed = false;
//             notifyListeners();
//           }
//         }
//       }
//     } catch (e) {
//       log("error for geting subscription database $e");
//       rethrow;
//     }
//   }*/
//
//   Future<void> updateSubscribedUser({
//     required String subname,
//     required bool inSubscribed,
//     required String expiredDate,
//   }) async {
//     final uid = AuthServices().fireAuth.currentUser!.uid;
//
//     // Fetch the subscription details
//     final tokenExist = await _refDb.child('Users/$uid/subscription').once();
//
//     // If the subscription node doesn't exist, skip the update
//     if (!tokenExist.snapshot.exists) {
//       log("Subscription node does not exist for user: $uid");
//       return;
//     }
//
//     // Check if `subscribed` is already false and skip update
//     final subscriptionData = tokenExist.snapshot.value as Map<String, dynamic>?;
//     if (subscriptionData != null && subscriptionData['subscribed'] == false) {
//       log("User $uid already unsubscribed. Skipping update.");
//       return;
//     }
//
//     // Proceed to update the subscription
//     await _refDb.child("Users/$uid/subscription").update({
//       'subname': subname,
//       'subscribed': inSubscribed,
//       'expireDate': expiredDate,
//     });
//
//     // Update the local state
//     _subscribed = inSubscribed;
//     notifyListeners();
//
//     log("User $uid subscription updated successfully.");
//   }
//
//
//   //for home page get banner!.
//   Stream<List<TopBannerModel>> getBanners() async* {
//     //DataSnapshot dataSnapshot = await _refDb.child("TopBanner").get();
//     Query query = _refDb.child("TopBanner");
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       notifyListeners();
//       yield data.values
//           .map((bannerValue) => TopBannerModel.fromJson(bannerValue))
//           .toList();
//     } else {
//       log("No Rows Found");
//     }
//   }
//
//   //get All Books
//
//   final StreamController<List<BookModel>> bookController =
//       StreamController<List<BookModel>>.broadcast();
//   Stream<List<BookModel>> get bookStream => bookController.stream;
//
//   final StreamController<List<BookModel>> allBookAgentController =
//       StreamController<List<BookModel>>.broadcast();
//   Stream<List<BookModel>> get allBookAgentStream => bookController.stream;
//
//   void getBooks({required String category, String? myBooks}) {
//     Query query = _refDb.child("Books/$category");
//
//     // Listen for changes in the database
//     query.onValue.listen((DatabaseEvent event) {
//       DataSnapshot dataSnapshot = event.snapshot;
//
//       if (dataSnapshot.value != null) {
//         Map data = dataSnapshot.value as Map;
//         List<BookModel> books = data.values
//             .map((bookValue) => BookModel.fromJson(bookValue))
//             .toList();
//         bookController.add(books);
//       } else {
//         log("No Rows Found");
//         bookController.add([]);
//       }
//     });
//     _refDb.keepSynced(true);
//   }
//
//   void getAllAgentBooks() async {
//     DataSnapshot snapshot = await _refDb.child("Books").get();
//     List<BookModel> allBooks = [];
//
//     if (snapshot.value != null) {
//       log("message snap is not null");
//       Map<String, dynamic> categories =
//           Map<String, dynamic>.from(snapshot.value as Map);
//
//       // Traverse each category and collect books in a single list
//       for (String categoryKey in categories.keys) {
//         Map<String, dynamic> booksInCategory =
//             Map<String, dynamic>.from(categories[categoryKey]);
//
//         // Convert each book in the category to BookModel and add to allBooks
//         allBooks.addAll(
//           booksInCategory.values.map((bookData) {
//             return BookModel.fromJson(Map<String, dynamic>.from(bookData));
//           }),
//         );
//       }
//
//       // Add the accumulated list of all books to the controller
//       allBookAgentController.add(allBooks);
//     } else {
//       log("No categories found.");
//       allBookAgentController.add([]);
//     }
//   }
//
//   Future<void> updateBookStatus({
//     required String category,
//     required String bookId,
//     required String status,
//   }) async {
//     _refDb.child("Books/$category/$bookId").update({
//       'status': status,
//     });
//     notifyListeners();
//   }
//
//   Stream<List<BookModel>> getTopBooks({required String category}) async* {
//     Query query = _refDb.child("Books/$category").limitToFirst(
//         10); // Assuming 'likes' is a field in your book data.limitToFirst(10); // Get the top 10 books with the most likes
//
//     // Fetch the data once and return it as a future
//     final DatabaseEvent event = await query.once();
//     DataSnapshot dataSnapshot = event.snapshot;
//
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       // Convert the Firebase data into a list of BookModel
//       List<BookModel> books = data.values
//           .map((bookValue) => BookModel.fromJson(bookValue))
//           .toList();
//       yield books;
//     } else {
//       log("No Rows Found");
//       yield [];
//     }
//   }
//
//   Stream<BookModel> getLinkBook(
//       {required String category, required String bookId}) async* {
//     Query query = _refDb.child("Books/$category/$bookId");
//
//     // Fetch the data once and return it as a future
//     final DatabaseEvent event = await query.once();
//     DataSnapshot dataSnapshot = event.snapshot;
//
//     if (dataSnapshot.value != null) {
//       // Convert the Firebase data to a BookModel instance
//       BookModel book = BookModel.fromJson(dataSnapshot.value as Map);
//       yield book;
//     } else {
//       log("No Book Found with ID: $bookId");
//     }
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     bookController.close();
//     userReqController.close();
//     usersController.close();
//   }
//   /*Stream<List<BookModel>> getBooks({required String category, String? myBooks}) async* {
//     // Use a more efficient query if possible
//     Query query = _refDb.child("Books/$category");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//       if (dataSnapshot.value != null) {
//         Map data = dataSnapshot.value as Map;
//          yield data.values.map((bookValue) => BookModel.fromJson(bookValue))
//             .toList();
//       } else {
//         log("No Rows Found");
//         yield [];
//       }
//   }*/
//
//   //for book category list
//   Stream<List<String>> getCategory(List<String> myCat) async* {
//     try {
//       Query query = _refDb.child("Categories");
//
//       DatabaseEvent databaseEvent = await query.once();
//       DataSnapshot dataSnapshot = databaseEvent.snapshot;
//
//       if (dataSnapshot.value != null) {
//         Map category = dataSnapshot.value as Map;
//         notifyListeners();
//         category.values.map((catValue) => myCat.add(catValue)).toList();
//         yield myCat;
//       } else {
//         log("No Rows Found");
//         yield [];
//       }
//     } catch (e) {
//       log(e.toString());
//     }
//   }
//
//   //For Home Page
//   Stream<List<MyCategories>> getCategories() async* {
//     Query query = _refDb.child("Categories");
//
//     DatabaseEvent databaseEvent = await query.once();
//     DataSnapshot dataSnapshot = databaseEvent.snapshot;
//
//     if (dataSnapshot.value != null) {
//       Map category = dataSnapshot.value as Map;
//       yield category.values
//           .map((catValue) => MyCategories.fromJson(catValue))
//           .toList();
//     } else {
//       log("No Rows Found");
//       yield [];
//     }
//   }
//
//   // searching
//
//   Future<List<BookModel>> getSearchAllBooks() async {
//     List<BookModel> allBooks = [];
//
//     // Get the categories (e.g., Islamic, Science, etc.)
//     DataSnapshot snapshot = await _refDb.child("Books").get();
//     Map<String, dynamic> categories =
//         Map<String, dynamic>.from(snapshot.value as Map);
//
//     // Traverse through each category and fetch books
//     for (String categoryKey in categories.keys) {
//       Map<String, dynamic> booksInCategory =
//           Map<String, dynamic>.from(categories[categoryKey]);
//
//       for (String bookId in booksInCategory.keys) {
//         // Get the book details from the bookId
//         Map<String, dynamic> bookData =
//             Map<String, dynamic>.from(booksInCategory[bookId]);
//
//         // Convert to BookModel and add to list
//         allBooks.add(BookModel.fromJson(bookData));
//       }
//     }
//     return allBooks;
//   }
//
//   //methods
//
//   //Update my profile
//   void updateMyUser({required String fullName, required String phone}) async {
//     final dbEvent =
//         _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//     dbEvent
//         .update({"name": fullName, "phone": int.parse(phone)}).whenComplete(() {
//       AuthServices().fireAuth.currentUser!.updateDisplayName(fullName);
//       notifyListeners();
//     });
//   }
//
//   //Update Lucky
//   void updateLucky({required int lucky}) async {
//     final dbEvent =
//         _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//     dbEvent.update({
//       "lucky": lucky,
//     });
//     notifyListeners();
//   }
//
//   //Update Lucky
//   void updateLuckyNumber({required int lucky}) async {
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({"lucky": lucky, "weekWin": false});
//     notifyListeners();
//   }
//
//   //Update Lucky
//   void updateLuckySwitch({required bool isOn}) async {
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({
//       "isOn": isOn,
//     });
//     notifyListeners();
//   }
//
//   //Update Lucky
//   void updateLuckyWeekWinner({required bool weekWinner}) async {
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({
//       "weekWin": weekWinner,
//     });
//     notifyListeners();
//   }
//
//   //Update Lucky win user!.
//   void updateLuckyWinUser({required String winUser}) async {
//     final dbEvent = _refDb.child("luckyUser");
//     dbEvent.update({
//       "winUser": winUser,
//     });
//     notifyListeners();
//   }
//
//   //likes
//   void likeActions(
//       {required bool isLiked,
//       required int likes,
//       required String category,
//       bookId,
//       uid,
//       name}) async {
//     final bookLike = _refDb.child('Books/$category/$bookId/likes/$uid');
//     final bookLikes = _refDb.child('Books/$category/$bookId');
//     try {
//       isLiked
//           ? await bookLike.remove()
//           : await bookLike.set({
//               'uid': uid,
//               'name': name,
//               'like': true,
//             }).whenComplete(() => notifyListeners());
//       isLiked
//           ? await bookLikes.update({'like': likes - 1})
//           : await bookLikes.update({'like': likes + 1}).whenComplete(
//               () => notifyListeners());
//       log("$isLiked, $likes, $category, $bookId, $uid, $name");
//     } catch (e) {
//       log("error");
//     }
//   }
//
//   //update Version
//   void updateAppVersions({
//     String? newVersion,
//     bool? updating,
//     bool? waiting,
//   }) {
//
//     if(newVersion != null && updating != null && waiting != null){
//       _refDb.child('$dbName/updates').update({
//         'version' : newVersion,
//         'updating' : updating,
//         'waiting' : waiting,
//       });
//     }else {
//       if (newVersion != null) {
//         _refDb.child('$dbName/updates').update({
//           'version': newVersion,
//         });
//       }
//       if (updating != null) {
//         _refDb.child('$dbName/updates').update({
//           'updating': updating,
//         });
//       }
//       if (waiting != null) {
//         _refDb.child('$dbName/updates').update({
//           'waiting': waiting,
//         });
//       }
//     }
//     notifyListeners();
//   }
//
//   //Rate
//   void ratingActions({
//     required bool isRated,
//     required int totalRates,
//     required double averageRate,
//     String? uid,
//     String? username,
//     required double rate,
//     String? category,
//     String? bookId,
//   }) async {
//     final bookUserRates = _refDb.child('Books/$category/$bookId/rates/$uid');
//     final bookTotalAvgRate = _refDb.child('Books/$category/$bookId');
//
//     try {
//       // Check if the user has already rated
//       if (!isRated) {
//         // Adding a new rate
//         totalRates += 1;
//         averageRate = ((averageRate * (totalRates - 1)) + rate) / totalRates;
//
//         // Ensure average does not exceed 5.0
//         averageRate = averageRate > 5.0 ? 5.0 : averageRate;
//
//         await bookUserRates.set({
//           'uid': uid,
//           'name': username,
//           'rate': "$rate",
//         });
//
//         // Update total rates and average rate
//         await bookTotalAvgRate.update({
//           'totalRates': "$totalRates",
//           'averageRate': "$averageRate",
//         });
//       } else {
//         // Updating an existing rate
//         DataSnapshot snapshot = await bookUserRates.get();
//         if (snapshot.exists) {
//           double oldRate =
//               double.parse(snapshot.child('rate').value.toString());
//           averageRate =
//               ((averageRate * totalRates) - oldRate + rate) / totalRates;
//
//           // Ensure average does not exceed 5.0
//           averageRate = averageRate > 5.0 ? 5.0 : averageRate;
//
//           await bookUserRates.update({
//             'rate': "$rate",
//           });
//
//           // Update average rate
//           await bookTotalAvgRate.update({
//             'averageRate': "$averageRate",
//           });
//         }
//       }
//       notifyListeners();
//     } catch (e) {
//       log("An error occurred: $e");
//       // Handle any additional error logging or recovery here if needed
//     }
//   }
//
//   /*
//   void ratingActions({
//     required bool isRated,
//     required int totalRates,
//     required double averageRate,
//     String? uid,
//     String? username,
//     required double rate,
//     String? category,
//     String? bookId,
//   }) async {
//     final bookUserRates = _refDb.child('Books/$category/$bookId/rates/$uid');
//     final bookTotalAvgRate = _refDb.child('Books/$category/$bookId');
//
//     // Check if the user has already rated
//     if (!isRated) {
//       // Adding a new rate
//       totalRates += 1;
//       averageRate = ((averageRate * (totalRates - 1)) + rate) / totalRates;
//
//       await bookUserRates.set({
//         'uid': uid,
//         'name': username,
//         'rate': "$rate",
//       });
//
//       // Update total rates and average rate
//       await bookTotalAvgRate.update({
//         'totalRates': "$totalRates",
//         'averageRate': "$averageRate",
//       });
//     } else {
//       // Updating an existing rate
//       DataSnapshot snapshot = await bookUserRates.get();
//       if (snapshot.exists) {
//         double oldRate = double.parse(snapshot.child('rate').value.toString());
//         averageRate =
//             ((averageRate * totalRates) - oldRate + rate) / totalRates;
//
//         await bookUserRates.update({
//           'rate': "$rate",
//         }).then((onValue) => notifyListeners());
//
//         // Update average rate
//         await bookTotalAvgRate.update({
//           'averageRate': "$averageRate",
//         }).then((onValue) => notifyListeners());
//       }
//     }
//   }
// */
//   //check user Role
//   Future<bool> checkUser() async {
//     bool isBanned = false;
//     if (AuthServices().fireAuth.currentUser != null) {
//       DataSnapshot dataSnapshot = await _refDb
//           .child('Users/${AuthServices().fireAuth.currentUser!.uid}')
//           .get();
//       if (dataSnapshot.value != null) {
//         final Map role = dataSnapshot.value as Map;
//         return isBanned = role['role'] == "Banned";
//       }
//     }
//     return isBanned;
//   }
//
//   Future<void> userPrevilage(userId, newValue) async {
//     _refDb.child('Users/$userId').update({
//       "role": newValue.toString(),
//     });
//   }
//
//   //Agents Operations:
//   Future<void> opMembers(userId, status) async {
//     final agent =
//         _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
//     final user = _refDb.child("Users");
//     agent.child(userId).update({"status": status});
//     user.child(userId).update({"uploader": status == "Active"});
//     notifyListeners();
//   }
//
//   Future<void> deleteMember(userId) async {
//     final agent =
//         _refDb.child("Agents/${AuthServices().fireAuth.currentUser!.uid}");
//     final user = _refDb.child("Users");
//     agent.child(userId).remove();
//     user.child(userId).update({"uploader": false});
//     notifyListeners();
//   }
//
//   //Request user uploader
//   Future<void> sendRequest(
//       {name, email, phone, ldrName, selectedAgent, isRequested}) async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final ref = _refDb.child("Agents/$selectedAgent/$uid");
//     ref.set({
//       "uid": uid,
//       "name": name,
//       "email": email,
//       "phone": phone,
//       "sub": selectedAgent,
//       "status": "Inactive",
//     }).whenComplete(() {
//       final ref = _refDb.child("Users/$uid");
//       ref.update({
//         'uprequest': true,
//       }).catchError((error) {});
//     }).whenComplete(() {
//       isRequested = true;
//       notifyListeners();
//     });
//   }
//
//   Future<void> getAgents({required menuItems}) async {
//     final ref = _refDb.child("Agents");
//     ref.onValue.listen((event) async {
//       if (event.snapshot.value != null) {
//         final leaders = event.snapshot.value as Map;
//         leaders.forEach((key, value) async {
//           final agent = await value as Map<dynamic, dynamic>;
//           if (agent['role'].toString() == 'Agent') {
//             menuItems
//                 .addAll({agent['uid'].toString(): agent['name'].toString()});
//             notifyListeners();
//           }
//         });
//       }
//     });
//   }
//
//   void addNewBanner({
//     required String title,
//     required String imgLink,
//     required bool status,
//     String? actionLink,
//   }) async {
//     _refDb.child("TopBanner").push().set({
//       "title": title,
//       "imgLink": imgLink,
//       "toGoLink": actionLink ?? "",
//       "status": status ? "on" : "off",
//     });
//   }
//
//   //Delete topBanner()
//
//   void deleteBanner(title) async {
//     DataSnapshot dataSnapshot = await _refDb.child("TopBanner").get();
//     if (dataSnapshot.value != null) {
//       Map data = dataSnapshot.value as Map;
//       log(data.toString());
//       data.forEach((key, value) {
//         if (value['title'] == title) {
//           log(key.toString());
//         }
//       });
//     } else {
//       log("No Rows Found");
//     }
//   }
//
//   //getAndUpdateWin
//   Future<void> checkAndUpdateLuckyDate() async {
//     final dbEvent =
//         _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
//     DateTime today = DateTime.now();
//     String todayStr = DateFormat('yyyy-MM-dd').format(today);
//     await dbEvent.update({"luckyDate": todayStr});
//     log("luckyDate updated to $todayStr");
//     notifyListeners();
//   }
// }
