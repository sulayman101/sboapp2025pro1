import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/Components/ads_and_net.dart';
import 'package:sboapp/Components/dropdown_widget.dart';
import 'package:sboapp/Constants/book_card.dart';
import 'package:sboapp/Constants/text_style.dart';
import 'package:sboapp/Constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/Services/auth_services.dart';
import 'package:sboapp/Services/book_searching.dart';
import 'package:sboapp/Services/get_database.dart';
import 'package:sboapp/Services/lan_services/language_provider.dart';

//This is not working Page

class MyBooks extends StatefulWidget {
  const MyBooks({super.key});

  @override
  State<MyBooks> createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  List<BookModel> searchBooks = [];

  int checked = 0;
  int checkedLan = 0;
  final ScrollController _scrollController = ScrollController();
  String? category;
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetDatabase>(context, listen: true);
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ScaffoldWidget(
        appBar: AppBar(
          title: appBarText(text: providerLocale.appBarManage),
          actions: [
            Visibility(
              visible: visible,
              child: IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate:
                            CustomSearchDelegate(listOfBooks: searchBooks));
                  },
                  icon: const Icon(Icons.search)),
            ),
            //IconButton(onPressed: (){}, icon: const Icon(CupertinoIcons.search))
          ],
        ),
        body: Column(
          children: [
            StreamBuilder<List<MyCategories>>(
              stream: provider.getCategories(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<MyCategories>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const DropShimmer();
                }
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropDownWidget(
                            providerLocale: providerLocale,
                            hintText: providerLocale.bodySelectCategory,
                            selectedValue: category,
                            onChange: (onValue) {
                              setState(() {
                                provider.getBooks(category: onValue!);
                                category = onValue!;
                              });
                            },
                            items: snapshot.data!),
                      ),
                      Visibility(
                        visible: category != null,
                        child: IconButton(
                            onPressed: () => setState(() {
                                  provider.getAllAgentBooks();
                                  category = null;
                                }),
                            icon: const Icon(Icons.cancel)),
                      )
                    ],
                  );
                } else {
                  return Card(child: Text(providerLocale.bodyNotFound));
                }
              },
            ),
            Visibility(
              visible: visible,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            ChoiceChip(
                                label: Text(providerLocale.bodyAll),
                                selected: checkedLan == 0,
                                onSelected: (selected) {
                                  setState(() {
                                    checkedLan = 0;
                                  });
                                }),
                            const SizedBox(
                              width: 4,
                            ),
                            ChoiceChip(
                                label: Text(providerLocale.bodySomali),
                                selected: checkedLan == 1,
                                onSelected: (selected) {
                                  setState(() {
                                    checkedLan = 1;
                                  });
                                }),
                            const SizedBox(
                              width: 4,
                            ),
                            ChoiceChip(
                                label: Text(providerLocale.bodyArabic),
                                selected: checkedLan == 2,
                                onSelected: (selected) {
                                  setState(() {
                                    checkedLan = 2;
                                  });
                                }),
                            const SizedBox(
                              width: 4,
                            ),
                            ChoiceChip(
                                label: Text(providerLocale.bodyEnglish),
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
                                buttonText(text: providerLocale.bodyAll)
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
                                buttonText(text: providerLocale.bodyFree)
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
                                buttonText(text: providerLocale.bodyPaid)
                              ]),
                            ),
                          ];
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: Visibility(
                    visible: category != null, child: _getAllBooks())),
          ],
        ));
  }

  Widget _getAllBooks() {
    final provider = Provider.of<GetDatabase>(context, listen: true);
    return StreamBuilder<List<BookModel>>(
      stream: category != null
          ? provider.bookController.stream
          : provider.allBookAgentController
              .stream, //provider.getBooks(category:  category!["category"]),
      builder: (BuildContext context, AsyncSnapshot<List<BookModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          category != null
              ? Provider.of<GetDatabase>(context, listen: true)
                  .getBooks(category: category!)
              : Provider.of<GetDatabase>(context, listen: true)
                  .getAllAgentBooks();
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
          visible = true;
          if (snapshot.data != null) {
            if (searchBooks.isEmpty) {
              searchBooks.addAll(snapshot.data!);
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                if (snapshot.data![index].user ==
                    AuthServices().fireAuth.currentUser!.uid) {
                  return BookCard(
                    bookModel: snapshot.data![index],
                    isModify: true,
                    isFree: checked,
                    lang: checkedLan,
                  );
                } else {
                  return const SizedBox();
                }
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



/**
class MyBooks extends StatefulWidget {
  const MyBooks({super.key});

  @override
  State<MyBooks> createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  List<MyCategories> categories =[];
  List<BookModel> myBook = [];
  String? selectedValue;
  int checked = 0;
  int checkedLang = 0;

  @override
  Widget build(BuildContext context) {
    final myProvider = Provider.of<GetDatabase>(context, listen: true);
    final providerLocale = Provider.of<AppLocalizationsNotifier>(context, listen: true).localizations;
    return ScaffoldWidget(
      appBar: AppBar(title: Text(providerLocale.appBarManage),),
        body: Consumer<GetDatabase>(builder: (BuildContext context, GetDatabase value, Widget? child) {
          final provider = context.read<GetDatabase>();
          return Column(children: [
            StreamBuilder<List<MyCategories>>(
              stream: provider.getCategories(), builder: (BuildContext context, AsyncSnapshot<List<MyCategories>> snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData){
                return const DropShimmer();
              }
              if(snapshot.hasData) {
                return DropDownWidget(
                  providerLocale: providerLocale,
                    selectedValue: selectedValue, onChange: (onValue){ selectedValue = onValue!; provider.notifyListeners(); myBook.clear();}, items: snapshot.data!);
              }else{
                return Card(child: Text(providerLocale.bodyNotFound));
              }
            },
            ),
            Visibility(
              visible: selectedValue != null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    ChoiceChip(label: Text(providerLocale.bodyAll), selected: checked == 0, onSelected: (selected){ setState(() {
                      checked = 0;
                    });}),
                    SizedBox(width: 4,),
                    ChoiceChip(label: Text(providerLocale.bodyFree), selected: checked == 1, onSelected: (selected){ setState(() {
                      checked = 1;
                    });}),
                    SizedBox(width: 4,),
                    ChoiceChip(label: Text(providerLocale.bodyPaid), selected: checked == 2, onSelected: (selected){ setState(() {
                      checked = 2;
                    });}),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: selectedValue != null,
              child: Expanded(
                  child: StreamBuilder<List<BookModel>?>(
                      stream: provider.bookController.stream, //provider.getBooks(category: selectedValue ?? "Islamic"),
                      builder: (BuildContext context, AsyncSnapshot<List<BookModel>?> snapshot) {
                        /*if(snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData){
                          return const BookShimmer(indexLength: 10);
                        }*/
                        if(snapshot.hasData){
                          String myUid = AuthServices().fireAuth.currentUser!.uid;
                          for(var book in snapshot.data!){
                            if(book.user == myUid){
                              myBook.add(book);
                            }
                          }
                          return ListView.builder(
                              itemCount: myBook.length,
                              itemBuilder: (context, index){
                                return BookCard(bookModel: myBook[index], isFree: checked, lang: checkedLang, isModify: true);
                                //Material(child: Text(snapshot.data![index].book),);
                              });
                        }else{
                          return Center(child: Text(providerLocale.bodyNoData),);
                        }
                  },
                  )),
            ),
          ],);
        },
        )
    );
  }
}*/
