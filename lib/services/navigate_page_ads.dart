

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class NavigatePageAds extends ChangeNotifier{
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  // replace this test ad unit with your own ad unit.
  final adUnitId = 'ca-app-pub-5978208654644743/6451649661';

  /// Loads an interstitial ad.
  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            //log('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 3) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() async {
    if (_interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      return;
    }

    await Future.delayed(const Duration(seconds: 1));
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
