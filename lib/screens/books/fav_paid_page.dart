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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: false)
            .localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(providerLocale.bodyFavAnPaidBook),
      ),
      body: Column(
        children: [
          _buildTabBar(providerLocale),
          Expanded(child: _buildTabView(providerLocale)),
        ],
      ),
    );
  }

  Widget _buildTabBar(dynamic providerLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TabBar(
        controller: _tabController,
        unselectedLabelColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        tabs: [
          Tab(text: providerLocale.bodyFavorite),
          Tab(text: providerLocale.bodySold),
        ],
      ),
    );
  }

  Widget _buildTabView(dynamic providerLocale) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFavoritesTab(providerLocale),
        _buildPaidBooksTab(providerLocale),
      ],
    );
  }

  Widget _buildFavoritesTab(dynamic providerLocale) {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        provider.getAllAgentBooks();
        return Column(
          children: [
            _buildCategoryDropdown(
              providerLocale: providerLocale,
              selectedValue: favSelectedValue,
              onChange: (value) {
                setState(() {
                  provider.getBooks(category: value!);
                  favSelectedValue = value;
                  paidSelectedValue = null;
                });
              },
              onClear: () {
                setState(() {
                  provider.getAllAgentBooks();
                  favSelectedValue = null;
                });
              },
            ),
            Expanded(
              child: _buildBookList(
                provider: provider,
                stream: favSelectedValue != null
                    ? provider.bookController.stream
                    : provider.allBookAgentController.stream,
                isFavorite: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaidBooksTab(dynamic providerLocale) {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildCategoryDropdown(
              providerLocale: providerLocale,
              selectedValue: paidSelectedValue,
              onChange: (value) {
                setState(() {
                  provider.getBooks(category: value!);
                  paidSelectedValue = value;
                  favSelectedValue = null;
                });
              },
              onClear: () {
                setState(() {
                  provider.getAllAgentBooks();
                  paidSelectedValue = null;
                });
              },
            ),
            Expanded(
              child: _buildBookList(
                provider: provider,
                stream: provider.bookController.stream,
                isFavorite: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryDropdown({
    required dynamic providerLocale,
    required String? selectedValue,
    required void Function(String?) onChange,
    required VoidCallback onClear,
  }) {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        return StreamBuilder<List<MyCategories>>(
          stream: provider.getCategories(),
          builder: (context, snapshot) {
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
                      selectedValue: selectedValue,
                      onChange: onChange,
                      items: snapshot.data!,
                    ),
                  ),
                  if (selectedValue != null)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear),
                    ),
                ],
              );
            }
            return Card(child: Text(providerLocale.bodyNotFound));
          },
        );
      },
    );
  }

  Widget _buildBookList({
    required GetDatabase provider,
    required Stream<List<BookModel>?> stream,
    required bool isFavorite,
  }) {
    return StreamBuilder<List<BookModel>?>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BookShimmer(indexLength: 10);
        }
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return LpBookCard(
                bookModel: snapshot.data![index],
                isFavorite: isFavorite,
              );
            },
          );
        }
        return const Center(child: Text("No Data"));
      },
    );
  }
}
