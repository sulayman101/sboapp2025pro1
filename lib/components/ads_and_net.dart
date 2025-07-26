import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/services/get_database.dart';

bool isActiveAds = false;

class ScaffoldWidget extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  const ScaffoldWidget({super.key, this.appBar, required this.body});

  @override
  State<ScaffoldWidget> createState() => _ScaffoldWidgetState();
}

class _ScaffoldWidgetState extends State<ScaffoldWidget> {
  //ads
  var adUnit = "ca-app-pub-5978208654644743/4877346563";
  late BannerAd bannerAd;
  bool adIsLoad = false;

  initBanner() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            adIsLoad = true;
            //print(adIsLoad);
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          //print(error);
        }),
        request: const AdRequest());
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
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GetDatabase>(context, listen: true).loadIsRead();
    isActiveAds = adIsLoad;
    return Scaffold(
      appBar: widget.appBar,
      body: Column(
        children: [
          //const ConIndicator(),
          //NetTest==========================
          Expanded(child: widget.body)
        ],
      ),
      bottomNavigationBar: adIsLoad
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
      /*SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              child: AdWidget(
                ad: bannerAd,
              ),
            )*/
          : const SizedBox(),
    );
  }
}


/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/Services/appDatabase.dart';
import 'package:sboapp/Services/lanServices/language_provider.dart';

import 'net_check.dart';

enum ConnStatus{online, offline}

class ScaffoldWidget extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Widget? bottomSheet;
  const ScaffoldWidget({super.key, this.appBar, required this.body, this.bottomSheet});

  @override
  State<ScaffoldWidget> createState() => _ScaffoldWidgetState();
}

class _ScaffoldWidgetState extends State<ScaffoldWidget> {

  //ads
  var adUnit = "ca-app-pub-5978208654644743/4877346563";
  late BannerAd bannerAd;
  bool adIsLoad = false;


  initBanner(){
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(
            onAdLoaded: (ad){
              setState(() {
                adIsLoad = true;
                //print(adIsLoad);
              });
            },
            onAdFailedToLoad: (ad, error){
              ad.dispose();
              //print(error);
            }
        ),
        request: const AdRequest()
    );
    bannerAd.load();
  }

  //ads
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<GetDatabase>(context, listen: false).loadIsRead();
    if(Provider.of<GetDatabase>(context, listen: false).subscriber == false) {
      initBanner();
    }

  }



  @override
  Widget build(BuildContext context) {
    return Consumer<AppLocalizationsNotifier>(builder: (BuildContext context, AppLocalizationsNotifier value, Widget? child) {
      var localRtl = value.localizations;
      return Directionality(
        textDirection: localRtl.language == "العربية" ? TextDirection.rtl : TextDirection.ltr,
        child: Provider.of<GetDatabase>(context, listen: true).subscriber ? withAds() : withOutAds()
      );
    });
  }
  Widget withAds(){
    //widget.removeAds == null || widget.removeAds == false ?
    return Scaffold(
      appBar: widget.appBar,
      body: Column(children: [
        const NetworkCheckPage(),
        Expanded(child: widget.body)
      ],),
      bottomNavigationBar: widget.bottomSheet ?? (adIsLoad ? SizedBox(
        height: bannerAd.size.height.toDouble(),
        width: bannerAd.size.width.toDouble(),
        child: AdWidget(ad: bannerAd,),
      ) : const SizedBox()),
    );
  }
  Widget withOutAds(){
    //widget.removeAds == null || widget.removeAds == false ?
    return Scaffold(
      appBar: widget.appBar,
      body: Column(children: [
        const NetworkCheckPage(),
        Expanded(child: widget.body)
      ],),
    );
  }
}

class AdsBanner extends StatefulWidget {
  final Widget child;
  final Widget title;
  const AdsBanner({super.key, required this.child, required this.title});

  @override
  State<AdsBanner> createState() => _AdsBannerState();
}

class _AdsBannerState extends State<AdsBanner> {

  var adUnit = "ca-app-pub-5978208654644743/4877346563";
  late BannerAd topBannerAd;
  bool topAdIsLoad = false;
  late BannerAd bottomBannerAd;
  bool bottomAdIsLoad = false;


  topInitBanner(){
    topBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(
            onAdLoaded: (ad){
              setState(() {
                topAdIsLoad = true;
                //print(adIsLoad);
              });
            },
            onAdFailedToLoad: (ad, error){
              ad.dispose();
              //print(error);
            }
        ),
        request: const AdRequest()
    );
    topBannerAd.load();
  }
  bottomInitBanner(){
    bottomBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(
            onAdLoaded: (ad){
              setState(() {
                bottomAdIsLoad = true;
                //print(adIsLoad);
              });
            },
            onAdFailedToLoad: (ad, error){
              ad.dispose();
              //print(error);
            }
        ),
        request: const AdRequest()
    );
    bottomBannerAd.load();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    topInitBanner();
    bottomInitBanner();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.title,
        Row(
          children: [
            Expanded(child: topAdIsLoad ? SizedBox(
              height: topBannerAd.size.height.toDouble(),
              width: topBannerAd.size.width.toDouble(),
              child: AdWidget(ad: topBannerAd,),
            ) : const SizedBox(),),
          ],
        ),
        widget.child,
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(child: bottomAdIsLoad ? SizedBox(
                height: bottomBannerAd.size.height.toDouble(),
                width: bottomBannerAd.size.width.toDouble(),
                child: AdWidget(ad: bottomBannerAd,),
              ) : const SizedBox(),),
            ],
          ),
        )
      ],);

  }
}

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


  initBanner(){
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(
            onAdLoaded: (ad){
              setState(() {
                adIsLoad = true;
                //print(adIsLoad);
              });
            },
            onAdFailedToLoad: (ad, error){
              ad.dispose();
              log(error.toString());
              //print(error);
            }
        ),

        request: const AdRequest(nonPersonalizedAds: true)
    );
    bannerAd.load();
  }

  //ads

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBanner();
  }

  @override
  Widget build(BuildContext context) {
    return adIsLoad ? SizedBox(
      height: bannerAd.size.height.toDouble(),
      width: bannerAd.size.width.toDouble(),
      child: AdWidget(ad: bannerAd),
    ) : const SizedBox();
  }
}
    **/
