import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdsState extends ChangeNotifier {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 5;
  int adClickCount = 0;
  int maxClicks = 3;
  bool canClick = true;

  //  replace this test ad unit with your own ad unit.
  final adUnitId = 'ca-app-pub-5978208654644743/6451649661';

  /// Loads an interstitial ad.
  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            //print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            //print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 3) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd({bool? reward}) async {
    if (_interstitialAd == null) {
      //print('Warning: attempt to show interstitial before loaded.');
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
      onAdClicked: (ad) {
        if (!canClick) {
          log('Clicking is disabled for 1 minute.');
          return; // Ignore clicks if disabled
        }

        if (adClickCount < maxClicks) {
          adClickCount++; // Increment click count on each click
          log('Ad clicked $adClickCount times');
        }

        if (adClickCount >= maxClicks) {
          // Disable further clicks and start the timer
          log('Max ad clicks reached. Disabling clicks for 1 minute.');
          canClick = false; // Disable further clicks
          Timer(const Duration(minutes: 1), () {
            // Reset the click count and re-enable clicking after 1 minute
            adClickCount = 0;
            canClick = true;
            notifyListeners();
            log('Clicking is now re-enabled.');
          });
        }
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
