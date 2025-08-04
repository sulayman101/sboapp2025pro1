import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ListAds extends StatefulWidget {
  const ListAds({super.key});

  @override
  State<ListAds> createState() => _ListAdsState();
}

class _ListAdsState extends State<ListAds> {
  final String adUnitId = "ca-app-pub-5978208654644743/4877346563";
  late BannerAd _bannerAd;
  bool _adIsLoaded = false;
  int _adClickCount = 0;
  final int _maxClicks = 3;
  bool _canClick = true;

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();
  }

  void _initializeBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _adIsLoaded = true),
        onAdClicked: (_) => _handleAdClick(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log('BannerAd failed to load: $error');
        },
      ),
      request: const AdRequest(nonPersonalizedAds: true),
    );
    _bannerAd.load();
  }

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
        setState(() {
          _adClickCount = 0;
          _canClick = true;
        });
        log('Clicking is now re-enabled.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _adIsLoaded
        ? SizedBox(
            height: _bannerAd.size.height.toDouble(),
            width: _bannerAd.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : const SizedBox();
  }
}
