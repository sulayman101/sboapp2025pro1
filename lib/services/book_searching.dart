import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/constants/book_card.dart';

import '../Constants/shimmer_widgets/home_shimmer.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<BookModel> listOfBooks;
  CustomSearchDelegate({required this.listOfBooks});

  @override
  List<Widget> buildActions(BuildContext context) {
    // Build the clear button.
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          // When pressed here the query will be cleared from the search bar.
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
      // Exit from the search screen.
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
    // Build the search results.
    return ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return Visibility(
              visible: searchResults[index].status == "Public",
              child: BookCard(bookModel: searchResults[index]));
        }
        // Exit from the search screen.
        );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final double imgHeight = MediaQuery.of(context).size.height * 0.25;
    final double leaderSize = 0.04;
    // Build the search suggestions.
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
        //log(index.toString());
        return Visibility(
          visible: searchResults[index].status == "Public",
          child:  Card.outlined(child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageNetCache(
                imageSize: leaderSize,
                imageUrl: searchResults[index].img,
                height: imgHeight,
                //width: imgWidth,
              ),
            ),
            isThreeLine: true,
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



//old
/*
class CustomSearchDelegate extends SearchDelegate {
  List<BookModel> searchItems = [];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<BookModel> matchQ = [];
    for (var search in searchItems) {
      if (search.bookModel!.book!.toLowerCase().contains(query.toLowerCase())) {
        matchQ.add(search);
      }
    }
    return ListView.builder(
      itemCount: matchQ.length,
      itemBuilder: (context, index) {
        return BookWidget(
          bookCategory: matchQ[index],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _buildSearch();
    List<BookModel> matchQ = [];
    for (var search in searchItems) {
      if (search.bookModel!.book!.toLowerCase().contains(query.toLowerCase())) {
        matchQ.add(search);
      }
    }
    return ListView.builder(
      itemCount: matchQ.length,
      itemBuilder: (context, index) {
        var result = matchQ[index];
        return ListTile(
          title: Text(result.bookModel!.book!),
        );
      },
    );
  }

  Widget _buildSearch() {

    return StreamBuilder<List<BookModel>>(
      stream: DbServices().getMyBooks(condition: "all"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final Map snapData = snapshot.data!.asMap();
          for (var element in snapData.values) {
            print(element);
            searchItems.add(element);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: searchItems.length,
                  itemBuilder: (context, index) {
                    return BookWidget(
                      bookCategory: searchItems[index],
                    );
                  },
                ),
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return const ListShimmerRow(rows: 8);
      },
    );
  }

  List<BookModel> getSearchItems() {
    return searchItems;
  }
}


 */