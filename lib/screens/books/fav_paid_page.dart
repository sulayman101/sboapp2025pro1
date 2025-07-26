import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/dropdown_widget.dart';
import 'package:sboapp/constants/likes_and_paid.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  String? favSelectedValue;
  String? paidSelectedValue;
  TabController? _tabController;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Widget _tabView(providerLocale, provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        favorites(providerLocale),
        paidBooks(providerLocale),
      ],
    );
  }

  Widget _tabBar(providerLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TabBar(
          unselectedLabelColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          tabAlignment: TabAlignment.fill,
          indicatorWeight: 2,
          indicatorPadding: EdgeInsets.zero,
          splashBorderRadius: const BorderRadius.only(
              topRight: Radius.circular(10), topLeft: Radius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Theme.of(context).colorScheme.primary,
          dividerHeight: 2,
          indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          isScrollable: false,
          controller: _tabController,
          tabs: [
            Tab(text: providerLocale.bodyFavorite),
            Tab(text: providerLocale.bodySold),
          ]),
    );
  }

  Widget paidBooks(providerLocale) {
    //final provider = Provider.of<GetDatabase>(context,listen: false);
    return Consumer<GetDatabase>(
        builder: (BuildContext context, GetDatabase value, Widget? child) {
      final provider = context.read<GetDatabase>();
      return Column(
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
                          selectedValue: paidSelectedValue,
                          onChange: (onValue) {
                            setState(() {
                              provider.getBooks(category: onValue!);
                              paidSelectedValue = onValue!;
                              favSelectedValue = null;
                            });
                          },
                          items: snapshot.data!),
                    ),
                    Visibility(
                      visible: paidSelectedValue != null,
                      child: IconButton(
                          onPressed: () => setState(() {
                                provider.getAllAgentBooks();
                                paidSelectedValue = null;
                              }),
                          icon: const Icon(Icons.clear)),
                    )
                  ],
                );
              } else {
                return Card(child: Text(providerLocale.bodyNotFound));
              }
            },
          ),
          Visibility(
            visible: paidSelectedValue != null,
            child: Expanded(
                child: StreamBuilder<List<BookModel>?>(
              stream: provider.bookController
                  .stream, //provider.getBooks(category: paidSelectedValue ?? "Islamic"),
              builder: (BuildContext context,
                  AsyncSnapshot<List<BookModel>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const BookShimmer(indexLength: 10);
                }
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return LpBookCard(
                          bookModel: snapshot.data![index],
                          isFavorite: false,
                        );
                        //Material(child: Text(snapshot.data![index].book),);
                      });
                } else {
                  return const Center(
                    child: Text("No Data"),
                  );
                }
              },
            )),
          ),
        ],
      );
      //End point
    });
  }

  Widget favorites(providerLocale) {
    return Consumer<GetDatabase>(
        builder: (BuildContext context, GetDatabase value, Widget? child) {
      final provider = context.read<GetDatabase>();
      provider.getAllAgentBooks();
      return Column(
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
                          selectedValue: favSelectedValue,
                          onChange: (onValue) {
                            setState(() {
                              provider.getBooks(category: onValue!);
                              favSelectedValue = onValue!;
                              paidSelectedValue = null;
                            });
                          },
                          items: snapshot.data!),
                    ),
                    Visibility(
                      visible: favSelectedValue != null,
                      child: IconButton(
                          onPressed: (() => setState(() {
                                provider.getAllAgentBooks();
                                favSelectedValue = null;
                              })),
                          icon: const Icon(Icons.clear)),
                    )
                  ],
                );
              } else {
                return Card(child: Text(providerLocale.bodyNotFound));
              }
            },
          ),
          Expanded(
              child: StreamBuilder<List<BookModel>?>(
            stream: favSelectedValue != null
                ? provider.bookController.stream
                : provider.allBookAgentController
                    .stream, //provider.getBooks(category: favSelectedValue ?? "Islamic"),
            builder: (BuildContext context,
                AsyncSnapshot<List<BookModel>?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                if (!snapshot.hasData) {
                  return const BookShimmer(indexLength: 10);
                } else {
                  return Center(
                    child: Text(providerLocale.bodyNoData),
                  );
                }
              }
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return LpBookCard(
                          bookModel: snapshot.data![index],
                          isFavorite: true,
                        );
                        //Material(child: Text(snapshot.data![index].book),);
                      }),
                );
              } else {
                return Center(
                  child: Text(providerLocale.bodyNoData),
                );
              }
            },
          )),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: false)
            .localizations;
    final provider = Provider.of<GetDatabase>(context, listen: false);
    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(providerLocale.bodyFavAnPaidBook),
      ),
      body: Column(
        children: [
          _tabBar(providerLocale),
          Expanded(child: _tabView(providerLocale, provider)),
        ],
      ),
    );
  }
}
