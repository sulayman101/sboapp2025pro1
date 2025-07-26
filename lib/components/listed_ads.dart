import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/services/get_database.dart';

class ListAds extends StatefulWidget {
  const ListAds({super.key});

  @override
  State<ListAds> createState() => _ListAdsState();
}

class _ListAdsState extends State<ListAds> {
  //ads
  var adUnit = "ca-app-pub-5978208654644743/4877346563";
  late BannerAd bannerAd;
  bool adIsLoad = false;
  int adClickCount = 0;
  int maxClicks = 3;
  bool canClick = true;

  initBanner() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            adIsLoad = true;
            //print(adIsLoad);
          });
        }, onAdClicked: (ad) {
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
              setState(() {
                adClickCount = 0;
                canClick = true;
              });
              log('Clicking is now re-enabled.');
            });
          }
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log(error.toString());
          //print(error);
        }),
        request: const AdRequest(nonPersonalizedAds: true));
    bannerAd.load();
  }

  //ads

  @override
  void initState() {
    super.initState();
    Provider.of<GetDatabase>(context, listen: false).loadIsRead();
    if (Provider.of<GetDatabase>(context, listen: false).subscriber == false) {
      initBanner();
    }
    log("===================================================loaded===============================================");
  }

  @override
  Widget build(BuildContext context) {
    return adIsLoad
        ? SizedBox(
      height: bannerAd.size.height.toDouble(),
      width: bannerAd.size.width.toDouble(),
          child: Stack(
            children: [
              Align(alignment: Alignment.topRight,
                child: GestureDetector(child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.amberAccent,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
                      child: Text("AD", style: TextStyle(
                        fontSize: kDefaultFontSize * 0.7,
                          color: Colors.black
                      ),),
                    ),
                  ),
                ),),
              ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: bannerAd.size.height.toDouble(),
                    width: bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  ),
                ),
              ],
          ),
        )
        : const SizedBox();
  }
}
