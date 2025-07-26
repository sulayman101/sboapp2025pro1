

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

  const LpBookCard(
      {super.key,
      this.onTap,
      /*required this.leading, required this.title,  this.price, this.likes,*/ this.bookModel,
      required this.isFavorite});

  @override
  State<LpBookCard> createState() => _LpBookCardState();
}

class _LpBookCardState extends State<LpBookCard> {
  final _titleSelected = TextEditingController();
  final _body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return widget.isFavorite
        ? Material(
            borderRadius: BorderRadius.circular(20),
            child: widget.bookModel!
                        .likes?[AuthServices().fireAuth.currentUser!.uid] !=
                    null
                ? ListTile(
                    onTap: () {
                      if (widget.bookModel!.price <= 0 ||
                          widget
                                  .bookModel!
                                  .paidUsers?[
                                      AuthServices().fireAuth.currentUser!.uid]
                                  ?.paid ==
                              true) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReadingPage(
                                    bookLink: widget.bookModel!.link,
                                    title: widget.bookModel!.book)));
                        Provider.of<NavigatePageAds>(context, listen: false)
                            .createInterstitialAd();
                      } else {
                        _showPriceBook(context);
                      }
                    },
                    leading: GestureDetector(
                        onTap: () {
                          _viewBookInfo(
                              context,
                              widget.bookModel!.book.toUpperCase(),
                              widget.bookModel!.img,
                              widget.bookModel!.author,
                              widget.bookModel!.category,
                              widget.bookModel!.like.toString(),
                              widget.bookModel!.price.toString(),
                              widget.bookModel!.date);
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(widget.bookModel!.img))),
                    title:
                        lTitleText(text: widget.bookModel!.book.toUpperCase()),
                    subtitle: lSubTitleText(text: widget.bookModel!.author),
                    trailing: trailing(),
                  )
                : const Visibility(visible: false, child: SizedBox()))
        : const Visibility(
            visible: false,
            child: SizedBox(),
          );
  }

  _showPriceBook(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.4;
    return showBottomSheet(
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
              child: Image.network(
                widget.bookModel!.img,
                fit: BoxFit.fill,
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
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
                          bookPrice: widget.bookModel!.price)));
            },
            text: "Paid",
          ),
        ],
      ),
    );
  }

  _reportBook(BuildContext context, String img, String title, String author) {
    _titleSelected.text =
        "ID: ${widget.bookModel!.bookId} \nName: ${widget.bookModel!.book}";
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Center(
                child: titleText(
                    text: "Book Report",
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.error),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      leading: Image.network(img),
                      title: lTitleText(text: title),
                      subtitle: lSubTitleText(text: author)),
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
                      final title = _titleSelected.text;
                      final subject =
                          "Reported bookId ${widget.bookModel!.bookId}";
                      final body =
                          "Do not change or erase! \n\nUserID: $uid \n\n Email: $email \n\n title: $title \n\n ${_body.text}";
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
                                content:
                                    Text("Please Write something or close")));
                      }
                    },
                    child: const Text(
                      "Report",
                      style: TextStyle(color: Colors.red),
                    )),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"))
              ],
            ));
  }

  _viewBookInfo(BuildContext context, String title, String img, String author,
      category, String likes, String price, String date) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 3,
              title: Card(
                  child: Center(
                      child: titleText(text: "Book Info", fontSize: 19))),
              content: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          img,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Name: $title"),
                                Text("Author: $author"),
                                Text("Category: $category"),
                                Text("Likes: $likes"),
                                Text("Price: $price"),
                                Text("Date: $date"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      materialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _reportBook(
                                context,
                                widget.bookModel!.img,
                                widget.bookModel!.book.toUpperCase(),
                                widget.bookModel!.author);
                          },
                          text: "Report",
                          txtColor: Theme.of(context).colorScheme.onError,
                          color: Theme.of(context).colorScheme.error),
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget trailing() {
    // ignore: unused_local_variable
    String selectedOption = '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                final provider =
                    Provider.of<GetDatabase>(context, listen: false);
                provider.likeActions(
                  isLiked: widget.bookModel!.likes?[
                              AuthServices().fireAuth.currentUser!.uid] ==
                          null
                      ? false
                      : true,
                  likes: widget.bookModel!.like,
                  category: widget.bookModel!.category,
                  bookId: widget.bookModel!.bookId,
                  uid: AuthServices().fireAuth.currentUser!.uid,
                  name: AuthServices().fireAuth.currentUser!.displayName,
                );
              },
              child: widget.bookModel!
                      .likes![AuthServices().fireAuth.currentUser!.uid]!.like!
                  ? const Icon(CupertinoIcons.heart_fill)
                  : const Icon(CupertinoIcons.heart_fill),
            ),
            Text(widget.bookModel!.like.toString())
          ],
        ),
        Visibility(
          visible: widget.bookModel!.price != 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.money_dollar_circle_fill),
              Text(widget.bookModel!.price.toString())
            ],
          ),
        ),
      ],
    );
  }
}
