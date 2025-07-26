import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/Services/get_database.dart';

class AuthServices extends ChangeNotifier {
  String? errorMsg;
  bool authGUser = false;
  final fireAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _db = FirebaseDatabase.instance.ref(dbName);

  bool _isGuest = false;

  bool get isGuest => _isGuest;

  void signInAsGuest() {
    _isGuest = true;
    notifyListeners();
  }

  void signOutGuest() {
    _isGuest = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await fireAuth.signInWithEmailAndPassword(
          email: email, password: password);
      fireAuth.authStateChanges();
      saveDeviceId();
      signOutGuest();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMsg = "error Name ${e.message.toString()}";
      log(e.message.toString());
      rethrow;
    } catch (e) {
      [];
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount;
      googleSignInAccount = await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      fireAuth.signInWithCredential(credential).whenComplete(() async {
        await saveGoogleUsers();
      });
      signOutGuest();
    } on FirebaseAuthException catch (e) {
      errorMsg = e.message ?? 'An unknown error occurred $e';
      log(errorMsg.toString());
    }
  }

  Future<void> signUp(UserModel? userModel, String password) async {
    try {
      await fireAuth.createUserWithEmailAndPassword(
          email: userModel!.email, password: password);
      fireAuth.authStateChanges();
      signOutGuest();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMsg = e.message.toString();
      log(e.message.toString());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
    saveUserData(userModel);
  }

  saveUserData(UserModel? userModel) async {
    _db.child("Users/${fireAuth.currentUser!.uid}").set(userModel?.toJson());
    _db
        .child("Users/${fireAuth.currentUser!.uid}")
        .update({"uid": fireAuth.currentUser!.uid});
    saveDeviceId();
    notifyListeners();
  }

  Future<void> saveGoogleUsers() async {
    try {
      // Retrieve user data from Firebase
      DataSnapshot dataSnapshot = await _db
          .child(
            'Users/${AuthServices().fireAuth.currentUser!.uid}/name',
          )
          .get();

      // Create the UserModel without parsing the phone number as an int
      UserModel userModel = UserModel(
        name: fireAuth.currentUser?.displayName ?? 'Unknown',
        email: fireAuth.currentUser?.email ?? 'Unknown',
        isVerify: fireAuth.currentUser?.emailVerified ?? false,
        role: "User",
        uid: fireAuth.currentUser!.uid,
      );

      // Ensure the DataSnapshot isn't null or empty
      if (!dataSnapshot.exists) {
        // Save the user data to the database only if it doesn't exist
        await _db.child("Users/${fireAuth.currentUser!.uid}").set(
              userModel.toJson(),
            );
        // Notify listeners if you're using state management
        notifyListeners();
      }
    } catch (e) {
      // Print the error if any exception occurs
      log("Error saving user data: $e");
    }
  }

  void saveDeviceId() async {
    if (fireAuth.currentUser?.uid != null) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        FirebaseDatabase.instance
            .ref("SBO/Users/${fireAuth.currentUser!.uid}")
            .update({
          'device': build.id.toString(),
        });
      }
    }
  }

  String _verificationId = "";
  String get verificationId => _verificationId;

  // Function to update user profile with phone number
  Future<void> updatePhoneNumber(String phoneNumber, String smsCode) async {
    try {
      await fireAuth.currentUser!
          .updatePhoneNumber(PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode:
            smsCode, // Dummy values because the phone number is already verified
      ));
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      rethrow;
    }
  }

  int timeLeft = 120;
  bool reSend = false;
  bool _isVerified = false;
  Timer? _timer;

  void _startTime() async {
    timeLeft = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (timeLeft > 0) {
        timeLeft--;
        notifyListeners();
      } else {
        t.cancel(); // Cancel the timer when time is up
        notifyListeners();
      }
    });
  }

  //Verify Email
  Future<void> verify() async {
    try {
      if (!fireAuth.currentUser!.emailVerified) {
        await fireAuth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      log("${e.message}");
    }
  }

  Future sendVerification() async {
    final delayTime = Future.delayed(const Duration(seconds: 120));
    try {
      reSend = false;
      verify();
      _startTime();
      await delayTime;
      reSend = true;
      log(reSend.toString());
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
    }
  }

  Future<void> checkEmailVerify() async {
    fireAuth.currentUser!.reload();
    fireAuth.authStateChanges();
    _isVerified = fireAuth.currentUser!.emailVerified;
    if (_isVerified) _timer?.cancel();
    notifyListeners();
  }

  //End Verify

  Future<void> getVerify() async {
    try {
      _db
          .child("Users/${AuthServices().fireAuth.currentUser!.uid}/isVerify")
          .get()
          .then((snapshot) {
        if (snapshot.value == null || snapshot.value != true) {
          _db
              .child("Users/${AuthServices().fireAuth.currentUser!.uid}")
              .update({
            "isVerify": AuthServices().fireAuth.currentUser!.emailVerified,
          });
        }
      });
    } catch (e) {
      log("$e");
    }
  }

  Future<void> deleteUser() async {
    _db.child("Users/${AuthServices().fireAuth.currentUser!.uid}").remove();
    fireAuth.currentUser!.delete();
    fireAuth.signOut();
    notifyListeners();
  }

  Future<void> forgetPsd(email) async {
    fireAuth.sendPasswordResetEmail(email: email);
    notifyListeners();
  }

  Future<void> singOut() async {
    await _googleSignIn.signOut();
    await fireAuth.signOut();
    notifyListeners();
  }

  //phone

  Future<void> linkPhoneNumber(String verificationId, String smsCode) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    // Create a PhoneAuthCredential with the verificationId and the SMS code.
    PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );

    // Link the phone number to the current user.
    log(phoneCredential.toString());
    try {
      await user?.linkWithCredential(phoneCredential);
      log("Phone number linked successfully.");
      notifyListeners();
    } catch (e) {
      log("Failed to link phone number: $e");
    }
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    _verificationId = verificationId;
    log("Sent Code with this phone");
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        fireAuth.currentUser!.linkWithPhoneNumber(phoneNumber);
      },
      verificationFailed: (FirebaseAuthException e) {
        log(e.message.toString());
      },
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        log("Verification code timeout.");
      },
    );
  }
  /*Future<void> verifyPhoneNumber(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This is called when verification is completed automatically.
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle the error
        log(e.message.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationId = _verificationId;
        log("Code sent to $phoneNumber");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log("Verification code timeout.");
      },
    );
  }*/
}
