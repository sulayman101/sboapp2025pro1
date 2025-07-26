import 'package:flutter/material.dart';
import 'package:sboapp/Constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/Constants/book_card.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<BookModel> listOfBooks;

  CustomSearchDelegate({required this.listOfBooks})
      : super(searchFieldLabel: "Search for books or authors...");

  @override
  List<Widget> buildActions(BuildContext context) {
    // Build the clear button.
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Build the leading icon.
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<BookModel> searchResults = query.isEmpty
        ? []
        : listOfBooks
            .where((item) =>
                item.book.toLowerCase().contains(query.toLowerCase()) ||
                item.author.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return Visibility(
            visible: searchResults[index].status == "Public",
            child: BookCard(
              bookModel: searchResults[index],
              arCategory: searchResults[index].arcategory,
            ));
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final double imgHeight = MediaQuery.of(context).size.height * 0.25;
    final double leaderSize = 0.04;
    final List<BookModel> searchResults = query.isEmpty
        ? []
        : listOfBooks
            .where((item) =>
                item.book.toLowerCase().contains(query.toLowerCase()) ||
                item.author.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return Visibility(
          visible: searchResults[index].status == "Public",
          child: Card.outlined(child: ListTile(
            isThreeLine: true,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageNetCache(
                imageSize: leaderSize,
                imageUrl: searchResults[index].img,
                height: imgHeight,
                //width: imgWidth,
              ),
            ),
            title: Text(searchResults[index].book),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(searchResults[index].author),
                Text(searchResults[index].language),
              ],
            ),
            onTap: () {
              query = searchResults[index].book;
              showResults(
                  context); // Show the results when a suggestion is tapped
            },
          ),)
        );
      },
    );
  }
}
