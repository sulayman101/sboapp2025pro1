import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NavigatePageAds extends ChangeNotifier {
  InterstitialAd? _interstitialAd;
  int _loadAttempts = 0;
  final int _maxLoadAttempts = 3;

  // Replace this test ad unit with your own ad unit.
  final String adUnitId = 'ca-app-pub-5978208654644743/6451649661';

  /// Loads an interstitial ad.
  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _loadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
          log('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial ad failed to load: $error');
          _loadAttempts++;
          _interstitialAd = null;
          if (_loadAttempts < _maxLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  /// Displays the interstitial ad if available.
  void showInterstitialAd() async {
    if (_interstitialAd == null) {
      log('Attempt to show interstitial ad before it was loaded.');
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('Interstitial ad displayed.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('Interstitial ad dismissed.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('Interstitial ad failed to show: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
