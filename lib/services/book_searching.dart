import 'package:flutter/material.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/constants/book_card.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<BookModel> listOfBooks;

  CustomSearchDelegate({required this.listOfBooks});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = _getSearchResults();
    return _buildBookList(searchResults);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchResults = _getSearchResults();
    return _buildBookList(searchResults);
  }

  List<BookModel> _getSearchResults() {
    return query.isEmpty
        ? []
        : listOfBooks
            .where((book) =>
                book.book.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
  }

  Widget _buildBookList(List<BookModel> books) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Visibility(
          visible: book.status == "Public",
          child: BookCard(bookModel: book),
        );
      },
    );
  }
}
