// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: 'Selected Language',
      args: [],
    );
  }

  /// `Language`
  String get changeLanguage {
    return Intl.message(
      'Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `SBO App`
  String get appBarHome {
    return Intl.message(
      'SBO App',
      name: 'appBarHome',
      desc: '',
      args: [],
    );
  }

  /// `Upload Book`
  String get appBarUpload {
    return Intl.message(
      'Upload Book',
      name: 'appBarUpload',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get appBarProfile {
    return Intl.message(
      'Profile',
      name: 'appBarProfile',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get appBarNotification {
    return Intl.message(
      'Notifications',
      name: 'appBarNotification',
      desc: '',
      args: [],
    );
  }

  /// `Manage books`
  String get appBarManage {
    return Intl.message(
      'Manage books',
      name: 'appBarManage',
      desc: '',
      args: [],
    );
  }

  /// `Pay Book`
  String get appBarPayBook {
    return Intl.message(
      'Pay Book',
      name: 'appBarPayBook',
      desc: '',
      args: [],
    );
  }

  /// `Request Upload Book`
  String get appBarRequest {
    return Intl.message(
      'Request Upload Book',
      name: 'appBarRequest',
      desc: '',
      args: [],
    );
  }

  /// `Help Center`
  String get appBarSupport {
    return Intl.message(
      'Help Center',
      name: 'appBarSupport',
      desc: '',
      args: [],
    );
  }

  /// `Manage Users`
  String get appBarManageUsers {
    return Intl.message(
      'Manage Users',
      name: 'appBarManageUsers',
      desc: '',
      args: [],
    );
  }

  /// `Requests Users`
  String get appBarRequestUsers {
    return Intl.message(
      'Requests Users',
      name: 'appBarRequestUsers',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get appBarRequestUsersHis {
    return Intl.message(
      'History',
      name: 'appBarRequestUsersHis',
      desc: '',
      args: [],
    );
  }

  /// `Crop Image`
  String get appBarCropImg {
    return Intl.message(
      'Crop Image',
      name: 'appBarCropImg',
      desc: '',
      args: [],
    );
  }

  /// `Add category`
  String get appBarAddCategory {
    return Intl.message(
      'Add category',
      name: 'appBarAddCategory',
      desc: '',
      args: [],
    );
  }

  /// `Update Notifications`
  String get appBarUpdateNotify {
    return Intl.message(
      'Update Notifications',
      name: 'appBarUpdateNotify',
      desc: '',
      args: [],
    );
  }

  /// `Manage Headers`
  String get appBarManageHeader {
    return Intl.message(
      'Manage Headers',
      name: 'appBarManageHeader',
      desc: '',
      args: [],
    );
  }

  /// `Win Weakly Gift`
  String get appBarWinWeek {
    return Intl.message(
      'Win Weakly Gift',
      name: 'appBarWinWeek',
      desc: '',
      args: [],
    );
  }

  /// `Edit Book`
  String get appBarEditBook {
    return Intl.message(
      'Edit Book',
      name: 'appBarEditBook',
      desc: '',
      args: [],
    );
  }

  /// `Waiting...`
  String get bodyWait {
    return Intl.message(
      'Waiting...',
      name: 'bodyWait',
      desc: '',
      args: [],
    );
  }

  /// `Subscribed`
  String get bodysubscribed {
    return Intl.message(
      'Subscribed',
      name: 'bodysubscribed',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up and join us`
  String get bodySignUpNow {
    return Intl.message(
      'Sign Up and join us',
      name: 'bodySignUpNow',
      desc: '',
      args: [],
    );
  }

  /// `Verify Email`
  String get bodyVerifyEmail {
    return Intl.message(
      'Verify Email',
      name: 'bodyVerifyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Verify Number`
  String get bodyVerifyNum {
    return Intl.message(
      'Verify Number',
      name: 'bodyVerifyNum',
      desc: '',
      args: [],
    );
  }

  /// `Paid`
  String get bodyPaid {
    return Intl.message(
      'Paid',
      name: 'bodyPaid',
      desc: '',
      args: [],
    );
  }

  /// `Free`
  String get bodyFree {
    return Intl.message(
      'Free',
      name: 'bodyFree',
      desc: '',
      args: [],
    );
  }

  /// `Select Image`
  String get bodySelectImage {
    return Intl.message(
      'Select Image',
      name: 'bodySelectImage',
      desc: '',
      args: [],
    );
  }

  /// `Select PDF`
  String get bodySelectPDF {
    return Intl.message(
      'Select PDF',
      name: 'bodySelectPDF',
      desc: '',
      args: [],
    );
  }

  /// `Note: Book fee is $`
  String get bodyNoteBBooFeeText {
    return Intl.message(
      'Note: Book fee is \$',
      name: 'bodyNoteBBooFeeText',
      desc: '',
      args: [],
    );
  }

  /// `books will be published after you paid.`
  String get bodyNoteBookPublishText {
    return Intl.message(
      'books will be published after you paid.',
      name: 'bodyNoteBookPublishText',
      desc: '',
      args: [],
    );
  }

  /// `Pay fee`
  String get bodyPayFee {
    return Intl.message(
      'Pay fee',
      name: 'bodyPayFee',
      desc: '',
      args: [],
    );
  }

  /// `Book Price`
  String get bodyLblBookPrice {
    return Intl.message(
      'Book Price',
      name: 'bodyLblBookPrice',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get bodyAddCategory {
    return Intl.message(
      'Add Category',
      name: 'bodyAddCategory',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get bodyLblCategory {
    return Intl.message(
      'Category',
      name: 'bodyLblCategory',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get bodyAdd {
    return Intl.message(
      'Add',
      name: 'bodyAdd',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get bodyUpdate {
    return Intl.message(
      'Update',
      name: 'bodyUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Somali`
  String get bodySomali {
    return Intl.message(
      'Somali',
      name: 'bodySomali',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get bodyArabic {
    return Intl.message(
      'Arabic',
      name: 'bodyArabic',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get bodyEnglish {
    return Intl.message(
      'English',
      name: 'bodyEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get bodySkip {
    return Intl.message(
      'Skip',
      name: 'bodySkip',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get bodyGetStart {
    return Intl.message(
      'Get Started',
      name: 'bodyGetStart',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon...`
  String get bodyComingSoon {
    return Intl.message(
      'Coming soon...',
      name: 'bodyComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Translated by`
  String get bodyTranslated {
    return Intl.message(
      'Translated by',
      name: 'bodyTranslated',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get bodySelectLang {
    return Intl.message(
      'Select Language',
      name: 'bodySelectLang',
      desc: '',
      args: [],
    );
  }

  /// `Favorite`
  String get bodyFavorite {
    return Intl.message(
      'Favorite',
      name: 'bodyFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Sold`
  String get bodySold {
    return Intl.message(
      'Sold',
      name: 'bodySold',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get bodyOk {
    return Intl.message(
      'Ok',
      name: 'bodyOk',
      desc: '',
      args: [],
    );
  }

  /// `New Book Added`
  String get bodyNewBooAdded {
    return Intl.message(
      'New Book Added',
      name: 'bodyNewBooAdded',
      desc: '',
      args: [],
    );
  }

  /// `Read Now`
  String get bodyReadNow {
    return Intl.message(
      'Read Now',
      name: 'bodyReadNow',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get bodyDone {
    return Intl.message(
      'Done',
      name: 'bodyDone',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get bodyAll {
    return Intl.message(
      'All',
      name: 'bodyAll',
      desc: '',
      args: [],
    );
  }

  /// `Add book`
  String get bodyAddBook {
    return Intl.message(
      'Add book',
      name: 'bodyAddBook',
      desc: '',
      args: [],
    );
  }

  /// `Books`
  String get bodyBooks {
    return Intl.message(
      'Books',
      name: 'bodyBooks',
      desc: '',
      args: [],
    );
  }

  /// `Request Upload Book`
  String get bodyRequestUploadBook {
    return Intl.message(
      'Request Upload Book',
      name: 'bodyRequestUploadBook',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get bodyUsers {
    return Intl.message(
      'Users',
      name: 'bodyUsers',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get bodyNotify {
    return Intl.message(
      'Notifications',
      name: 'bodyNotify',
      desc: '',
      args: [],
    );
  }

  /// `Update book fee`
  String get bodyUpdateBooFee {
    return Intl.message(
      'Update book fee',
      name: 'bodyUpdateBooFee',
      desc: '',
      args: [],
    );
  }

  /// `Update Price`
  String get bodyUpdatePrice {
    return Intl.message(
      'Update Price',
      name: 'bodyUpdatePrice',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get bodyPrice {
    return Intl.message(
      'Price',
      name: 'bodyPrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter new price`
  String get bodyEnterNewPrice {
    return Intl.message(
      'Enter new price',
      name: 'bodyEnterNewPrice',
      desc: '',
      args: [],
    );
  }

  /// `Account number`
  String get bodyAccountNum {
    return Intl.message(
      'Account number',
      name: 'bodyAccountNum',
      desc: '',
      args: [],
    );
  }

  /// `Current Acc`
  String get bodyCurrentAcc {
    return Intl.message(
      'Current Acc',
      name: 'bodyCurrentAcc',
      desc: '',
      args: [],
    );
  }

  /// `User requests`
  String get bodyUserRequest {
    return Intl.message(
      'User requests',
      name: 'bodyUserRequest',
      desc: '',
      args: [],
    );
  }

  /// `Feedback and Help`
  String get bodyFeedbackAndHelp {
    return Intl.message(
      'Feedback and Help',
      name: 'bodyFeedbackAndHelp',
      desc: '',
      args: [],
    );
  }

  /// `Rate App`
  String get bodyRateUs {
    return Intl.message(
      'Rate App',
      name: 'bodyRateUs',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get bodySettings {
    return Intl.message(
      'Settings',
      name: 'bodySettings',
      desc: '',
      args: [],
    );
  }

  /// `Share App`
  String get bodyShareApp {
    return Intl.message(
      'Share App',
      name: 'bodyShareApp',
      desc: '',
      args: [],
    );
  }

  /// `Sing Out`
  String get bodySingOut {
    return Intl.message(
      'Sing Out',
      name: 'bodySingOut',
      desc: '',
      args: [],
    );
  }

  /// `My library`
  String get bodyFavAnPaidBook {
    return Intl.message(
      'My library',
      name: 'bodyFavAnPaidBook',
      desc: '',
      args: [],
    );
  }

  /// `Favorite books`
  String get bodyFavBook {
    return Intl.message(
      'Favorite books',
      name: 'bodyFavBook',
      desc: '',
      args: [],
    );
  }

  /// `Paid books`
  String get bodyPaidBook {
    return Intl.message(
      'Paid books',
      name: 'bodyPaidBook',
      desc: '',
      args: [],
    );
  }

  /// `Manage books`
  String get bodyManage {
    return Intl.message(
      'Manage books',
      name: 'bodyManage',
      desc: '',
      args: [],
    );
  }

  /// `Change Theme`
  String get bodyChangeTheme {
    return Intl.message(
      'Change Theme',
      name: 'bodyChangeTheme',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get bodyVersion {
    return Intl.message(
      'Version',
      name: 'bodyVersion',
      desc: '',
      args: [],
    );
  }

  /// `Book Cover Picture`
  String get bodyBookCoverPicture {
    return Intl.message(
      'Book Cover Picture',
      name: 'bodyBookCoverPicture',
      desc: '',
      args: [],
    );
  }

  /// `Change image`
  String get bodyBookChangeImage {
    return Intl.message(
      'Change image',
      name: 'bodyBookChangeImage',
      desc: '',
      args: [],
    );
  }

  /// `Change PDF`
  String get bodyBookChangePDF {
    return Intl.message(
      'Change PDF',
      name: 'bodyBookChangePDF',
      desc: '',
      args: [],
    );
  }

  /// `Select book Pdf`
  String get bodyBookSelectBookPdf {
    return Intl.message(
      'Select book Pdf',
      name: 'bodyBookSelectBookPdf',
      desc: '',
      args: [],
    );
  }

  /// `Select one of them`
  String get bodyBookSelectOneOfThem {
    return Intl.message(
      'Select one of them',
      name: 'bodyBookSelectOneOfThem',
      desc: '',
      args: [],
    );
  }

  /// `if occurred mistake please contact us on number: `
  String get bodyBookFeeUserErrorCont {
    return Intl.message(
      'if occurred mistake please contact us on number: ',
      name: 'bodyBookFeeUserErrorCont',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get bodyBookSave {
    return Intl.message(
      'Save',
      name: 'bodyBookSave',
      desc: '',
      args: [],
    );
  }

  /// `Book Price Info`
  String get bodyBooBooPrInfo {
    return Intl.message(
      'Book Price Info',
      name: 'bodyBooBooPrInfo',
      desc: '',
      args: [],
    );
  }

  /// `Name:`
  String get bodyBookName {
    return Intl.message(
      'Name:',
      name: 'bodyBookName',
      desc: '',
      args: [],
    );
  }

  /// `ID:`
  String get bodyBookID {
    return Intl.message(
      'ID:',
      name: 'bodyBookID',
      desc: '',
      args: [],
    );
  }

  /// `Price:`
  String get bodyBookPrice {
    return Intl.message(
      'Price:',
      name: 'bodyBookPrice',
      desc: '',
      args: [],
    );
  }

  /// `Start process`
  String get bodyBookStartProcess {
    return Intl.message(
      'Start process',
      name: 'bodyBookStartProcess',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bodyBookCancel {
    return Intl.message(
      'Cancel',
      name: 'bodyBookCancel',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us on`
  String get bodyBookContactUs {
    return Intl.message(
      'Contact Us on',
      name: 'bodyBookContactUs',
      desc: '',
      args: [],
    );
  }

  /// `WhatsApp`
  String get bodyBookWhat {
    return Intl.message(
      'WhatsApp',
      name: 'bodyBookWhat',
      desc: '',
      args: [],
    );
  }

  /// `Send us your tr. Id and you name`
  String get bodyBookSendUsYou {
    return Intl.message(
      'Send us your tr. Id and you name',
      name: 'bodyBookSendUsYou',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get bodyBookNext {
    return Intl.message(
      'Next',
      name: 'bodyBookNext',
      desc: '',
      args: [],
    );
  }

  /// `You have requested to upload books We are review your request with in 2 or 3days, so please wait...`
  String get bodyUploadBWaitingText {
    return Intl.message(
      'You have requested to upload books We are review your request with in 2 or 3days, so please wait...',
      name: 'bodyUploadBWaitingText',
      desc: '',
      args: [],
    );
  }

  /// `hello`
  String get bodyUploadBHello {
    return Intl.message(
      'hello',
      name: 'bodyUploadBHello',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to SBO app`
  String get bodyUploadBWelcomeSBO {
    return Intl.message(
      'Welcome to SBO app',
      name: 'bodyUploadBWelcomeSBO',
      desc: '',
      args: [],
    );
  }

  /// `Request Now`
  String get bodyUploadBRequestNow {
    return Intl.message(
      'Request Now',
      name: 'bodyUploadBRequestNow',
      desc: '',
      args: [],
    );
  }

  /// `Send Request`
  String get bodyUploadBSendRequest {
    return Intl.message(
      'Send Request',
      name: 'bodyUploadBSendRequest',
      desc: '',
      args: [],
    );
  }

  /// `Select agent name`
  String get bodySelectAgentName {
    return Intl.message(
      'Select agent name',
      name: 'bodySelectAgentName',
      desc: '',
      args: [],
    );
  }

  /// `Upload book request`
  String get bodyUploadBookRequest {
    return Intl.message(
      'Upload book request',
      name: 'bodyUploadBookRequest',
      desc: '',
      args: [],
    );
  }

  /// `Clear Notifications`
  String get bodyClearNotifications {
    return Intl.message(
      'Clear Notifications',
      name: 'bodyClearNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Do not change or erase!`
  String get bodyUserNB {
    return Intl.message(
      'Do not change or erase!',
      name: 'bodyUserNB',
      desc: '',
      args: [],
    );
  }

  /// `UserID`
  String get bodyUserID {
    return Intl.message(
      'UserID',
      name: 'bodyUserID',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get bodySubmit {
    return Intl.message(
      'Submit',
      name: 'bodySubmit',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get bodyEdit {
    return Intl.message(
      'Edit',
      name: 'bodyEdit',
      desc: '',
      args: [],
    );
  }

  /// `My books`
  String get bodyMyBook {
    return Intl.message(
      'My books',
      name: 'bodyMyBook',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get bodyChangePsd {
    return Intl.message(
      'Change Password',
      name: 'bodyChangePsd',
      desc: '',
      args: [],
    );
  }

  /// `Please Check your password`
  String get bodyCheckPsd {
    return Intl.message(
      'Please Check your password',
      name: 'bodyCheckPsd',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bodyCancel {
    return Intl.message(
      'Cancel',
      name: 'bodyCancel',
      desc: '',
      args: [],
    );
  }

  /// `Set Password`
  String get bodySetPsd {
    return Intl.message(
      'Set Password',
      name: 'bodySetPsd',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect Password`
  String get bodyIncorrectPsd {
    return Intl.message(
      'Incorrect Password',
      name: 'bodyIncorrectPsd',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get bodyContinue {
    return Intl.message(
      'Continue',
      name: 'bodyContinue',
      desc: '',
      args: [],
    );
  }

  /// `Set Profile`
  String get bodySetProfile {
    return Intl.message(
      'Set Profile',
      name: 'bodySetProfile',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get bodyLblName {
    return Intl.message(
      'Name',
      name: 'bodyLblName',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get bodyLblEmail {
    return Intl.message(
      'Email',
      name: 'bodyLblEmail',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get bodyLblPhone {
    return Intl.message(
      'Phone',
      name: 'bodyLblPhone',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get bodyLblPsd {
    return Intl.message(
      'Password',
      name: 'bodyLblPsd',
      desc: '',
      args: [],
    );
  }

  /// `Old Password`
  String get bodyLblOldPsd {
    return Intl.message(
      'Old Password',
      name: 'bodyLblOldPsd',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get bodyLblConfirmPsd {
    return Intl.message(
      'Confirm Password',
      name: 'bodyLblConfirmPsd',
      desc: '',
      args: [],
    );
  }

  /// `Book Name`
  String get bodyLblBook {
    return Intl.message(
      'Book Name',
      name: 'bodyLblBook',
      desc: '',
      args: [],
    );
  }

  /// `Book Author`
  String get bodyLblBooAuthor {
    return Intl.message(
      'Book Author',
      name: 'bodyLblBooAuthor',
      desc: '',
      args: [],
    );
  }

  /// `As Arabic`
  String get bodyBookLblAr {
    return Intl.message(
      'As Arabic',
      name: 'bodyBookLblAr',
      desc: '',
      args: [],
    );
  }

  /// `Telecom Name`
  String get bodyBooLblTelecomName {
    return Intl.message(
      'Telecom Name',
      name: 'bodyBooLblTelecomName',
      desc: '',
      args: [],
    );
  }

  /// `Real Name`
  String get bodyUploadBLblRealName {
    return Intl.message(
      'Real Name',
      name: 'bodyUploadBLblRealName',
      desc: '',
      args: [],
    );
  }

  /// `Contact Email`
  String get bodyUploadBLblContactEmail {
    return Intl.message(
      'Contact Email',
      name: 'bodyUploadBLblContactEmail',
      desc: '',
      args: [],
    );
  }

  /// `Contact Phone`
  String get bodyUploadBLblContactPhone {
    return Intl.message(
      'Contact Phone',
      name: 'bodyUploadBLblContactPhone',
      desc: '',
      args: [],
    );
  }

  /// `Select Problem Issue`
  String get bodyLblSelectPro {
    return Intl.message(
      'Select Problem Issue',
      name: 'bodyLblSelectPro',
      desc: '',
      args: [],
    );
  }

  /// `Describe`
  String get bodyLblDescr {
    return Intl.message(
      'Describe',
      name: 'bodyLblDescr',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get bodyLblNewPsd {
    return Intl.message(
      'New Password',
      name: 'bodyLblNewPsd',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get bodyLblMsg {
    return Intl.message(
      'Message',
      name: 'bodyLblMsg',
      desc: '',
      args: [],
    );
  }

  /// `Image Link`
  String get bodyLblImgLink {
    return Intl.message(
      'Image Link',
      name: 'bodyLblImgLink',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get bodyLblLanguage {
    return Intl.message(
      'Language',
      name: 'bodyLblLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get bodyActive {
    return Intl.message(
      'Active',
      name: 'bodyActive',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get bodyRequests {
    return Intl.message(
      'Requests',
      name: 'bodyRequests',
      desc: '',
      args: [],
    );
  }

  /// `Rejects`
  String get bodyRejects {
    return Intl.message(
      'Rejects',
      name: 'bodyRejects',
      desc: '',
      args: [],
    );
  }

  /// `Redirect Link`
  String get bodyLblRedirectLink {
    return Intl.message(
      'Redirect Link',
      name: 'bodyLblRedirectLink',
      desc: '',
      args: [],
    );
  }

  /// `Enter Redirect Link`
  String get bodyHintRedirectLink {
    return Intl.message(
      'Enter Redirect Link',
      name: 'bodyHintRedirectLink',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter valid Url`
  String get bodyEnterValidUrl {
    return Intl.message(
      'Please Enter valid Url',
      name: 'bodyEnterValidUrl',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get bodyLblTitle {
    return Intl.message(
      'Title',
      name: 'bodyLblTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter a Title`
  String get bodyHintTitle {
    return Intl.message(
      'Enter a Title',
      name: 'bodyHintTitle',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get bodySend {
    return Intl.message(
      'Send',
      name: 'bodySend',
      desc: '',
      args: [],
    );
  }

  /// `Enter your full Name`
  String get bodyHintName {
    return Intl.message(
      'Enter your full Name',
      name: 'bodyHintName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your Email`
  String get bodyHintEmail {
    return Intl.message(
      'Enter your Email',
      name: 'bodyHintEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter your Phone (Optional)`
  String get bodyHintPhone {
    return Intl.message(
      'Enter your Phone (Optional)',
      name: 'bodyHintPhone',
      desc: '',
      args: [],
    );
  }

  /// `Enter your Password`
  String get bodyHintPsd {
    return Intl.message(
      'Enter your Password',
      name: 'bodyHintPsd',
      desc: '',
      args: [],
    );
  }

  /// `Enter Old Password`
  String get bodyHintOldPsd {
    return Intl.message(
      'Enter Old Password',
      name: 'bodyHintOldPsd',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your Password`
  String get bodyHintConfirmPsd {
    return Intl.message(
      'Confirm your Password',
      name: 'bodyHintConfirmPsd',
      desc: '',
      args: [],
    );
  }

  /// `Enter Book Name`
  String get bodyHintBook {
    return Intl.message(
      'Enter Book Name',
      name: 'bodyHintBook',
      desc: '',
      args: [],
    );
  }

  /// `Enter Book Author`
  String get bodyHintBookAuthor {
    return Intl.message(
      'Enter Book Author',
      name: 'bodyHintBookAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Enter Book Price`
  String get bodyHintBookPrice {
    return Intl.message(
      'Enter Book Price',
      name: 'bodyHintBookPrice',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get bodyHintCategory {
    return Intl.message(
      'Add Category',
      name: 'bodyHintCategory',
      desc: '',
      args: [],
    );
  }

  /// `Enter as a Arabic`
  String get bodyBookHintAr {
    return Intl.message(
      'Enter as a Arabic',
      name: 'bodyBookHintAr',
      desc: '',
      args: [],
    );
  }

  /// `Choose you number's Telecom name`
  String get bodyBooHintTelecomName {
    return Intl.message(
      'Choose you number\'s Telecom name',
      name: 'bodyBooHintTelecomName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Real Name`
  String get bodyUploadBHintRealName {
    return Intl.message(
      'Enter Real Name',
      name: 'bodyUploadBHintRealName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Contact Email`
  String get bodyUploadBHintContactEmail {
    return Intl.message(
      'Enter Contact Email',
      name: 'bodyUploadBHintContactEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter Contact Phone`
  String get bodyUploadBHintContactPhone {
    return Intl.message(
      'Enter Contact Phone',
      name: 'bodyUploadBHintContactPhone',
      desc: '',
      args: [],
    );
  }

  /// `Enter Book Name`
  String get bodyBookHintBook {
    return Intl.message(
      'Enter Book Name',
      name: 'bodyBookHintBook',
      desc: '',
      args: [],
    );
  }

  /// `Describe your problem`
  String get bodyHintDescr {
    return Intl.message(
      'Describe your problem',
      name: 'bodyHintDescr',
      desc: '',
      args: [],
    );
  }

  /// `Enter New Password`
  String get bodyHintNewPsd {
    return Intl.message(
      'Enter New Password',
      name: 'bodyHintNewPsd',
      desc: '',
      args: [],
    );
  }

  /// `Enter Translated by author name`
  String get bodyHintTrans {
    return Intl.message(
      'Enter Translated by author name',
      name: 'bodyHintTrans',
      desc: '',
      args: [],
    );
  }

  /// `Enter Message`
  String get bodyHintMsg {
    return Intl.message(
      'Enter Message',
      name: 'bodyHintMsg',
      desc: '',
      args: [],
    );
  }

  /// `Enter Image Link`
  String get bodyHintImgLink {
    return Intl.message(
      'Enter Image Link',
      name: 'bodyHintImgLink',
      desc: '',
      args: [],
    );
  }

  /// `Book Info`
  String get bodyBookInfo {
    return Intl.message(
      'Book Info',
      name: 'bodyBookInfo',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get bodyBookAuthor {
    return Intl.message(
      'Author',
      name: 'bodyBookAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Translate by`
  String get bodyBookTranslate {
    return Intl.message(
      'Translate by',
      name: 'bodyBookTranslate',
      desc: '',
      args: [],
    );
  }

  /// `Posted`
  String get bodyBookPosted {
    return Intl.message(
      'Posted',
      name: 'bodyBookPosted',
      desc: '',
      args: [],
    );
  }

  /// `Like`
  String get bodyBookLikes {
    return Intl.message(
      'Like',
      name: 'bodyBookLikes',
      desc: '',
      args: [],
    );
  }

  /// `Book Report`
  String get bodyBookReport {
    return Intl.message(
      'Book Report',
      name: 'bodyBookReport',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get bodyReport {
    return Intl.message(
      'Report',
      name: 'bodyReport',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get bodyBookRates {
    return Intl.message(
      'Rate',
      name: 'bodyBookRates',
      desc: '',
      args: [],
    );
  }

  /// `Rated`
  String get bodyBookRated {
    return Intl.message(
      'Rated',
      name: 'bodyBookRated',
      desc: '',
      args: [],
    );
  }

  /// `See More`
  String get bodySeeMore {
    return Intl.message(
      'See More',
      name: 'bodySeeMore',
      desc: '',
      args: [],
    );
  }

  /// `Translated by`
  String get bodyTranslatedBy {
    return Intl.message(
      'Translated by',
      name: 'bodyTranslatedBy',
      desc: '',
      args: [],
    );
  }

  /// `Book title`
  String get bodyBookTitle {
    return Intl.message(
      'Book title',
      name: 'bodyBookTitle',
      desc: '',
      args: [],
    );
  }

  /// `Book Author`
  String get bodyInfoBookAuthor {
    return Intl.message(
      'Book Author',
      name: 'bodyInfoBookAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Book Rate`
  String get bodyBookRate {
    return Intl.message(
      'Book Rate',
      name: 'bodyBookRate',
      desc: '',
      args: [],
    );
  }

  /// `Book Uploader`
  String get bodyBookUploader {
    return Intl.message(
      'Book Uploader',
      name: 'bodyBookUploader',
      desc: '',
      args: [],
    );
  }

  /// `Waiting...`
  String get bodyWaiting {
    return Intl.message(
      'Waiting...',
      name: 'bodyWaiting',
      desc: '',
      args: [],
    );
  }

  /// `Pay with Google Play`
  String get bodyPayWithGooglePlay {
    return Intl.message(
      'Pay with Google Play',
      name: 'bodyPayWithGooglePlay',
      desc: '',
      args: [],
    );
  }

  /// `Pay with locale payment`
  String get bodyPayWithLocale {
    return Intl.message(
      'Pay with locale payment',
      name: 'bodyPayWithLocale',
      desc: '',
      args: [],
    );
  }

  /// `Purchase`
  String get bodyPurchase {
    return Intl.message(
      'Purchase',
      name: 'bodyPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Most Popular`
  String get bodyMostPp {
    return Intl.message(
      'Most Popular',
      name: 'bodyMostPp',
      desc: '',
      args: [],
    );
  }

  /// `Remove Ad`
  String get bodyRemoveAd {
    return Intl.message(
      'Remove Ad',
      name: 'bodyRemoveAd',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get bodyPay {
    return Intl.message(
      'Pay',
      name: 'bodyPay',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get bodyMonth {
    return Intl.message(
      'Month',
      name: 'bodyMonth',
      desc: '',
      args: [],
    );
  }

  /// `Months`
  String get bodyMonths {
    return Intl.message(
      'Months',
      name: 'bodyMonths',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get bodySingUp {
    return Intl.message(
      'Sign Up',
      name: 'bodySingUp',
      desc: '',
      args: [],
    );
  }

  /// `Sing In`
  String get bodySingIn {
    return Intl.message(
      'Sing In',
      name: 'bodySingIn',
      desc: '',
      args: [],
    );
  }

  /// `Agree our terms and privacy`
  String get bodyAgreeOur {
    return Intl.message(
      'Agree our terms and privacy',
      name: 'bodyAgreeOur',
      desc: '',
      args: [],
    );
  }

  /// `terms and privacy`
  String get bodyOurTerms {
    return Intl.message(
      'terms and privacy',
      name: 'bodyOurTerms',
      desc: '',
      args: [],
    );
  }

  /// `This app can be used without a subscription. With a subscription, you get unlimited access to all paid features and the ads will be removed. Payment will be charged to your Google Play account at the confirmation of purchase. Subscriptions automatically renew unless canceled at least 24 hours before the current period ends. Manage or cancel subscriptions in your Google Play account settings anytime.`
  String get bodyPurchaseNote {
    return Intl.message(
      'This app can be used without a subscription. With a subscription, you get unlimited access to all paid features and the ads will be removed. Payment will be charged to your Google Play account at the confirmation of purchase. Subscriptions automatically renew unless canceled at least 24 hours before the current period ends. Manage or cancel subscriptions in your Google Play account settings anytime.',
      name: 'bodyPurchaseNote',
      desc: '',
      args: [],
    );
  }

  /// `Already i have an account`
  String get bodyAlready {
    return Intl.message(
      'Already i have an account',
      name: 'bodyAlready',
      desc: '',
      args: [],
    );
  }

  /// `Remember`
  String get bodyRemember {
    return Intl.message(
      'Remember',
      name: 'bodyRemember',
      desc: '',
      args: [],
    );
  }

  /// `Forget Password`
  String get bodyForgetPsd {
    return Intl.message(
      'Forget Password',
      name: 'bodyForgetPsd',
      desc: '',
      args: [],
    );
  }

  /// `I don't have an account`
  String get bodyIDonT {
    return Intl.message(
      'I don\'t have an account',
      name: 'bodyIDonT',
      desc: '',
      args: [],
    );
  }

  /// `Create new Account`
  String get bodyCreate {
    return Intl.message(
      'Create new Account',
      name: 'bodyCreate',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get bodyReset {
    return Intl.message(
      'Reset',
      name: 'bodyReset',
      desc: '',
      args: [],
    );
  }

  /// `Send Verification`
  String get bodySendVerification {
    return Intl.message(
      'Send Verification',
      name: 'bodySendVerification',
      desc: '',
      args: [],
    );
  }

  /// `Please wait resend`
  String get bodyWaitResend {
    return Intl.message(
      'Please wait resend',
      name: 'bodyWaitResend',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get bodyVContinue {
    return Intl.message(
      'Continue',
      name: 'bodyVContinue',
      desc: '',
      args: [],
    );
  }

  /// `if you not redirected after verification, click on the Continue button`
  String get bodyRedirect {
    return Intl.message(
      'if you not redirected after verification, click on the Continue button',
      name: 'bodyRedirect',
      desc: '',
      args: [],
    );
  }

  /// `We have just sent email verification link on `
  String get otherUserSentVerification {
    return Intl.message(
      'We have just sent email verification link on ',
      name: 'otherUserSentVerification',
      desc: '',
      args: [],
    );
  }

  /// ` please check email and click on that link to verify your email address `
  String get bodyUserNote {
    return Intl.message(
      ' please check email and click on that link to verify your email address ',
      name: 'bodyUserNote',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get bodyOr {
    return Intl.message(
      'Or',
      name: 'bodyOr',
      desc: '',
      args: [],
    );
  }

  /// `Continue with google`
  String get bodyContWitG {
    return Intl.message(
      'Continue with google',
      name: 'bodyContWitG',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back!`
  String get bodyWelcomeBack {
    return Intl.message(
      'Welcome back!',
      name: 'bodyWelcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get bodyRefresh {
    return Intl.message(
      'Refresh',
      name: 'bodyRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Resend`
  String get bodyResend {
    return Intl.message(
      'Resend',
      name: 'bodyResend',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get bodyRemove {
    return Intl.message(
      'Remove',
      name: 'bodyRemove',
      desc: '',
      args: [],
    );
  }

  /// `User Not Found`
  String get bodyUserNotFound {
    return Intl.message(
      'User Not Found',
      name: 'bodyUserNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Add book • Manage Books • Paid books`
  String get bodyBookSubTitle {
    return Intl.message(
      'Add book • Manage Books • Paid books',
      name: 'bodyBookSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Role • Agents`
  String get bodyUserSubTitle {
    return Intl.message(
      'Role • Agents',
      name: 'bodyUserSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `To see Agent profile tap and hold cover`
  String get bodyAgentTip {
    return Intl.message(
      'To see Agent profile tap and hold cover',
      name: 'bodyAgentTip',
      desc: '',
      args: [],
    );
  }

  /// `Agent`
  String get bodyAgent {
    return Intl.message(
      'Agent',
      name: 'bodyAgent',
      desc: '',
      args: [],
    );
  }

  /// `Make Announcement • Make Alert`
  String get bodyNotifySubTitle {
    return Intl.message(
      'Make Announcement • Make Alert',
      name: 'bodyNotifySubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Win Weakly Gift`
  String get bodyWinWeek {
    return Intl.message(
      'Win Weakly Gift',
      name: 'bodyWinWeek',
      desc: '',
      args: [],
    );
  }

  /// `Sign out and delete`
  String get bodySignDelete {
    return Intl.message(
      'Sign out and delete',
      name: 'bodySignDelete',
      desc: '',
      args: [],
    );
  }

  /// `Do you went to Delete this user account`
  String get bodyDoWentDelete {
    return Intl.message(
      'Do you went to Delete this user account',
      name: 'bodyDoWentDelete',
      desc: '',
      args: [],
    );
  }

  /// `New Category`
  String get bodyNewCaNewCategory {
    return Intl.message(
      'New Category',
      name: 'bodyNewCaNewCategory',
      desc: '',
      args: [],
    );
  }

  /// `Add Notify`
  String get bodyAddNotify {
    return Intl.message(
      'Add Notify',
      name: 'bodyAddNotify',
      desc: '',
      args: [],
    );
  }

  /// `Manage Notify`
  String get bodyManageNotify {
    return Intl.message(
      'Manage Notify',
      name: 'bodyManageNotify',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get bodyAllUsers {
    return Intl.message(
      'Users',
      name: 'bodyAllUsers',
      desc: '',
      args: [],
    );
  }

  /// `Authors`
  String get bodyAllAuthors {
    return Intl.message(
      'Authors',
      name: 'bodyAllAuthors',
      desc: '',
      args: [],
    );
  }

  /// `Admins`
  String get bodyAllAdmins {
    return Intl.message(
      'Admins',
      name: 'bodyAllAdmins',
      desc: '',
      args: [],
    );
  }

  /// `Agents`
  String get bodyAllAgents {
    return Intl.message(
      'Agents',
      name: 'bodyAllAgents',
      desc: '',
      args: [],
    );
  }

  /// `Header Banner`
  String get bodyHeaderBanner {
    return Intl.message(
      'Header Banner',
      name: 'bodyHeaderBanner',
      desc: '',
      args: [],
    );
  }

  /// `You don't change admins role`
  String get bodyNotChangeAdmins {
    return Intl.message(
      'You don\'t change admins role',
      name: 'bodyNotChangeAdmins',
      desc: '',
      args: [],
    );
  }

  /// `Select category`
  String get bodySelectCategory {
    return Intl.message(
      'Select category',
      name: 'bodySelectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Add or Choose Category`
  String get bodyAddOrChooseCategory {
    return Intl.message(
      'Add or Choose Category',
      name: 'bodyAddOrChooseCategory',
      desc: '',
      args: [],
    );
  }

  /// `Themes`
  String get bodyThemes {
    return Intl.message(
      'Themes',
      name: 'bodyThemes',
      desc: '',
      args: [],
    );
  }

  /// `blue`
  String get bodyColorBlue {
    return Intl.message(
      'blue',
      name: 'bodyColorBlue',
      desc: '',
      args: [],
    );
  }

  /// `green`
  String get bodyColorGreen {
    return Intl.message(
      'green',
      name: 'bodyColorGreen',
      desc: '',
      args: [],
    );
  }

  /// `purple`
  String get bodyColorPurple {
    return Intl.message(
      'purple',
      name: 'bodyColorPurple',
      desc: '',
      args: [],
    );
  }

  /// `grey`
  String get bodyColorGrey {
    return Intl.message(
      'grey',
      name: 'bodyColorGrey',
      desc: '',
      args: [],
    );
  }

  /// `brown`
  String get bodyColorBrown {
    return Intl.message(
      'brown',
      name: 'bodyColorBrown',
      desc: '',
      args: [],
    );
  }

  /// `pink`
  String get bodyColorPink {
    return Intl.message(
      'pink',
      name: 'bodyColorPink',
      desc: '',
      args: [],
    );
  }

  /// `Please check your email`
  String get bodyCheckYEmail {
    return Intl.message(
      'Please check your email',
      name: 'bodyCheckYEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter an exist email`
  String get bodyExist {
    return Intl.message(
      'Enter an exist email',
      name: 'bodyExist',
      desc: '',
      args: [],
    );
  }

  /// `Empty! Please Enter you Email`
  String get bodyEmptyEmail {
    return Intl.message(
      'Empty! Please Enter you Email',
      name: 'bodyEmptyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please check your name`
  String get bodyCheckName {
    return Intl.message(
      'Please check your name',
      name: 'bodyCheckName',
      desc: '',
      args: [],
    );
  }

  /// `Please check your phone`
  String get bodyCheckPhone {
    return Intl.message(
      'Please check your phone',
      name: 'bodyCheckPhone',
      desc: '',
      args: [],
    );
  }

  /// `Please check your name`
  String get bodyPaIsTooShort {
    return Intl.message(
      'Please check your name',
      name: 'bodyPaIsTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Please check your confirm password`
  String get bodyCheckCrmPsd {
    return Intl.message(
      'Please check your confirm password',
      name: 'bodyCheckCrmPsd',
      desc: '',
      args: [],
    );
  }

  /// `Your password is not match!`
  String get bodyYourPsdIsNotMatch {
    return Intl.message(
      'Your password is not match!',
      name: 'bodyYourPsdIsNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get bodyEnterValid {
    return Intl.message(
      'Please enter a valid email',
      name: 'bodyEnterValid',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred`
  String get bodyErrorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'bodyErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Your password  is too short!`
  String get bodyMinPsdError {
    return Intl.message(
      'Your password  is too short!',
      name: 'bodyMinPsdError',
      desc: '',
      args: [],
    );
  }

  /// `Not found`
  String get bodyNotFound {
    return Intl.message(
      'Not found',
      name: 'bodyNotFound',
      desc: '',
      args: [],
    );
  }

  /// `No Data`
  String get bodyNoData {
    return Intl.message(
      'No Data',
      name: 'bodyNoData',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get bodyDeleteAccount {
    return Intl.message(
      'Delete account',
      name: 'bodyDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Do you went to delete your account`
  String get bodyDeleteNote {
    return Intl.message(
      'Do you went to delete your account',
      name: 'bodyDeleteNote',
      desc: '',
      args: [],
    );
  }

  /// `Remember if you delete your account you can not recovery or undo.`
  String get bodyDeleteRem {
    return Intl.message(
      'Remember if you delete your account you can not recovery or undo.',
      name: 'bodyDeleteRem',
      desc: '',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get bodySendResetLink {
    return Intl.message(
      'Send Reset Link',
      name: 'bodySendResetLink',
      desc: '',
      args: [],
    );
  }

  /// `Please wait 5m to resend`
  String get bodyResendPsdWait {
    return Intl.message(
      'Please wait 5m to resend',
      name: 'bodyResendPsdWait',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get bodyResult {
    return Intl.message(
      'Result',
      name: 'bodyResult',
      desc: '',
      args: [],
    );
  }

  /// `Win Gift`
  String get bodyWinGift {
    return Intl.message(
      'Win Gift',
      name: 'bodyWinGift',
      desc: '',
      args: [],
    );
  }

  /// `Enable Weekly Gift`
  String get bodyEnableWkGift {
    return Intl.message(
      'Enable Weekly Gift',
      name: 'bodyEnableWkGift',
      desc: '',
      args: [],
    );
  }

  /// `Lucky number`
  String get bodyLuckyNumber {
    return Intl.message(
      'Lucky number',
      name: 'bodyLuckyNumber',
      desc: '',
      args: [],
    );
  }

  /// `Update Lucky Number`
  String get bodyUpLuckyNum {
    return Intl.message(
      'Update Lucky Number',
      name: 'bodyUpLuckyNum',
      desc: '',
      args: [],
    );
  }

  /// `Win User`
  String get bodyWinUser {
    return Intl.message(
      'Win User',
      name: 'bodyWinUser',
      desc: '',
      args: [],
    );
  }

  /// `Last lucky number:`
  String get bodyLastLuckyNum {
    return Intl.message(
      'Last lucky number:',
      name: 'bodyLastLuckyNum',
      desc: '',
      args: [],
    );
  }

  /// `Last date:`
  String get bodyLastDateLucky {
    return Intl.message(
      'Last date:',
      name: 'bodyLastDateLucky',
      desc: '',
      args: [],
    );
  }

  /// `Win this Gift`
  String get bodyWinThisGift {
    return Intl.message(
      'Win this Gift',
      name: 'bodyWinThisGift',
      desc: '',
      args: [],
    );
  }

  /// `Show Gift`
  String get bodyShowGift {
    return Intl.message(
      'Show Gift',
      name: 'bodyShowGift',
      desc: '',
      args: [],
    );
  }

  /// `Lucky Number:`
  String get bodyLuckyNum {
    return Intl.message(
      'Lucky Number:',
      name: 'bodyLuckyNum',
      desc: '',
      args: [],
    );
  }

  /// `Congregation \nYou win weekly gift and you got`
  String get bodyCongregateGift {
    return Intl.message(
      'Congregation \nYou win weekly gift and you got',
      name: 'bodyCongregateGift',
      desc: '',
      args: [],
    );
  }

  /// `you already done, Please wait next week`
  String get bodyAlreadyDone {
    return Intl.message(
      'you already done, Please wait next week',
      name: 'bodyAlreadyDone',
      desc: '',
      args: [],
    );
  }

  /// `Lucky`
  String get bodyLucky {
    return Intl.message(
      'Lucky',
      name: 'bodyLucky',
      desc: '',
      args: [],
    );
  }

  /// `Preparing new gift...`
  String get bodyPreparingGift {
    return Intl.message(
      'Preparing new gift...',
      name: 'bodyPreparingGift',
      desc: '',
      args: [],
    );
  }

  /// `sure`
  String get bodySure {
    return Intl.message(
      'sure',
      name: 'bodySure',
      desc: '',
      args: [],
    );
  }

  /// `Privilege Change`
  String get bodyPriChange {
    return Intl.message(
      'Privilege Change',
      name: 'bodyPriChange',
      desc: '',
      args: [],
    );
  }

  /// `Select Problem Issue`
  String get bodyLblSelectProblemIssue {
    return Intl.message(
      'Select Problem Issue',
      name: 'bodyLblSelectProblemIssue',
      desc: '',
      args: [],
    );
  }

  /// `Describe`
  String get bodyLblDescribe {
    return Intl.message(
      'Describe',
      name: 'bodyLblDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Describe your problem`
  String get bodyHintDescribe {
    return Intl.message(
      'Describe your problem',
      name: 'bodyHintDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Report description`
  String get bodyLblReportDesc {
    return Intl.message(
      'Report description',
      name: 'bodyLblReportDesc',
      desc: '',
      args: [],
    );
  }

  /// `Tell us why you report this book`
  String get bodyHintReportDesc {
    return Intl.message(
      'Tell us why you report this book',
      name: 'bodyHintReportDesc',
      desc: '',
      args: [],
    );
  }

  /// `Reported`
  String get bodyReported {
    return Intl.message(
      'Reported',
      name: 'bodyReported',
      desc: '',
      args: [],
    );
  }

  /// `Do not change or erase! \n\n`
  String get bodyUserReportNote {
    return Intl.message(
      'Do not change or erase! \n\n',
      name: 'bodyUserReportNote',
      desc: '',
      args: [],
    );
  }

  /// `Supported Languages: Somali, Arabic and English-US`
  String get bodyWeSupportLanguages {
    return Intl.message(
      'Supported Languages: Somali, Arabic and English-US',
      name: 'bodyWeSupportLanguages',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to the SBO app! You can get the latest books, read more learn more. Check it out and install now`
  String get bodyShareAppLink {
    return Intl.message(
      'Welcome to the SBO app! You can get the latest books, read more learn more. Check it out and install now',
      name: 'bodyShareAppLink',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to remove ${user} from your agent.`
  String bodyUserManActions(String user) {
    return Intl.message(
      'Do you want to remove \$$user from your agent.',
      name: 'bodyUserManActions',
      desc: '',
      args: [user],
    );
  }

  /// `Winner of the week is {winUser} please try again next week`
  String bodyWeekWinner(String winUser) {
    return Intl.message(
      'Winner of the week is $winUser please try again next week',
      name: 'bodyWeekWinner',
      desc: 'A message when the user is win a week',
      args: [winUser],
    );
  }

  /// `Do you went to promote {role} to {newRole} this user {user}`
  String bodyRoleActions(String role, String newRole, String user) {
    return Intl.message(
      'Do you went to promote $role to $newRole this user $user',
      name: 'bodyRoleActions',
      desc: 'A message when the role change',
      args: [role, newRole, user],
    );
  }

  /// `{currentField} can't be empty`
  String bodyEmptyValid(String currentField) {
    return Intl.message(
      '$currentField can\'t be empty',
      name: 'bodyEmptyValid',
      desc: 'A message when the user leave empty field',
      args: [currentField],
    );
  }

  /// `You got {currentNumber} try again next weak`
  String bodySorryGift(String currentNumber) {
    return Intl.message(
      'You got $currentNumber try again next weak',
      name: 'bodySorryGift',
      desc: 'A message when the user gets a certain number',
      args: [currentNumber],
    );
  }

  /// `You already got {lucky} this week, please wait until next weak`
  String bodyAlreadyGot(String lucky) {
    return Intl.message(
      'You already got $lucky this week, please wait until next weak',
      name: 'bodyAlreadyGot',
      desc: 'A message when the user has already got a number',
      args: [lucky],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
