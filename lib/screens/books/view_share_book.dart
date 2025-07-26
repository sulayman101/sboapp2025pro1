import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/Services/get_database.dart';

class BookShareInfoView extends StatefulWidget {
  final String category;
  final String bookId;

  const BookShareInfoView(
      {super.key, required this.category, required this.bookId});

  @override
  State<BookShareInfoView> createState() => _BookShareInfoViewState();
}

class _BookShareInfoViewState extends State<BookShareInfoView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Fetch the book info when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final getDatabase = Provider.of<GetDatabase>(context, listen: false);
      getDatabase.getLinkBook(
          category: widget.category,
          bookId: widget.bookId); // Call to load book info
      _showBookInfoBottomSheet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetDatabase>(context, listen: false);
    return StreamBuilder<BookModel>(
      stream: provider.getLinkBook(
          category: widget.category, bookId: widget.bookId),
      builder: (BuildContext context, AsyncSnapshot<BookModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          return Text(snapshot.data!.book);
        } else {
          return const Center(
            child: Text("Error occured"),
          );
        }
      },
    );
  }

  void _showBookInfoBottomSheet() {
    final provider = Provider.of<GetDatabase>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StreamBuilder<BookModel>(
          stream: provider.getLinkBook(
              category: widget.category, bookId: widget.bookId),
          builder: (BuildContext context, AsyncSnapshot<BookModel> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              return Text(snapshot.data!.book);
            } else {
              return const Center(
                child: Text("Error occured"),
              );
            }
          },
        );
      },
    );
  }
}
