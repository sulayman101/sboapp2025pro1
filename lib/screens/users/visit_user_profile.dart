import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/dropdown_widget.dart';
import 'package:sboapp/constants/book_card.dart';
import 'package:sboapp/constants/check_subs.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/services/book_searching.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

class UserProfileBooks extends StatefulWidget {
  final String uid;
  const UserProfileBooks({super.key, required this.uid});

  @override
  State<UserProfileBooks> createState() => _UserProfileBooksState();
}

class _UserProfileBooksState extends State<UserProfileBooks> {
  List<BookModel> searchBooks = [];

  int checked = 0;
  int checkedLan = 0;
  final ScrollController _scrollController = ScrollController();
  String? category;
  bool visible = false;

  String constProfile =
      "https://firebasestorage.googleapis.com/v0/b/sboapp-2a2be.appspot.com/o/profile_images%2FwoOUuLKoJbdlZSxyaVFNQYPl7fX2?alt=media&token=082a9782-5a9f-4be9-9591-3175d104cbe3";
  bool isDone = false;
  @override
  void didUpdateWidget(covariant UserProfileBooks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isDone) return setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetDatabase>(context, listen: true);
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return StreamBuilder<UserModel>(
      stream: provider.userProfile(uid: widget.uid),
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SafeArea(
            child: ScaffoldWidget(
                body: Column(
              children: [
                ProfileShimmer(
                  isBannerProfile: false,
                ),
                Expanded(
                    child: BookShimmer(
                  indexLength: 10,
                ))
              ],
            )),
          );
        }
        if (snapshot.hasData) {
          isDone = true;
          return ScaffoldWidget(
              appBar: AppBar(
                title: Text(snapshot.data!.name),
                actions: [
                  Visibility(
                    visible: visible,
                    child: IconButton(
                        onPressed: () {
                          showSearch(
                              context: context,
                              delegate: CustomSearchDelegate(
                                  listOfBooks: searchBooks));
                        },
                        icon: const Icon(Icons.search)),
                  ),
                  //IconButton(onPressed: (){}, icon: const Icon(CupertinoIcons.search))
                ],
              ),
              body: Column(
                children: [
                  Card.filled(child: userInfoWidget(snapshot, providerLocale)),
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
                                            padding:
                                                EdgeInsets.only(right: 8.0),
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
                                            padding:
                                                EdgeInsets.only(right: 8.0),
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
                                            padding:
                                                EdgeInsets.only(right: 8.0),
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
                  Expanded(child: _getAllBooks()),
                ],
              ));
        } else {
          return const Center(
            child: Text("This User is not found or resistic"),
          );
        }
      },
    );
  }

  Widget _getAllBooks() {
    final provider = Provider.of<GetDatabase>(context, listen: true);
    return StreamBuilder<List<BookModel>>(
      stream: category != null
          ? provider.bookController.stream
          : provider.allBookAgentController.stream,
      //provider.getBooks(category:  category!["category"]),
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
          if (snapshot.data != null) {
            visible = true;
            if (searchBooks.isEmpty) {
              searchBooks.addAll(snapshot.data!);
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                if (snapshot.data![index].user == widget.uid) {
                  return BookCard(
                    bookModel: snapshot.data![index],
                    isModify: false,
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

  Widget userInfoWidget(snapshot, providerLocale) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        children: [
          ListTile(
              leading: ClipOval(
                  child: ImageNetCache(
                      imageUrl: snapshot.data!.profile ?? constProfile)),
              title: bodyText(text: snapshot.data!.name),
              subtitle: bodyText(text: snapshot.data!.email),
              trailing: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: subChecker(
                      snapSubName: snapshot.data!.subscription?.subname,
                      snapSubActive: snapshot.data!.subscription?.subscribe))),
          /*Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customText(
                  text: "${providerLocale.bodyLblName}:",
                  fontSize: MediaQuery.of(context).textScaler.scale(18),
                  fontWeight: FontWeight.w300),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
                width: MediaQuery.of(context).size.width * 1,
              ),
              bodyText(text: snapshot.data!.name),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              customText(
                  text: "${providerLocale.bodyLblEmail}:",
                  fontSize: MediaQuery.of(context).textScaler.scale(18),
                  fontWeight: FontWeight.w300),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              bodyText(text: snapshot.data!.email),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              customText(
                  text: "Subscribed:",
                  fontSize: MediaQuery.of(context).textScaler.scale(18),
                  fontWeight: FontWeight.w300),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              bodyText(text: snapshot.data!.subscribed != null ? snapshot.data!.subscribed! : "false"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}
