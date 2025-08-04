import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/displayvideo/v2.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/Services/auth_services.dart';
import 'package:sboapp/app_model/offline_books_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/services/offline_books/offline_books_provider.dart';

import '../../Constants/shimmer_widgets/home_shimmer.dart';
import '../../Constants/text_style.dart';
import '../presentation/pdf_reader_page.dart';

class OfflineBooks extends StatefulWidget {
  const OfflineBooks({super.key});

  @override
  State<OfflineBooks> createState() => _OfflineBooksState();
}

class _OfflineBooksState extends State<OfflineBooks> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OfflineBooksProvider>(context);

    return ScaffoldWidget(
      appBar: AppBar(
        title: const Text("Offline Books"),
        actions: [
          IconButton(
            onPressed: () => _showClearAllDialog(context, provider),
            icon: const Icon(Icons.cleaning_services),
          ),
        ],
      ),
      body: provider.offlineBooks.isNotEmpty
          ? _buildOfflineBooksList(provider)
          : const Center(child: Text("No Books Offline")),
    );
  }

  Widget _buildOfflineBooksList(OfflineBooksProvider provider) {
    final offlineBooks = provider.offlineBooks
      ..sort((a, b) => b.bookDate.compareTo(a.bookDate));

    return ListView.builder(
      itemCount: offlineBooks.length,
      itemBuilder: (context, index) {
        final book = offlineBooks[index];
        final imageFile = File(book.bookImg);

        return Card.filled(
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.file(imageFile),
            ),
            title: lTitleText(text: book.book),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                lSubTitleText(text: book.author),
                bodyText(text: book.bookLang),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, provider, book),
            ),
            onTap: () => _openBook(context, book),
          ),
        );
      },
    );
  }

  void _showClearAllDialog(
      BuildContext context, OfflineBooksProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: "Clear Offline Books"),
        content: bodyText(text: "Do you want to clear all offline books?"),
        actions: [
          TextButton(
            onPressed: () {
              provider.deleteAllBooks();
              Navigator.pop(context);
            },
            child: const Text("Clear"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, OfflineBooksProvider provider,
      OfflineBooksModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: "Delete Book"),
        content: bodyText(text: "Do you want to delete ${book.book}?"),
        actions: [
          MaterialButton(
            color: Theme.of(context).colorScheme.error,
            onPressed: () {
              provider.deleteBook(book.bookId);
              Navigator.pop(context);
            },
            child: buttonText(text: "Delete"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: buttonText(text: "Cancel"),
          ),
        ],
      ),
    );
  }

  void _openBook(BuildContext context, OfflineBooksModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPage(
          bookLink: book.bookPath,
          title: book.book,
        ),
      ),
    );
  }
}
