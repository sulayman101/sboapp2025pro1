import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/listed_ads.dart';
import 'package:sboapp/constants/book_card.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/services/book_searching.dart';
import 'package:sboapp/services/get_database.dart';

import 'package:sboapp/services/lan_services/language_provider.dart';

import '../../components/chips_check.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List<BookModel> searchBooks = [];

  int checked = 0;
  int checkedLan = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final category =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final provider =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(category!["lanCategory"]),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(listOfBooks: searchBooks));
              },
              icon: const Icon(Icons.search)),
          //IconButton(onPressed: (){}, icon: const Icon(CupertinoIcons.search))
        ],
      ),
      body: Column(
        children: [
          topLang(provider),
          Expanded(child: _getAllBooks(category)),
        ],
      ),
    );
  }
  
  

  Widget topLang(provider){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0,left: 8.0, right: 8.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  choiceChipWidget(
                      label: provider.bodyAll,
                      selected: checkedLan == 0,
                      onSelected: (selected) {
                        setState(() {
                          checkedLan = 0;
                        });
                      }),
                  const SizedBox(
                    width: 4,
                  ),
                  choiceChipWidget(
                      label: provider.bodySomali,
                      selected: checkedLan == 1,
                      onSelected: (selected) {
                        setState(() {
                          checkedLan = 1;
                        });
                      }),
                  const SizedBox(
                    width: 4,
                  ),
                  choiceChipWidget(
                      label: provider.bodyArabic,
                      selected: checkedLan == 2,
                      onSelected: (selected) {
                        setState(() {
                          checkedLan = 2;
                        });
                      }),
                  const SizedBox(
                    width: 4,
                  ),
                  choiceChipWidget(
                      label: provider.bodyEnglish,
                      selected: checkedLan == 3,
                      onSelected: (selected) {
                        setState(() {
                          checkedLan = 3;
                        });
                      }),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  checked = value;
                });
              },
              itemBuilder: (BuildContext context) {
                // Defining the options for the popup menu
                return <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(children: [
                      Visibility(
                          visible: checked == 0,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.check),
                          )),
                      buttonText(text: provider.bodyAll)
                    ]),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(children: [
                      Visibility(
                          visible: checked == 1,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.check),
                          )),
                      buttonText(text: provider.bodyFree)
                    ]),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(children: [
                      Visibility(
                          visible: checked == 2,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.check),
                          )),
                      buttonText(text: provider.bodyPaid)
                    ]),
                  ),
                ];
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getAllBooks(category) {
    final provider = Provider.of<GetDatabase>(context, listen: true);
    /*return Consumer<GetDatabase>(
      builder: (BuildContext context, GetDatabase value, Widget? child) {
        final provider = context.read<GetDatabase>();*/
    return StreamBuilder<List<BookModel>>(
      stream: provider.bookController
          .stream, //provider.getBooks(category:  category!["category"]),
      builder: (BuildContext context, AsyncSnapshot<List<BookModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          Provider.of<GetDatabase>(context, listen: true)
              .getBooks(category: category!["category"]);
          //return const BookShimmer(indexLength: 10);
          if (!snapshot.hasData) {
            return const BookShimmer(indexLength: 10);
          } else {
            return const Center(
              child: Text("No Data"),
            );
          }
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            if (searchBooks.isEmpty) {
              searchBooks.addAll(snapshot.data!);
            }
            return ListView.separated(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Visibility(
                  visible: snapshot.data![index].status == "Public",
                  child: BookCard(
                    bookModel: snapshot.data![index],
                    arCategory: category!["lanCategory"],
                    isModify: false,
                    isFree: checked,
                    lang: checkedLan,
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return adsInList(index % 10 == 2);
              },
            );
          } else {
            return const Center(child: Text("No Rows"));
          }
        } else {
          return const Center(child: Text("No Data"));
        }
        //},
        //);
      },
    );
    /*Consumer<GetDatabase>(
      builder:
          (BuildContext context, GetDatabase value, Widget? child) {
        final provider = context.watch<GetDatabase>();
        return StreamBuilder<List<BookModel>>(
          stream: provider.getdBooks(category: widget.category),
          builder: (BuildContext context,
              AsyncSnapshot<List<BookModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const BookShimmer(indexLength: 10);
            }
            if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString()),);
            }
            if (snapshot.hasData) {
              searchBooks.isEmpty ? searchBooks.addAll(snapshot.data!) : searchBooks;
              return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    /*if (index % 6 == 2) {
                                  index + 1;
                                  return const ListAds();
                                } else {*/
                    return BookCard(
                      bookModel: snapshot.data![index],
                      isModify: false,
                      isFree: checked, lang: checkedLan,
                    );
                    //}
                  });

            } else {
              return const Center(child: Text("No Data"));
            }
          },
        );
      },
    );*/
  }

  Widget adsInList(condition){
    return Container(
        child: condition ? const ListAds() : null);
  }

  Widget rowAction({required int likes, required int price}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.heart_fill),
              Text(likes.toString())
            ],
          ),
          Visibility(
            visible: price != 0,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(CupertinoIcons.money_dollar_circle_fill),
              Text(price.toString())
            ]),
          ),
        ],
      );
}
