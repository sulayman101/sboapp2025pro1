import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/screens/presentation/pdf_reader_page.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/pay_book.dart';
import 'package:sboapp/services/reports_function.dart';
import 'package:sboapp/services/get_database.dart';

import '../services/navigate_page_ads.dart';

class LpBookCard extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isFavorite;
  final BookModel? bookModel;

  const LpBookCard({
    super.key,
    this.onTap,
    required this.isFavorite,
    this.bookModel,
  });

  @override
  State<LpBookCard> createState() => _LpBookCardState();
}

class _LpBookCardState extends State<LpBookCard> {
  final _titleSelected = TextEditingController();
  final _body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!widget.isFavorite || widget.bookModel == null) {
      return const SizedBox.shrink();
    }

    return Material(
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        onTap: () => _handleBookTap(context),
        leading: GestureDetector(
          onTap: () => _viewBookInfo(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(widget.bookModel!.img),
          ),
        ),
        title: lTitleText(text: widget.bookModel!.book.toUpperCase()),
        subtitle: lSubTitleText(text: widget.bookModel!.author),
        trailing: _buildTrailing(),
      ),
    );
  }

  void _handleBookTap(BuildContext context) {
    final isPaid = widget.bookModel!
            .paidUsers?[AuthServices().fireAuth.currentUser!.uid]?.paid ??
        false;

    if (widget.bookModel!.price <= 0 || isPaid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadingPage(
            bookLink: widget.bookModel!.link,
            title: widget.bookModel!.book,
          ),
        ),
      );
      Provider.of<NavigatePageAds>(context, listen: false)
          .createInterstitialAd();
    } else {
      _showPriceBook(context);
    }
  }

  void _showPriceBook(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.4;
    showBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(thickness: 5, indent: size, endIndent: size),
          ExpansionTile(
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            collapsedTextColor: Theme.of(context).colorScheme.primary,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(widget.bookModel!.img, fit: BoxFit.fill),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: lTitleText(text: widget.bookModel!.book)),
                Text("\$ ${widget.bookModel!.price}"),
              ],
            ),
            subtitle: lSubTitleText(text: widget.bookModel!.author),
            children: [
              lTitleText(text: "Id: ${widget.bookModel!.bookId}"),
              lTitleText(text: "Category: ${widget.bookModel!.category}"),
              lTitleText(text: "Posted: ${widget.bookModel!.date}"),
            ],
          ),
          materialButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PayBook(
                    bookTitle: widget.bookModel!.book,
                    bookId: widget.bookModel!.bookId,
                    bookPrice: widget.bookModel!.price,
                  ),
                ),
              );
            },
            text: "Pay",
          ),
        ],
      ),
    );
  }

  void _viewBookInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 3,
        title: Card(
          child: Center(child: titleText(text: "Book Info", fontSize: 19)),
        ),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(widget.bookModel!.img, fit: BoxFit.fill),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${widget.bookModel!.book}"),
                          Text("Author: ${widget.bookModel!.author}"),
                          Text("Category: ${widget.bookModel!.category}"),
                          Text("Likes: ${widget.bookModel!.like}"),
                          Text("Price: ${widget.bookModel!.price}"),
                          Text("Date: ${widget.bookModel!.date}"),
                        ],
                      ),
                    ),
                  ),
                ),
                materialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _reportBook(context);
                  },
                  text: "Report",
                  txtColor: Theme.of(context).colorScheme.onError,
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reportBook(BuildContext context) {
    _titleSelected.text =
        "ID: ${widget.bookModel!.bookId} \nName: ${widget.bookModel!.book}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: titleText(
            text: "Book Report",
            fontSize: 20,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.network(widget.bookModel!.img),
              title: lTitleText(text: widget.bookModel!.book),
              subtitle: lSubTitleText(text: widget.bookModel!.author),
            ),
            MyTextFromField(
              labelText: "Book Info",
              textEditingController: _titleSelected,
              isReadOnly: true,
              hintText: 'Report',
              maxLines: 3,
            ),
            MyTextFromField(
              labelText: "Report description",
              hintText: "Tell us why you report this book",
              textEditingController: _body,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final email = FirebaseAuth.instance.currentUser!.email!;
              final subject = "Reported bookId ${widget.bookModel!.bookId}";
              final body =
                  "Do not change or erase! \n\nUserID: $uid \n\n Email: $email \n\n Title: ${_titleSelected.text} \n\n ${_body.text}";

              if (_body.text.isNotEmpty) {
                ReportFunction()
                    .sendReportEmail(
                  toEmail: "contactus@sboapp.so",
                  subject: subject,
                  body: body,
                )
                    .then((value) {
                  _body.clear();
                  Navigator.pop(context);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please write something or close")),
                );
              }
            },
            child: const Text("Report", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing() {
    final isLiked = widget.bookModel!
            .likes?[AuthServices().fireAuth.currentUser!.uid]?.like !=
        null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            InkWell(
              onTap: () => _toggleLike(),
              child: Icon(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
            ),
            Text(widget.bookModel!.like.toString()),
          ],
        ),
        if (widget.bookModel!.price != 0)
          Column(
            children: [
              const Icon(CupertinoIcons.money_dollar_circle_fill),
              Text(widget.bookModel!.price.toString()),
            ],
          ),
      ],
    );
  }

  void _toggleLike() {
    final provider = Provider.of<GetDatabase>(context, listen: false);
    provider.likeActions(
      isLiked: widget.bookModel!
              .likes?[AuthServices().fireAuth.currentUser!.uid]?.like !=
          null,
      likes: widget.bookModel!.like,
      category: widget.bookModel!.category,
      bookId: widget.bookModel!.bookId,
      uid: AuthServices().fireAuth.currentUser!.uid,
      name: AuthServices().fireAuth.currentUser!.displayName ?? "Guest User",
    );
  }
}
