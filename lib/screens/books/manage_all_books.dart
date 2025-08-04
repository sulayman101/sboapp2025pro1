import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/dropdown_widget.dart';
import 'package:sboapp/constants/book_card.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/services/book_searching.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

class MangeAllBooks extends StatefulWidget {
  const MangeAllBooks({super.key});

  @override
  State<MangeAllBooks> createState() => _MangeAllBooksState();
}

class _MangeAllBooksState extends State<MangeAllBooks> {
  List<BookModel> searchBooks = [];
  int checked = 0;
  int checkedLan = 0;
  final ScrollController _scrollController = ScrollController();
  String? category;
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: const Text("Manage All Books"),
        actions: [
          if (visible)
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
          _buildCategoryDropdown(providerLocale),
          if (visible) _buildFilterRow(providerLocale),
          Expanded(child: _buildBooksList()),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(dynamic providerLocale) {
    final provider = Provider.of<GetDatabase>(context, listen: true);

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
                  selectedValue: category,
                  onChange: (value) {
                    setState(() {
                      provider.getBooks(category: value!);
                      category = value;
                    });
                  },
                  items: snapshot.data!,
                ),
              ),
              if (category != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      provider.getAllAgentBooks();
                      category = null;
                    });
                  },
                  icon: const Icon(Icons.cancel),
                ),
            ],
          );
        }
        return Card(child: Text(providerLocale.bodyNotFound));
      },
    );
  }

  Widget _buildFilterRow(dynamic providerLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
        child: ChoiceChip(
          label: Text(languages[index]),
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

  Widget _buildBooksList() {
    final provider = Provider.of<GetDatabase>(context, listen: true);

    return StreamBuilder<List<BookModel>>(
      stream: category != null
          ? provider.bookController.stream
          : provider.allBookAgentController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          if (category != null) {
            provider.getBooks(category: category!);
          } else {
            provider.getAllAgentBooks();
          }
          return const BookShimmer(indexLength: 10);
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData) {
          final books = snapshot.data!;
          visible = true;
          if (searchBooks.isEmpty) searchBooks.addAll(books);

          return ListView.builder(
            controller: _scrollController,
            itemCount: books.length,
            itemBuilder: (context, index) {
              return BookCard(
                bookModel: books[index],
                isModify: true,
                isFree: checked,
                lang: checkedLan,
              );
            },
          );
        }

        return const Center(child: Text("No Data"));
      },
    );
  }
}
