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
    final providerLocale =
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
                delegate: CustomSearchDelegate(listOfBooks: searchBooks),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLanguageFilter(providerLocale),
          Expanded(child: _buildBooksList(category)),
        ],
      ),
    );
  }

  Widget _buildLanguageFilter(dynamic providerLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._buildLanguageChips(providerLocale),
                ],
              ),
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => checked = value),
            itemBuilder: (context) => _buildPopupMenuItems(providerLocale),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLanguageChips(dynamic providerLocale) {
    final languages = [
      providerLocale.bodyAll,
      providerLocale.bodySomali,
      providerLocale.bodyArabic,
      providerLocale.bodyEnglish,
    ];

    return List.generate(
      languages.length,
      (index) => Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: choiceChipWidget(
          label: languages[index],
          selected: checkedLan == index,
          onSelected: (selected) => setState(() => checkedLan = index),
        ),
      ),
    );
  }

  List<PopupMenuEntry<int>> _buildPopupMenuItems(dynamic providerLocale) {
    final options = [
      providerLocale.bodyAll,
      providerLocale.bodyFree,
      providerLocale.bodyPaid,
    ];

    return List.generate(
      options.length,
      (index) => PopupMenuItem<int>(
        value: index,
        child: Row(
          children: [
            if (checked == index)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.check),
              ),
            buttonText(text: options[index]),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(Map<String, dynamic> category) {
    final provider = Provider.of<GetDatabase>(context, listen: true);

    return StreamBuilder<List<BookModel>>(
      stream: provider.bookController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          provider.getBooks(category: category["category"]);
          return const BookShimmer(indexLength: 10);
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData) {
          final books = snapshot.data!;
          if (searchBooks.isEmpty) searchBooks.addAll(books);

          return ListView.separated(
            controller: _scrollController,
            itemCount: books.length,
            itemBuilder: (context, index) => Visibility(
              visible: books[index].status == "Public",
              child: BookCard(
                bookModel: books[index],
                arCategory: category["lanCategory"],
                isModify: false,
                isFree: checked,
                lang: checkedLan,
              ),
            ),
            separatorBuilder: (context, index) => _buildAdInList(index),
          );
        }

        return const Center(child: Text("No Data"));
      },
    );
  }

  Widget _buildAdInList(int index) {
    return index % 10 == 2 ? const ListAds() : const SizedBox.shrink();
  }
}
