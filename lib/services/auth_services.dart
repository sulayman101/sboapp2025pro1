
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/services/get_database.dart';


class AuthServices extends ChangeNotifier {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref(dbName);

  String? errorMsg;
  bool authGUser = false;
  String _verificationId = "";
  Timer? _timer;
  int timeLeft = 120;
  bool reSend = false;
  bool _isVerified = false;
  bool _isDisposed = false; // Add disposed flag

  bool _isGuest = false;

  bool get isGuest => _isGuest;

  // Initialize App Check
  static Future<void> initializeAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        // For Android (Release builds)
        androidProvider: AndroidProvider.playIntegrity,
        // For iOS
        appleProvider: AppleProvider.appAttest,
        // For web
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
      log('Firebase App Check initialized successfully');
    } catch (e) {
      log('Failed to initialize App Check: $e');
      // Fallback to debug provider for development
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        log('App Check initialized with debug provider');
      } catch (debugError) {
        log('Failed to initialize App Check with debug provider: $debugError');
      }
    }
  }

  // Set debug token for development (call this in development only)
  static Future<void> setDebugToken() async {
    try {
      // Only use this in development/debug builds
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

      // Get debug token - you'll need to check the logs for the actual token
      // and then register it in Firebase Console
      log('App Check debug mode enabled. Check logs for debug token.');
    } catch (e) {
      log('Error setting debug token: $e');
    }
  }

  // Safe notifyListeners that checks if disposed
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void signInAsGuest() {
    _isGuest = true;
    _safeNotifyListeners();
  }

  void signOutGuest() {
    _isGuest = false;
    _safeNotifyListeners();
  }

  String get verificationId => _verificationId;

  Future<void> signIn(String email, String password) async {
    try {
      await fireAuth.signInWithEmailAndPassword(
          email: email, password: password);
      _isGuest = false; // Clear guest status on successful login
      saveDeviceId();
      _safeNotifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMsg = e.message;
      log(e.message.toString());
      rethrow;
    }
  }

  // Replace your existing signInWithGoogle method with this updated version

  Future<void> signInWithGoogle() async {
    try {
      // Check if authentication is supported on this platform
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        errorMsg = 'Google Sign-In is not supported on this platform';
        _safeNotifyListeners();
        return;
      }

      // Perform authentication
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn.instance.authenticate();

      if (googleSignInAccount == null) {
        // User cancelled the sign-in
        return;
      }

      // Get authentication details
      //final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        //accessToken: googleAuth.,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      await fireAuth.signInWithCredential(credential);

      // Clear guest status on successful login
      _isGuest = false;

      // Save user data to database
      await saveGoogleUser();

      // Notify listeners
      _safeNotifyListeners();

    } on GoogleSignInException catch (e) {
      // Handle Google Sign-In specific exceptions
      errorMsg = switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Sign in was cancelled',
        GoogleSignInExceptionCode.interrupted => 'Sign in was interrupted. Please try again.',
        GoogleSignInExceptionCode.values => 'Invalid sign in values provided',
        GoogleSignInExceptionCode.clientConfigurationError => 'Google Sign-In configuration error. Please contact support.',
        GoogleSignInExceptionCode.providerConfigurationError => 'Provider configuration error. Please contact support.',
        GoogleSignInExceptionCode.uiUnavailable => 'Google Sign-In UI is currently unavailable',
        GoogleSignInExceptionCode.unknownError => 'An unknown error occurred during sign in',
        GoogleSignInExceptionCode.userMismatch => 'User account mismatch. Please try again.',
        _ => 'Google Sign-In error: ${e.description}',
      };
      _safeNotifyListeners();
      log('Google Sign-In Exception: ${e.code} - ${e.description}');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      errorMsg = e.message ?? 'Firebase authentication failed';
      _safeNotifyListeners();
      log('Firebase Auth Exception: ${e.code} - ${e.message}');
    } catch (e) {
      // Handle any other exceptions
      errorMsg = 'An unexpected error occurred during sign-in';
      _safeNotifyListeners();
      log('Unexpected error during Google Sign-In: $e');
    }
  }
  // Future<void> signInWithGoogle() async {
  //   try {
  //     final googleSignInAccount = await _googleSignIn.signIn();
  //     if (googleSignInAccount == null) return;
  //
  //     final googleAuth = await googleSignInAccount.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     await fireAuth.signInWithCredential(credential);
  //     _isGuest = false; // Clear guest status on successful login
  //     await saveGoogleUser();
  //     _safeNotifyListeners();
  //   } on FirebaseAuthException catch (e) {
  //     errorMsg = e.message;
  //     log(errorMsg.toString());
  //   }
  // }

  Future<void> signUp(UserModel userModel, String password) async {
    try {
      await fireAuth.createUserWithEmailAndPassword(
          email: userModel.email, password: password);
      _isGuest = false; // Clear guest status on successful signup
      saveUserData(userModel);
      _safeNotifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMsg = e.message;
      log(e.message.toString());
      _safeNotifyListeners();
    }
  }

  Future<void> saveUserData(UserModel userModel) async {
    try {
      final uid = fireAuth.currentUser!.uid;
      await _db.child("Users/$uid").set(userModel.toJson());
      await _db.child("Users/$uid").update({"uid": uid});
      saveDeviceId();
    } catch (e) {
      log('Error saving user data: $e');
      // Handle App Check related errors gracefully
      if (e.toString().contains('AppCheck')) {
        log('App Check error during user data save - continuing without App Check verification');
      }
      rethrow;
    }
  }

  Future<void> saveGoogleUser() async {
    try {
      final uid = fireAuth.currentUser!.uid;
      final snapshot = await _db.child("Users/$uid/name").get();

      if (!snapshot.exists) {
        final userModel = UserModel(
          name: fireAuth.currentUser?.displayName ?? 'Unknown',
          email: fireAuth.currentUser?.email ?? 'Unknown',
          isVerify: fireAuth.currentUser?.emailVerified ?? false,
          role: "User",
          uid: uid,
        );
        await _db.child("Users/$uid").set(userModel.toJson());
      }
      saveDeviceId();
    } catch (e) {
      log('Error saving Google user: $e');
      // Handle App Check related errors gracefully
      if (e.toString().contains('AppCheck')) {
        log('App Check error during Google user save - continuing without App Check verification');
      }
    }
  }

  Future<void> saveDeviceId() async {
    try {
      if (fireAuth.currentUser?.uid != null && Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        await _db.child("Users/${fireAuth.currentUser!.uid}").update({
          'device': deviceInfo.id,
        });
      }
    } catch (e) {
      log('Error saving device ID: $e');
      // Handle App Check related errors gracefully
      if (e.toString().contains('AppCheck') || e.toString().contains('app-check')) {
        log('App Check error during device ID save - continuing without App Check verification');
      }
    }
  }

  Future<void> verifyEmail() async {
    try {
      if (!fireAuth.currentUser!.emailVerified) {
        await fireAuth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
    }
  }

  Future<void> sendVerification() async {
    try {
      reSend = false;
      await verifyEmail();
      _startTimer();
      await Future.delayed(const Duration(seconds: 120));
      if (!_isDisposed) {
        reSend = true;
        _safeNotifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      await fireAuth.currentUser!.reload();
      _isVerified = fireAuth.currentUser!.emailVerified;
      if (_isVerified) {
        _timer?.cancel();
        _timer = null;
      }
      _safeNotifyListeners();
    } catch (e) {
      log('Error checking email verification: $e');
    }
  }

  Future<void> deleteUser() async {
    try {
      final uid = fireAuth.currentUser!.uid;
      await _db.child("Users/$uid").remove();
      await fireAuth.currentUser!.delete();
      await fireAuth.signOut();
      _isGuest = false;
      _safeNotifyListeners();
    } catch (e) {
      log('Error deleting user: $e');
      // Handle App Check related errors gracefully
      if (e.toString().contains('AppCheck') || e.toString().contains('app-check')) {
        log('App Check error during user deletion - continuing without App Check verification');
      }
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await fireAuth.sendPasswordResetEmail(email: email);
      _safeNotifyListeners();
    } catch (e) {
      log('Error resetting password: $e');
    }
  }

  Future<void> signOut() async {
    try {
      // Cancel any running timers
      _timer?.cancel();
      _timer = null;

      await _googleSignIn.signOut();
      await fireAuth.signOut();
      _isGuest = false;
      _safeNotifyListeners();
    } catch (e) {
      log('Error signing out: $e');
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await fireAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          await fireAuth.currentUser!.linkWithCredential(credential);
          _safeNotifyListeners();
        } catch (e) {
          log('Error linking phone credential: $e');
        }
      },
      verificationFailed: (e) {
        log(e.message.toString());
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        _safeNotifyListeners();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        _safeNotifyListeners();
      },
    );
  }

  Future<void> linkPhoneNumber(String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await fireAuth.currentUser!.linkWithCredential(credential);
      _safeNotifyListeners();
    } catch (e) {
      log('Error linking phone number: $e');
    }
  }

  void _startTimer() {
    // Cancel existing timer if any
    _timer?.cancel();

    timeLeft = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (timeLeft > 0) {
        timeLeft--;
        _safeNotifyListeners();
      } else {
        timer.cancel();
        _timer = null;
        _safeNotifyListeners();
      }
    });
  }

  // Method to manually cancel timer if needed
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sboapp/app_model/user_model.dart';
// import 'package:sboapp/services/get_database.dart';
//
// class AuthServices extends ChangeNotifier {
//   final FirebaseAuth fireAuth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final DatabaseReference _db = FirebaseDatabase.instance.ref(dbName);
//
//   String? errorMsg;
//   bool authGUser = false;
//   String _verificationId = "";
//   Timer? _timer;
//   int timeLeft = 120;
//   bool reSend = false;
//   bool _isVerified = false;
//
//   bool _isGuest = false;
//
//   bool get isGuest => _isGuest;
//
//   void signInAsGuest() {
//     _isGuest = true;
//     notifyListeners();
//   }
//
//   void signOutGuest() {
//     _isGuest = false;
//     notifyListeners();
//   }
//
//   String get verificationId => _verificationId;
//
//   Future<void> signIn(String email, String password) async {
//     try {
//       await fireAuth.signInWithEmailAndPassword(
//           email: email, password: password);
//       saveDeviceId();
//       notifyListeners();
//     } on FirebaseAuthException catch (e) {
//       errorMsg = e.message;
//       log(e.message.toString());
//       rethrow;
//     }
//   }
//
//   Future<void> signInWithGoogle() async {
//     try {
//       final googleSignInAccount = await _googleSignIn.signIn();
//       if (googleSignInAccount == null) return;
//
//       final googleAuth = await googleSignInAccount.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       await fireAuth.signInWithCredential(credential);
//       await saveGoogleUser();
//     } on FirebaseAuthException catch (e) {
//       errorMsg = e.message;
//       log(errorMsg.toString());
//     }
//   }
//
//   Future<void> signUp(UserModel userModel, String password) async {
//     try {
//       await fireAuth.createUserWithEmailAndPassword(
//           email: userModel.email, password: password);
//       saveUserData(userModel);
//       notifyListeners();
//     } on FirebaseAuthException catch (e) {
//       errorMsg = e.message;
//       log(e.message.toString());
//       notifyListeners();
//     }
//   }
//
//   Future<void> saveUserData(UserModel userModel) async {
//     final uid = fireAuth.currentUser!.uid;
//     await _db.child("Users/$uid").set(userModel.toJson());
//     await _db.child("Users/$uid").update({"uid": uid});
//     saveDeviceId();
//   }
//
//   Future<void> saveGoogleUser() async {
//     final uid = fireAuth.currentUser!.uid;
//     final snapshot = await _db.child("Users/$uid/name").get();
//
//     if (!snapshot.exists) {
//       final userModel = UserModel(
//         name: fireAuth.currentUser?.displayName ?? 'Unknown',
//         email: fireAuth.currentUser?.email ?? 'Unknown',
//         isVerify: fireAuth.currentUser?.emailVerified ?? false,
//         role: "User",
//         uid: uid,
//       );
//       await _db.child("Users/$uid").set(userModel.toJson());
//     }
//   }
//
//   Future<void> saveDeviceId() async {
//     if (fireAuth.currentUser?.uid != null && Platform.isAndroid) {
//       final deviceInfo = await DeviceInfoPlugin().androidInfo;
//       await _db.child("Users/${fireAuth.currentUser!.uid}").update({
//         'device': deviceInfo.id,
//       });
//     }
//   }
//
//   Future<void> verifyEmail() async {
//     try {
//       if (!fireAuth.currentUser!.emailVerified) {
//         await fireAuth.currentUser!.sendEmailVerification();
//       }
//     } on FirebaseAuthException catch (e) {
//       log(e.message.toString());
//     }
//   }
//
//   Future<void> sendVerification() async {
//     try {
//       reSend = false;
//       await verifyEmail();
//       _startTimer();
//       await Future.delayed(const Duration(seconds: 120));
//       reSend = true;
//       notifyListeners();
//     } on FirebaseAuthException catch (e) {
//       log(e.message.toString());
//     }
//   }
//
//   Future<void> checkEmailVerification() async {
//     await fireAuth.currentUser!.reload();
//     _isVerified = fireAuth.currentUser!.emailVerified;
//     if (_isVerified) _timer?.cancel();
//     notifyListeners();
//   }
//
//   Future<void> deleteUser() async {
//     final uid = fireAuth.currentUser!.uid;
//     await _db.child("Users/$uid").remove();
//     await fireAuth.currentUser!.delete();
//     await fireAuth.signOut();
//     notifyListeners();
//   }
//
//   Future<void> resetPassword(String email) async {
//     await fireAuth.sendPasswordResetEmail(email: email);
//     notifyListeners();
//   }
//
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await fireAuth.signOut();
//     notifyListeners();
//   }
//
//   Future<void> verifyPhoneNumber(String phoneNumber) async {
//     await fireAuth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: (credential) async {
//         await fireAuth.currentUser!.linkWithCredential(credential);
//       },
//       verificationFailed: (e) {
//         log(e.message.toString());
//       },
//       codeSent: (verificationId, _) {
//         _verificationId = verificationId;
//       },
//       codeAutoRetrievalTimeout: (verificationId) {
//         _verificationId = verificationId;
//       },
//     );
//   }
//
//   Future<void> linkPhoneNumber(String smsCode) async {
//     final credential = PhoneAuthProvider.credential(
//       verificationId: _verificationId,
//       smsCode: smsCode,
//     );
//     await fireAuth.currentUser!.linkWithCredential(credential);
//     notifyListeners();
//   }
//
//   void _startTimer() {
//     timeLeft = 120;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (timeLeft > 0) {
//         timeLeft--;
//         notifyListeners();
//       } else {
//         timer.cancel();
//         notifyListeners();
//       }
//     });
//   }
// }
