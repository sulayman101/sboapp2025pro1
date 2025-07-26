import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return CustomScrollView(slivers: [
      SliverAppBar(
        pinned: false, // The AppBar will scroll away when you scroll up
        floating: true,
        snap: true,
        collapsedHeight: MediaQuery.of(context).size.height * 0.14,
        expandedHeight: MediaQuery.of(context).size.height * 0.16,
        flexibleSpace: const Padding(
            padding: EdgeInsets.only(bottom: 8.0), child: TopBannerShimmer()),
      ),
      SliverList(
          delegate: SliverChildBuilderDelegate(childCount: 5,
              (BuildContext context, int index) {
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary,
                      highlightColor: Theme.of(context).colorScheme.onPrimary,
                      direction: providerLocale.language == "العربية"
                          ? ShimmerDirection.rtl
                          : ShimmerDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.015,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.red,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_outlined),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.26,
                                    child: Material(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Shimmer.fromColors(
                                            baseColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            highlightColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            direction:
                                                providerLocale.language ==
                                                        "العربية"
                                                    ? ShimmerDirection.rtl
                                                    : ShimmerDirection.ltr,
                                            child: Image.asset(
                                              "assets/images/logoSplash.png",
                                              filterQuality: FilterQuality.high,
                                            ))),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.008,
                                  ),
                                  Shimmer.fromColors(
                                    baseColor:
                                        Theme.of(context).colorScheme.primary,
                                    highlightColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    direction:
                                        providerLocale.language == "العربية"
                                            ? ShimmerDirection.rtl
                                            : ShimmerDirection.ltr,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.008,
                                        ),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.favorite),
                                            Row(
                                              children: [
                                                Icon(Icons.star_rate),
                                                Icon(Icons.star_rate),
                                                Icon(Icons.star_rate),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                          /*Material(
                                  color: Theme.of(context).colorScheme.primary,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Shimmer.fromColors(
                                    baseColor:  Theme.of(context).colorScheme.onPrimary,
                                    highlightColor:Theme.of(context).colorScheme.primary,
                                    direction: providerLocale.language == "العربية" ? ShimmerDirection.rtl : ShimmerDirection.ltr,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: MediaQuery.of(context).size.height * 0.29,
                                            width: double.infinity,
                                            child: Image.asset("assets/images/logoSplash.png", filterQuality: FilterQuality.high,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );*/
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }))
    ]);
  }
}

class TopBannerShimmer extends StatelessWidget {
  const TopBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return CarouselSlider.builder(
      itemCount: 3,
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 3.0,
        enlargeCenterPage: true,
      ),
      itemBuilder: (context, index, realIdx) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.primary,
          highlightColor: Theme.of(context).colorScheme.surface,
          direction: providerLocale.language == "العربية"
              ? ShimmerDirection.rtl
              : ShimmerDirection.ltr,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/logoSplash.png",
                  width: MediaQuery.of(context).size.width * 1,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20)),
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ListBannerShimmer extends StatelessWidget {
  const ListBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                color: Theme.of(context).colorScheme.primaryContainer),
            height: MediaQuery.of(context).size.height * 0.2,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.primary,
              highlightColor: Theme.of(context).colorScheme.surface,
              direction: providerLocale.language == "العربية"
                  ? ShimmerDirection.rtl
                  : ShimmerDirection.ltr,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/logoSplash.png",
                      width: MediaQuery.of(context).size.width * 1,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.01,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookShimmer extends StatelessWidget {
  final int indexLength;
  const BookShimmer({super.key, required this.indexLength});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ListView.builder(
      itemCount: indexLength,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.outlineVariant,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.primary,
              highlightColor: Theme.of(context).colorScheme.surface,
              direction: providerLocale.language == "العربية"
                  ? ShimmerDirection.rtl
                  : ShimmerDirection.ltr,
              child: Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      "assets/images/logoSplash.png",
                    ),
                    title: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20)),
                      height: 7,
                      width: 20,
                    ),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20)),
                          height: 5,
                          width: 170,
                        ),
                      ],
                    ),
                    trailing: const Icon(CupertinoIcons.heart_fill),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  final bool? isBannerProfile;
  const ProfileShimmer({super.key, this.isBannerProfile});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.primary,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  direction: providerLocale.language == "العربية"
                      ? ShimmerDirection.rtl
                      : ShimmerDirection.ltr,
                  child: isBannerProfile == null
                      ? ListTile(
                          leading: const Icon(
                            Icons.person,
                          ),
                          title: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20)),
                            height: MediaQuery.of(context).size.height * 0.007,
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20)),
                                height:
                                    MediaQuery.of(context).size.height * 0.005,
                                width: MediaQuery.of(context).size.width * 0.4,
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                  radius: 50,
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                                width: MediaQuery.of(context).size.width * 1,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                                width: MediaQuery.of(context).size.width * 0.3,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                                width: MediaQuery.of(context).size.width * 1,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                                width: MediaQuery.of(context).size.width * 0.3,
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5),
                            ],
                          ),
                        )),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class DropShimmer extends StatelessWidget {
  const DropShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: 1)),
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.primary,
          highlightColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: ListTile(
              title: Container(
                height: MediaQuery.of(context).size.height * 0.02,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10)),
              ),
              trailing: const Icon(Icons.arrow_drop_down_sharp),
            ),
          ),
        ),
      ),
    );
  }
}
/*
class ImageNetCache extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width, height;
  const ImageNetCache({super.key, required this.imageUrl, this.fit, this.width, this.height, });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(imageUrl: imageUrl, placeholder: (context, url) => Image.asset("assets/images/logoSplash.png", ), errorWidget: (context, url, error) => Icon(CupertinoIcons.exclamationmark_circle), fit: fit, width: width,height: height,);
  }
}*/

class ImageNetCache extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width, height;
  final double? imageSize;
  const ImageNetCache(
      {super.key,
      required this.imageUrl,
      this.fit,
      this.width,
      this.height,
      this.imageSize});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      height: height,
      width: width,
      placeholder: (context, url) => ShimmerImage(
        imageSize: imageSize,
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.error,
        color: Colors.red,
        size: kDefaultFontSize,
      ),
    );
  }
}

class ShimmerImage extends StatelessWidget {
  final double? imageSize;

  const ShimmerImage({super.key, this.imageSize});
  @override
  Widget build(BuildContext context) {
    double imgSize = imageSize ?? 0.07;
    return Shimmer.fromColors(
      //baseColor: Colors.grey[300]!,
      //highlightColor: Colors.grey[100]!,
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Image.asset("assets/images/logoSplash.png",
          height: MediaQuery.of(context).size.width * imgSize),
      //fit: BoxFit.cover,
      //),
    );
  }
}

class HomeRowsShimmer extends StatelessWidget {
  final String bookCategory;
  const HomeRowsShimmer({super.key, required this.bookCategory});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: titleText(text: bookCategory, fontSize: kDefaultFontSize * 1.5)),
                    ),
                    const Icon(Icons.arrow_forward_ios_outlined),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.26,
                                child: Material(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Shimmer.fromColors(
                                        baseColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        direction:
                                            providerLocale.language == "العربية"
                                                ? ShimmerDirection.rtl
                                                : ShimmerDirection.ltr,
                                        child: Image.asset(
                                          "assets/images/logoSplash.png",
                                          filterQuality: FilterQuality.high,
                                        ))),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.008,
                              ),
                              Shimmer.fromColors(
                                baseColor:
                                    Theme.of(context).colorScheme.primary,
                                highlightColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                direction: providerLocale.language == "العربية"
                                    ? ShimmerDirection.rtl
                                    : ShimmerDirection.ltr,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.008,
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.favorite),
                                        Row(
                                          children: [
                                            Icon(Icons.star_rate),
                                            Icon(Icons.star_rate),
                                            Icon(Icons.star_rate),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                      /*Material(
                                  color: Theme.of(context).colorScheme.primary,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Shimmer.fromColors(
                                    baseColor:  Theme.of(context).colorScheme.onPrimary,
                                    highlightColor:Theme.of(context).colorScheme.primary,
                                    direction: providerLocale.language == "العربية" ? ShimmerDirection.rtl : ShimmerDirection.ltr,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: MediaQuery.of(context).size.height * 0.29,
                                            width: double.infinity,
                                            child: Image.asset("assets/images/logoSplash.png", filterQuality: FilterQuality.high,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );*/
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
