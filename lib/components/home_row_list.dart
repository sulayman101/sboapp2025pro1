
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/constants/languages_convert.dart';
import 'package:sboapp/constants/short_nums.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/screens/books/book_view_Info.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';
//

class HomeRowsList extends StatefulWidget {
  final String bookCategory;
  final String lanCategory;
  final VoidCallback onTap;

  const HomeRowsList({
    super.key,
    required this.bookCategory,
    required this.lanCategory,
    required this.onTap,
  });

  @override
  State<HomeRowsList> createState() => _HomeRowsListState();
}

class _HomeRowsListState extends State<HomeRowsList> {
  String convertNumber({required num number, required String languageCode}) {
    final formatter = NumberFormat.decimalPattern(languageCode);
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: false)
            .localizations;
    final provider = Provider.of<GetDatabase>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<BookModel>>(
            stream: provider.getTopBooks(category: widget.bookCategory),
            builder: (BuildContext context,
                AsyncSnapshot<List<BookModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return HomeRowsShimmer(
                  bookCategory: widget.lanCategory,
                );
              }
              if (snapshot.hasData) {
                return SizedBox(
                  height: size.height * 0.53,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              titleText(text: widget.lanCategory,
                                fontSize: kDefaultFontSize * 1.5
                              ),
                              const Icon(Icons.arrow_forward_ios_outlined)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            final int isLessThen = snapshot.data!.length < 10
                                ? snapshot.data!.length
                                : snapshot.data!.length;
                            if (index < isLessThen) {
                              return Visibility(
                                visible:
                                    snapshot.data![index].status == "Public",
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BookInfoView(
                                                  bookModel: snapshot
                                                      .data![index],
                                                  arCategory: widget
                                                      .lanCategory,
                                                )));
                                  },
                                  child: Hero(
                                    tag: snapshot.data![index].book,
                                    child: Card.filled(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FittedBox(
                                          child: SizedBox(
                                            width: size.width * 0.4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                    child: ImageNetCache(
                                                        imageUrl: snapshot
                                                            .data![index].img,
                                                        fit: BoxFit.cover,
                                                        width: size.width * 0.4,
                                                        height: size.height * 0.25),
                                                  ),
                                                ),
                                                rowTitleText(
                                                    text: snapshot.data![index].book
                                                        .toUpperCase(),

                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                rowSubTitleText(
                                                    text: snapshot.data![index].author),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    bodyText(
                                                      text: convertLang(
                                                          snapshot
                                                              .data![index].language,
                                                          providerLocale),
                                                    ),
                                                    RatingBarIndicator(
                                                      itemBuilder: (context, _) =>
                                                          const Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      itemSize: kDefaultFontSize * 1.3,
                                                      rating: customRound(double.parse(snapshot
                                                              .data![index]
                                                              .averageRate ??
                                                          "0.0")),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets.only(
                                                                right: 4.0),
                                                            child: Icon(
                                                              Icons.favorite,
                                                              applyTextScaling: true,
                                                              size: 18,
                                                            )),
                                                        bodyText(
                                                            text: (shortNum(number: snapshot.data![index].like))),
                                                      ],
                                                    ),
                                                    /*bodyText(
                                                        text:
                                                        "${providerLocale.bodyBookLikes}: ${shortNum(number: snapshot.data![index].like)}"),*/

                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 4.0),
                                                            child: Icon(
                                                              Icons.star,
                                                              applyTextScaling: true,
                                                              size: 18,
                                                            )),
                                                        bodyText(
                                                            text: "${customRound(double.parse(snapshot.data![index].averageRate!))}"),
                                                        /*bodyText(
                                                            text:
                                                            "${providerLocale.bodyBookRates}: ${customRound(double.parse(snapshot.data![index].averageRate!))}"),*/
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 4.0),
                                                            child: Icon(
                                                              Icons.person,
                                                              applyTextScaling: true,
                                                              size: 18,
                                                            )),
                                                        bodyText(
                                                            text: shortNum(
                                                              number: num.parse(snapshot
                                                                  .data![index]
                                                                  .totalRates ??
                                                                  "0"),
                                                            ).toString())
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: widget.onTap,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        titleText(
                                            text: providerLocale.bodySeeMore),
                                        const Icon(
                                            Icons.arrow_forward_ios_outlined),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: Text(providerLocale.bodyNotFound));
              }
            },
          ),
        ),
      ],
    );

  }

}
