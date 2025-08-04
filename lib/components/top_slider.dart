import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sboapp/app_model/top_banner_model.dart';
import 'package:sboapp/Constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/Services/get_database.dart';
import 'package:url_launcher/url_launcher.dart';

class TopSliders extends StatefulWidget {
  const TopSliders({super.key});

  @override
  State<TopSliders> createState() => _TopSlidersState();
}

class _TopSlidersState extends State<TopSliders> {
  void _handleBannerTap(String? link) {
    if (link == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: bodyText(text: ""),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      launchUrl(Uri.parse(link));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TopBannerModel>>(
      stream: GetDatabase().getBanners(),
      builder:
          (BuildContext context, AsyncSnapshot<List<TopBannerModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TopBannerShimmer();
        }
        if (snapshot.hasData) {
          return CarouselSlider.builder(
            itemCount: snapshot.data!.length,
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 3.1,
              enlargeCenterPage: true,
            ),
            itemBuilder: (context, index, realIdx) {
              return GestureDetector(
                onTap: () => _handleBannerTap(snapshot.data![index].toGoLink),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FittedBox(
                        child: ImageNetCache(
                          imageUrl: snapshot.data![index]
                              .imgLink, //Image.network(snapshot.data![index].imgLink,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 1,
                          imageSize: 0.25,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white10, // Transparent at the top
                                Theme.of(context)
                                    .colorScheme
                                    .surface, // Change this color to your desired bottom color
                              ],
                              stops: const [
                                0.0,
                                0.5
                              ], // 0.5 represents the bottom 50%
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 8.0),
                            child: titleText(
                                text: snapshot.data![index].title,
                                fontSize: 18),
                          )),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text("No data"),
          );
        }
      },
    );
  }
}
