import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:backdrop/backdrop.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/awesome_snackbar.dart';
import 'package:sboapp/components/home_row_list.dart';
import 'package:sboapp/components/net_check.dart';
import 'package:sboapp/components/top_slider.dart';
import 'package:sboapp/components/loading_widget.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/check_subs.dart';
import 'package:sboapp/constants/expiration_date.dart';
import 'package:sboapp/constants/settings_card.dart';
import 'package:sboapp/constants/social_icons.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/constants/updating_app.dart';
import 'package:sboapp/screens/books/view_share_book.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/book_searching.dart';
import 'package:sboapp/services/fire_push_notify.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../services/notify_hold_service.dart';
import '../../welcome_screen/land_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  //Notifies
  bool newNotify = false;
  String constProfile =
      "https://firebasestorage.googleapis.com/v0/b/sboapp-2a2be.appspot.com/o/profile_images%2FuserProfile%5B1%5D.png?alt=media&token=234392a7-3cf7-47cd-a8ee-f375944718c1";
  //int _bottomNavIndex = 0;

  Future _updateDot() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('read', true);
  }

  checkDot() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool? isRead = sp.getBool('read');
    if (isRead != null) {
      setState(() => newNotify = !isRead);
    }
  }

  //*/
  //Ended

  //deep link

  void _initDynamicLinks() async {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // Extract category and bookId from the deep link URL
        List<String> pathSegments = uri.pathSegments;

        if (pathSegments.length >= 2) {
          String category = pathSegments[0]; // e.g., "history"
          String bookId =
              pathSegments[1]; // e.g., "9187d2c0-c824-1089-a3f1-a3bd607cedf7"
          BookShareInfoView(category: category, bookId: bookId);
        }
      }
    }, onError: (err) {
      log('Error handling uni link: $err');
    });
  }
  //testing remove Ads

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _available = false;
  bool _isSubscribed = false;
  List<ProductDetails>? _products;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  int _selected = 1;

  void _fetchSubscriptions() async {
    // ignore: no_leading_underscores_for_local_identifiers
    const Set<String> _kIds = {
      'removeads',
      'removeads6m',
    };
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(_kIds);

    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error here
    }

    setState(() {
      _products = response.productDetails;
    });
  }

  Future<void> _initialize() async {
    _available = await _inAppPurchase.isAvailable();
    if (_available) {
      _fetchSubscriptions();
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.productID == 'removeads' ||
          purchaseDetails.productID == 'removeadsfor6m') {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          setState(() async {

            _isSubscribed = true;
            GetDatabase().updateSubscribedUser(
                subname: "Monthly",
                inSubscribed: _isSubscribed,
                expiredDate: purchaseDetails.productID == 'removeads'
                    ? getExpirationDate(months: 1)
                    : getExpirationDate(months: 6));
          });
        }
      }
    }
  }

  void _buySubscription(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
    PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // ignore: unused_element
  void _showPurchaseDialog(ProductDetails product, message, providerLocale) {
    if (_products == null || _products!.isEmpty) return;
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(providerLocale.bodyRemoveAd),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text(providerLocale.bodyCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _buySubscription(product); // Initiate the purchase
              },
              child: Text(
                  '${providerLocale.bodyPay} ${product.price}/${providerLocale.bodyBody}'),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseOptionsDialog(providerLocale) {
    log(_products!.length.toString());
    if (_products == null || _products!.isEmpty) return;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                titleText(
                  text: providerLocale.bodyRemoveAd,
                ),
                const Divider(
                  thickness: 3,
                ),
                const SizedBox(height: 10),
                RadioListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        bodyText(text: providerLocale.bodyMonth),
                        bodyText(text: _products![0].price.toString()),
                      ],
                    ),
                    value: 0,
                    groupValue: _selected,
                    onChanged: (value) {
                      setState(() {
                        _selected = value!;
                      });
                    }),
                RadioListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        bodyText(text: "6 ${providerLocale.bodyMonths}"),
                        bodyText(text: _products![1].price.toString()),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        bodyText(text: providerLocale.bodyMostPp),
                        bodyText(
                            text:
                            "${_products![1].currencySymbol}${(_products![1].rawPrice / 6).toStringAsFixed(1)}/${providerLocale.bodyMonth}"),
                      ],
                    ),
                    value: 1,
                    groupValue: _selected,
                    onChanged: (value) {
                      setState(() {
                        _selected = value!;
                      });
                    }),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: materialButton(
                    onPressed: () {
                      _buySubscription(_products![_selected]);
                      Navigator.of(context);
                    },
                    text: 'Purchase',
                  ),
                ),
                customText(
                    text: providerLocale.bodyPurchaseNote, fontSize: 10,
                  maxLines: 10,
                  fontFamily: firaSansL,
                  textAlign: TextAlign.center
                ),
              ],
            ),
          ),
        ));
  }

  /*
    void _showPurchaseOptionsDialog() {
    if (_products == null || _products!.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.remove_circle, color: Colors.red), // Icon for "Remove Ads"
              SizedBox(width: 10),
              Text('Remove Ads'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/removeAds.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ), // Replace with your image
              SizedBox(height: 20),
              Text('Choose a subscription to remove ads:'),
            ],
          ),
          actions: _products!.map((product) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _buySubscription(product); // Initiate the purchase for the selected product
              },
              child: Text('Pay ${product.price} for ${product.title}'),
            );
          }).toList(),
        );
      },
    );
  }*/

  //end test

  String? appVersion;
  void getDeviceAndVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
    log(packageInfo.version);
  }

  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        updateApp();
        /*showDialog(context: context, builder: (context)=> PopScope(
          canPop: false,
            child: AlertDialog(
          title: titleText(text: "New Update"),
          content: bodyText(text: "New update released and added new features or fixed bugs."),
          actions: [TextButton(onPressed: updateApp, child: buttonText(text: "Update Now"))],
        )));*/
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void updateApp() async {
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((value) {}).catchError((e) {});
  }

  void checkUser() async {
    var isBanned = Provider.of<GetDatabase>(context, listen: false).checkUser();
    if (await isBanned) {
      bannedAlert(context: context);
    }
  }

  void requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      // If the in-app review is not available, you can redirect the user to the app store.
      inAppReview.openStoreListing(
        appStoreId: 'com.dsd.sboapp',
      );
    }
  }

  Future shareApp(providerLocale) async {
    String appLink =
        'https://play.google.com/store/apps/details?id=com.dsd.sboapp'; // Replace with your app's link
    await Share.share(
        '${providerLocale.bodyShareAppLink} $appLink'); //(appLink);
  }

  void checkUserDevice(String userDevice) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      bool isYou = userDevice != build.id;
      if (isYou) {
        showDialog(
            context: context,
            builder: (context) => PopScope(
                  canPop: false,
                  child: AlertDialog(
                    title: titleText(text: "Session Expired"),
                    content: bodyText(
                        text:
                            "Your account was signed another device please check it and sign in again"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Provider.of<AuthServices>(context, listen: false)
                                .singOut();
                            Navigator.pop(context);
                          },
                          child: buttonText(text: "ok"))
                    ],
                  ),
                ));
      }
    }
  }

  void allowNotification() async{
    final firebaseMessaging = FirebaseMessaging.instance;
    final requestPermission = await firebaseMessaging.requestPermission();
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //log('User granted permission');
      final token = await firebaseMessaging.getToken();
      NotificationProvider().updateToken(token);
    } else {
      if (settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        requestPermission;
      }
    }
  }

  void initActions() {
    allowNotification();
    checkDot();
    _subscription = _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {});
  }
  bool waiting = false;
  checkUpdating(){
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference
        .child('$dbName/updates/waiting')
        .onValue
        .listen((onData) {
          setState(() => waiting = bool.parse(onData.snapshot.value.toString()));
    });
    if(waiting){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const UpdatingApp()));
    }
  }

  String? currentVersion;
  bool updating = false;
  String newVersion = "";
  bool isUpdated = true;
  Future<void> getCheckUpdating() async {
    // Fetch current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    // Listen for updates
    databaseReference.child('$dbName/updates').once().then((snapshot) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        updating = data['updating'] ?? false;
        newVersion = data['version'] ?? "";
      });
      // Compare versions and show alert
      if (updating) {
        if(int.parse(currentVersion!.replaceAll('.', '').toString()) < int.parse(newVersion.replaceAll('.', '').toString())) {
          checkUpdating();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
    getDeviceAndVersion();
    checkForUpdate();
    _initDynamicLinks();
    getCheckUpdating();

    //ended

    //disabled screenshot
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Platform.isAndroid) {
        //await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    });*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkDot();
  }

  @override
  Widget build(BuildContext context) {
    initActions();
    Provider.of<GetDatabase>(context, listen: true).loadIsRead();
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: false)
            .localizations;

    return Directionality(
      textDirection: providerLocale.language == "العربية"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: BackdropScaffold(
        backLayerBackgroundColor: Theme.of(context).colorScheme.primary,
        subHeaderAlwaysActive: false,
        appBar: BackdropAppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: titleText(
              text: providerLocale.appBarHome,
              fontSize: 20,
              color: Colors.white),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: Provider.of<GetDatabase>(context, listen: false).subscriber
                  ? null
                  : () => _showPurchaseOptionsDialog(providerLocale),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: providerLocale.language == "العربية"
                      ? const EdgeInsets.only(left: 4.0)
                      : const EdgeInsets.only(right: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Provider.of<GetDatabase>(context, listen: false)
                              .subscriber
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                      buttonText(text: "Ads", color: Colors.black)
                    ],
                  ),
                ),
              ),
            ), //Image.asset("assets/images/ads.png", height: MediaQuery.of(context).size.height * 0.035)),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/notifyList');
                _updateDot();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Badge(
                    isLabelVisible: newNotify,
                    smallSize: 10,
                    alignment: Alignment.topRight,
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    )),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  // Trigger the search delegate manually if the user presses the search icon
                  final books =
                      await Provider.of<GetDatabase>(context, listen: false)
                          .getSearchAllBooks();
                  showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(listOfBooks: books),
                  );
                },
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                )),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            )
          ],
        ),
        /*subHeader: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NetworkCheckPage(),
            Padding(
              padding: EdgeInsets.only(
                top: 8.0,
              ),
              child: TopSliders(),
            ),
          ],
        ),*/
        backLayer: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<UserModel>(
                    stream: GetDatabase().getMyUser(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, "/profile"),
                            child: const ProfileShimmer());
                      }
                      if (snapshot.hasError) {
                        final isGuest = Provider.of<AuthServices>(context).isGuest;
                        if(isGuest){
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Guest User'),
                              subtitle: const Text('Sign in or sign up to access full features.'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const OnboardingView()),
                                );
                              },
                            ),
                          );
                      }
                          return const Center(child: Text("not Found"));
                      }
                      if (snapshot.hasData) {
                        // ignore: unused_local_variable
                        bool ownerRole = snapshot.data!.role == "Owner";
                        bool generalRole = snapshot.data!.role == "Owner" ||
                            snapshot.data!.role == "Admin" ||
                            snapshot.data!.role == "Agent";
                        bool ownerAdmin = snapshot.data!.role == "Owner" ||
                            snapshot.data!.role == "Admin";
                        // ignore: unused_local_variable
                        bool adminAgent = snapshot.data!.role == "Admin" ||
                            snapshot.data!.role == "Agent";
                        // ignore: unused_local_variable
                        bool userRole = snapshot.data!.role == "User";
                        checkUserDevice(snapshot.data!.device!);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Material(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, "/profile");
                                        },
                                        leading: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                // Glowing shadow effect
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(
                                                          0.4), // Glow color
                                                  spreadRadius: 2,
                                                  blurRadius: 1,
                                                ),
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(
                                                          0.2), // Additional layers of glow
                                                  spreadRadius: 4,
                                                  blurRadius: 2,
                                                ),
                                              ]

                                              /*border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface, // Set the color of the border
                                            width:
                                                2.0, // Adjust the width of the border
                                          ),*/
                                              ),
                                          child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: ImageNetCache(
                                                    imageUrl: snapshot
                                                            .data!.profile ??
                                                        constProfile),
                                              )),
                                        ),
                                        title:
                                            bodyText(text: snapshot.data!.name),
                                        subtitle: lSubTitleText(
                                            text: snapshot.data!.email),
                                        trailing: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            child: subChecker(
                                                snapSubName: snapshot.data!
                                                    .subscription?.subname,
                                                snapSubActive: snapshot.data!
                                                    .subscription?.subscribe))),
                                  ),
                                ),
                                CardSettings(
                                  leading: generalRole
                                      ? const Icon(CupertinoIcons.book_fill)
                                      : const Icon(Icons.local_library),
                                  title: generalRole
                                      ? bodyText(text: providerLocale.bodyBooks)
                                      : bodyText(
                                          text:
                                              providerLocale.bodyFavAnPaidBook),
                                  subTitle: generalRole
                                      ? lSubTitleText(
                                          text: providerLocale.bodyBookSubTitle)
                                      : null,
                                  onTap: () {
                                    generalRole
                                        ? Navigator.pushNamed(context, "/book",
                                            arguments: [
                                                snapshot.data!.role,
                                                snapshot.data!.uploader
                                              ])
                                        : Navigator.pushNamed(
                                            context, "/favBook");
                                  },
                                ),
                                /*Visibility(
                                    visible: userRole,
                                  child: CardSettings(
                                    leading: Image.asset("assets/images/requestAgent.png",color: Theme.of(context).colorScheme.onSurface, scale: 1.3),
                                    title: bodyText(text: "Request Book Uploader"),
                                    onTap: () {
                                      Navigator.pushNamed(context, "/reqUpBook");
                                    },
                                  ),
                                ),*/
                                Visibility(
                                  visible:
                                      generalRole, //snapshot.data!.role == "Admin" || snapshot.data!.role == "Agent" || snapshot.data!.role == "Owner",
                                  child: CardSettings(
                                    leading:
                                        const Icon(CupertinoIcons.person_2_alt),
                                    title: bodyText(
                                        text: providerLocale.bodyUsers),
                                    subTitle: lSubTitleText(
                                        text: providerLocale.bodyUserSubTitle),
                                    onTap: () {
                                      Navigator.pushNamed(context, "/users",
                                          arguments: [snapshot.data!.role]);
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      ownerAdmin, //snapshot.data!.role == "Admin" || snapshot.data!.role == "Owner",
                                  child: CardSettings(
                                    leading:
                                        const Icon(CupertinoIcons.bell_solid),
                                    title: bodyText(
                                        text: providerLocale.bodyNotify),
                                    subTitle: lSubTitleText(
                                        text:
                                            providerLocale.bodyNotifySubTitle),
                                    onTap: () {
                                      Navigator.pushNamed(context, "/notify");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                                child: ListTile(
                              leading: const CircleAvatar(
                                  child: Icon(
                                Icons.person,
                              )),
                              title: bodyText(
                                  text: providerLocale.bodyUserNotFound),
                              trailing: IconButton(
                                  onPressed: () => setState(() {}),
                                  icon: const Icon(Icons.refresh)),
                            )));
                      }
                    },
                  ),
                  CardSettings(
                      leading: const Icon(Icons.offline_pin_sharp),
                      title: bodyText(text: "Offline Books"),
                      onTap: () {
                        Navigator.pushNamed(context, "/offline");
                      }),
                  CardSettings(
                      leading: const Icon(CupertinoIcons.gift_fill),
                      title: bodyText(text: providerLocale.bodyWinWeek),
                      onTap: () {
                        Navigator.pushNamed(context, "/winGift");
                      }),
                  /*CardSettings(
                    leading: const Icon(Icons.support),
                    title: bodyText(text: providerLocale.bodyRateUs),
                    onTap: () =>  _showPurchaseDialog(_products![2], "Support Us ${_products![2].price}"),
                  ),*/
                  CardSettings(
                    leading: const Icon(CupertinoIcons.star_fill),
                    title: bodyText(text: providerLocale.bodyRateUs),
                    onTap: requestReview,
                  ),
                  CardSettings(
                    leading: const Icon(CupertinoIcons.info),
                    title: bodyText(text: "About us"),
                    onTap: () => Navigator.pushNamed(context,"/aboutUs"),
                  ),
                  CardSettings(
                    leading: const Icon(CupertinoIcons.share),
                    title: bodyText(text: providerLocale.bodyShareApp),
                    onTap: () => shareApp(providerLocale),
                  ),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: customText(
                            text: "${providerLocale.bodyVersion} $appVersion",
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SocialMediaRow(),
                ],
              ),
            ),
          ),
        ),
        frontLayer: Column(
          children: [
            const NetworkCheckPage(),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: consumerWidget(providerLocale),
            )),
          ],
        ),
      ),
    );
  }

  Widget consumerWidget(providerLocale) {
    return Consumer<GetDatabase>(
      builder: (BuildContext context, GetDatabase value, Widget? child) {
        final provider = context.read<GetDatabase>();
        return StreamBuilder<List<MyCategories>?>(
          stream: provider.getCategories(),
          builder: (BuildContext context,
              AsyncSnapshot<List<MyCategories>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const HomeShimmer();
            }
            if (snapshot.hasData) {
              return ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: CustomScrollView(slivers: [
                  SliverAppBar(
                    pinned:
                        false, // The AppBar will scroll away when you scroll up
                    floating: true,
                    snap: true,
                    collapsedHeight: MediaQuery.of(context).size.height * 0.15,
                    expandedHeight: MediaQuery.of(context).size.height * 0.145,
                    flexibleSpace: const TopSliders(),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    childCount: snapshot.data!.length,
                    (BuildContext context, int index) {
                      return HomeRowsList(
                        bookCategory: snapshot.data![index].category,
                        lanCategory: providerLocale.language == "العربية"
                            ? snapshot.data![index].arcategory
                            : snapshot.data![index].category,
                        onTap: () => Navigator.pushNamed(context, "/booksPage",
                            arguments: {
                              'lanCategory':
                                  providerLocale.language == "العربية"
                                      ? snapshot.data![index].arcategory
                                      : snapshot.data![index].category,
                              'category': snapshot.data![index].category,
                            }),
                      );
                    },
                  )),
                ]),
              );
            } else {
              return const Center(child: Text("No Data"));
            }
          },
        );
      },
    );
  }
}
