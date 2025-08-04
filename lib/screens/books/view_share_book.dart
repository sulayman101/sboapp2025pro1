import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/Services/get_database.dart';

class BookShareInfoView extends StatefulWidget {
  final String category;
  final String bookId;

  const BookShareInfoView({
    super.key,
    required this.category,
    required this.bookId,
  });

  @override
  State<BookShareInfoView> createState() => _BookShareInfoViewState();
}

class _BookShareInfoViewState extends State<BookShareInfoView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookInfo();
      _showBookInfoBottomSheet();
    });
  }

  void _fetchBookInfo() {
    final getDatabase = Provider.of<GetDatabase>(context, listen: false);
    getDatabase.getLinkBook(category: widget.category, bookId: widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        return StreamBuilder<BookModel?>(
          stream: provider.getLinkBook(
              category: widget.category, bookId: widget.bookId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return Center(child: Text(snapshot.data!.book));
            }
            return const Center(child: Text("Error occurred"));
          },
        );
      },
    );
  }

  void _showBookInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Consumer<GetDatabase>(
          builder: (context, provider, child) {
            return StreamBuilder<BookModel?>(
              stream: provider.getLinkBook(
                  category: widget.category, bookId: widget.bookId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          snapshot.data!.book,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Author: ${snapshot.data!.author}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text("Error occurred"));
              },
            );
          },
        );
      },
    );
  }
}
