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
  final String adUnit = "ca-app-pub-5978208654644743/4877346563";
  late BannerAd bannerAd;
  bool adIsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  void _initializeAds() {
    final isSubscriber =
        Provider.of<GetDatabase>(context, listen: false).subscriber;

    if (!isSubscriber) {
      bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              adIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: const AdRequest(),
      );
      bannerAd.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    isActiveAds = adIsLoaded;

    return Scaffold(
      appBar: widget.appBar,
      body: Column(
        children: [
          Expanded(child: widget.body),
        ],
      ),
      bottomNavigationBar: adIsLoaded
          ? SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.amberAccent,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 5.0),
                          child: Text(
                            "AD",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
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
          : const SizedBox(),
    );
  }
}
