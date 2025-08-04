import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdsState extends ChangeNotifier {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int _maxLoadAttempts = 3;
  int _adClickCount = 0;
  final int _maxClicks = 3;
  bool _canClick = true;

  final String adUnitId = 'ca-app-pub-5978208654644743/6451649661';

  /// Loads an interstitial ad.
  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error');
          _numInterstitialLoadAttempts++;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < _maxLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  /// Displays the interstitial ad if available.
  void showInterstitialAd() async {
    if (_interstitialAd == null) {
      log('Attempt to show interstitial before loaded.');
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('Ad showed full screen content.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('Ad dismissed full screen content.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdClicked: (ad) => _handleAdClick(),
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('Ad failed to show full screen content: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  /// Handles ad click logic, including limiting clicks and resetting after a cooldown.
  void _handleAdClick() {
    if (!_canClick) {
      log('Clicking is disabled for 1 minute.');
      return;
    }

    _adClickCount++;
    log('Ad clicked $_adClickCount times.');

    if (_adClickCount >= _maxClicks) {
      log('Max ad clicks reached. Disabling clicks for 1 minute.');
      _canClick = false;
      Timer(const Duration(minutes: 1), () {
        _adClickCount = 0;
        _canClick = true;
        notifyListeners();
        log('Clicking is now re-enabled.');
      });
    }
  }
}
