

import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/components/awesome_snackbar.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/languages_convert.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/screens/books/book_view_Info.dart';
import 'package:sboapp/screens/presentation/pdf_reader_page.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/pay_book.dart';
import 'package:sboapp/services/reports_function.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

import '../services/navigate_page_ads.dart';
import '../services/notify_hold_service.dart';

class BookCard extends StatefulWidget {
  final VoidCallback? onTap;
  final BookModel? bookModel;
  final int? isFree;
  final int? lang;
  final String? arCategory;
  final bool? isModify;

  const BookCard(
      {super.key,
      this.onTap,
      this.isModify,
      required this.bookModel,
      this.isFree,
      this.lang,
      this.arCategory});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final _titleSelected = TextEditingController();
  final _body = TextEditingController();
  final DatabaseReference _refDb = FirebaseDatabase.instance.ref(dbName);
  String userRole = "User";

  final double leaderSize = 0.04;

  void getUserRole() async {
    Query query =
        _refDb.child("Users/${AuthServices().fireAuth.currentUser!.uid}");
    DatabaseEvent databaseEvent = await query.once();
    DataSnapshot dataSnapshot = databaseEvent.snapshot;
    if (dataSnapshot.value != null) {
      Object? users = dataSnapshot.value;
      if (users != null && users is Map<dynamic, dynamic>) {
        Map<String, dynamic> usersMap =
            users.map((key, value) => MapEntry(key.toString(), value));
        setState(() {
          userRole = usersMap['role'].toString();
        });
      }
    } else {
      log("No Rows Found");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserRole();
  }

  @override
  Widget build(BuildContext context) {

    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return _bookLang(providerLocale);
  }

  String? agentName;



  Widget _bookLang(providerLocale) {
    if (widget.lang == 0 || widget.lang == null) {
      return _listTitle(providerLocale);
    } else if (widget.lang! == 1 && widget.bookModel!.language == "Somali") {
      return _listTitle(providerLocale);
    } else if (widget.lang! == 2 && widget.bookModel!.language == "Arabic") {
      return _listTitle(providerLocale);
    } else if (widget.lang! == 3 && widget.bookModel!.language == "English") {
      return _listTitle(providerLocale);
    } else {
      return const SizedBox();
    }
  }
//
  Widget _listTitle(providerLocale) {
    final double imgHeight = MediaQuery.of(context).size.height * 0.25;
    //final double? imgWidth = MediaQuery.of(context).size.width * 0.07;
    if (widget.isFree == null || widget.isFree! == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card.filled(
          color:
          userRole == "Admin" && widget.bookModel!.status != "Public"
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          elevation: 5,
          child: ListTile(
            onTap: () {
              if (widget.bookModel!.price <= 0 ||
                  widget
                          .bookModel!
                          .paidUsers?[AuthServices().fireAuth.currentUser!.uid]
                          ?.paid ==
                      true) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReadingPage(
                              /*bookLink: widget.bookModel!.link,
                            title: widget.bookModel!.book,*/
                              bookModel: widget.bookModel,
                            )));
                if (Provider.of<GetDatabase>(context, listen: false).subscriber ==
                    false) {
                  Provider.of<NavigatePageAds>(context, listen: false)
                      .createInterstitialAd();
                }
              } else {
                _showPriceBook(context, providerLocale);
              }
            },
            leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookInfoView(
                                bookModel: widget.bookModel!,
                                arCategory: widget.arCategory,
                              )));
                  //_viewBookInfo(context, providerLocale);
                },
                child: Hero(
                    tag: widget.bookModel!.book,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: ImageNetCache(
                          imageSize: leaderSize,
                          imageUrl: widget.bookModel!.img,
                          height: imgHeight,
                          //width: imgWidth,
                        )))),
            title: lTitleText(text: widget.bookModel!.book.toUpperCase()),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                lSubTitleText(
                    text: widget.bookModel!.translated != null
                        ? "${providerLocale.bodyTranslatedBy} ${widget.bookModel!.author}"
                        : widget.bookModel!.author),
                bodyText(
                    text: convertLang(widget.bookModel!.language, providerLocale)),
              ],
            ),
            trailing: trailing(),
          ),
        ),
      );
    } else {
      if (widget.isFree! == 1 && widget.bookModel!.price <= 1) {
        return ListTile(
          onTap: () {
            if (widget.bookModel!.price <= 0 ||
                widget
                        .bookModel!
                        .paidUsers?[AuthServices().fireAuth.currentUser!.uid]
                        ?.paid ==
                    true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReadingPage(
                            /*bookLink: widget.bookModel!.link,
                            title: widget.bookModel!.book,*/
                            bookModel: widget.bookModel,
                          )));
              if (Provider.of<GetDatabase>(context, listen: true).subscriber ==
                  false) {
                Provider.of<NavigatePageAds>(context, listen: false)
                    .createInterstitialAd();
              }
            } else {
              _showPriceBook(context, providerLocale);
            }
          },
          leading: GestureDetector(
              onTap: () {
                //_viewBookInfo(context, providerLocale);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookInfoView(
                          bookModel: widget.bookModel!,
                          arCategory: widget.arCategory,
                        )));
              },
              child: Hero(
                  tag: widget.bookModel!.book,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ImageNetCache(
                        imageSize: leaderSize,
                        imageUrl: widget.bookModel!.img,
                      )))),
          title: lTitleText(text: widget.bookModel!.book.toUpperCase()),
          subtitle: lSubTitleText(text: widget.bookModel!.author),
          trailing: trailing(),
        );
      } else if (widget.isFree! == 2 && widget.bookModel!.price >= 1) {
        return ListTile(
          onTap: () {
            if (widget.bookModel!.price <= 0 ||
                widget
                        .bookModel!
                        .paidUsers?[AuthServices().fireAuth.currentUser!.uid]
                        ?.paid ==
                    true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReadingPage(
                            /*bookLink: widget.bookModel!.link,
                          title: widget.bookModel!.book,*/
                            bookModel: widget.bookModel,
                          )));
              if (Provider.of<GetDatabase>(context, listen: false).subscriber ==
                  false) {
                Provider.of<NavigatePageAds>(context, listen: false)
                    .createInterstitialAd();
              }
            } else {
              _showPriceBook(context, providerLocale);
            }
          },
          leading: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookInfoView(
                          bookModel: widget.bookModel!,
                          arCategory: widget.arCategory,
                        )));
              },
              child: Hero(
                tag: widget.bookModel!.book,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ImageNetCache(
                      imageSize: leaderSize,
                      imageUrl: widget.bookModel!.img,
                      height: imgHeight,
                      //width: imgWidth,
                    )),
              )),
          title: lTitleText(text: widget.bookModel!.book.toUpperCase()),
          subtitle: lSubTitleText(text: widget.bookModel!.author),
          trailing: trailing(),
        );
      } else {
        return const SizedBox();
      }
    }
  }

  _showPriceBook(BuildContext context, providerLocale) {
    final size = MediaQuery.of(context).size.shortestSide * 0.45;
    return showModalBottomSheet(
      enableDrag: true,
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
              child: ImageNetCache(
                imageSize: leaderSize,
                imageUrl: widget.bookModel!.img,
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
              lTitleText(
                  text:
                      "${providerLocale.bodyBookID}: ${widget.bookModel!.bookId}"),
              lTitleText(
                  text:
                      "${providerLocale.bodyLblCategory}: ${widget.bookModel!.category}"),
              lTitleText(
                  text:
                      "${providerLocale.language}: ${widget.bookModel!.language}"),
              lTitleText(
                  text:
                      "${providerLocale.bodybookPosted}: ${widget.bookModel!.date}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("wait Coming soon...")));
                },
                child: const Text("Pay with Google Play"),
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
                text: "Pay with by hand",
              ),
            ],
          ),
        ],
      ),
    );
  }

  _reportBook(BuildContext context, String img, String title, String author, providerLocale) {
    _titleSelected.text =
        "${providerLocale.bodyBookID} ${widget.bookModel!.bookId} \n${providerLocale.bodyLblTitle}: ${widget.bookModel!.book}";
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Center(
                child: titleText(
                    text: providerLocale.bodyBookReport,
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
                    labelText: providerLocale.bodyBookInfo,
                    textEditingController: _titleSelected,
                    isReadOnly: true,
                    hintText: 'Report',
                    maxLines: 3,
                  ),
                  MyTextFromField(
                    labelText: providerLocale.bodyLblReportDesc,
                    hintText: providerLocale.bodyHintReportDesc,
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
                          "${providerLocale.bodyReported} ${providerLocale.bodyBookID} ${widget.bookModel!.bookId}";
                      final body =
                          "${providerLocale.bodyUserReportNote}! \n\n${providerLocale.bodyUserID}: $uid \n\n ${providerLocale.bodyLblEmail}: $email \n\n ${providerLocale.bodyLblTitle}: $title \n\n ${_body.text}";
                      if (_body.text.isNotEmpty) {
                        ReportFunction()
                            .sendReportEmail(
                          toEmail: "Sanaagebooks@gmail.com",
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
                    child: Text(
                      providerLocale.bodyReport,
                      style: const TextStyle(color: Colors.red),
                    )),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(providerLocale.bodyCancel))
              ],
            ));
  }

  String? selectedStatus;

  Widget trailing() {
    selectedStatus ?? widget.bookModel!.status;
    return widget.isModify != null && widget.isModify!
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case "hide":
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(value)));
                      break;
                    case "update":
                      Navigator.pushNamed(context, "/editBook", arguments: {
                        "bookTitle": widget.bookModel?.book,
                        "bookAuthor": widget.bookModel?.author,
                        "bookPrice": widget.bookModel?.price.toString(),
                        "bookCategory": widget.bookModel?.category,
                        "bookLanguage": widget.bookModel?.language,
                        "isTranslated": widget.bookModel?.translated,
                        "bookCover": widget.bookModel?.img,
                        "bookLink": widget.bookModel?.link,
                        "status": widget.bookModel?.status,
                        "date": widget.bookModel?.date,
                        "bookId": widget.bookModel?.bookId,
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(value)));
                      break;
                    case "privacy":
                      log(userRole.toString());
                      if (widget.bookModel!.user ==
                              AuthServices().fireAuth.currentUser!.uid ||
                          userRole == "Admin" ||
                          userRole == "Owner") {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title:
                                      lTitleText(text: widget.bookModel!.book),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RadioListTile<String>(
                                        title: lTitleText(text: "Public"),
                                        value: "Public",
                                        groupValue: selectedStatus,
                                        selected: selectedStatus == "Public",
                                        onChanged: selectedStatus == "Public"
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  selectedStatus = value!;
                                                });
                                                Provider.of<GetDatabase>(
                                                        context,
                                                        listen: false)
                                                    .updateBookStatus(
                                                  category: widget
                                                      .bookModel!.category,
                                                  bookId:
                                                      widget.bookModel!.bookId,
                                                  status: "Public",
                                                );
                                              },
                                      ),
                                      RadioListTile<String>(
                                        title: lTitleText(text: "Pending"),
                                        value: "Pending",
                                        groupValue: selectedStatus,
                                        selected: selectedStatus == "Pending",
                                        onChanged: selectedStatus == "Pending"
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  selectedStatus = value!;
                                                });
                                                Provider.of<GetDatabase>(
                                                        context,
                                                        listen: false)
                                                    .updateBookStatus(
                                                  category: widget
                                                      .bookModel!.category,
                                                  bookId:
                                                      widget.bookModel!.bookId,
                                                  status: "Pending",
                                                );
                                              },
                                      ),
                                      RadioListTile<String>(
                                        title: lTitleText(text: "Private"),
                                        value: "Private",
                                        groupValue: selectedStatus,
                                        selected: selectedStatus == "Private",
                                        onChanged: selectedStatus == "Private"
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  selectedStatus = value!;
                                                });
                                                Provider.of<GetDatabase>(
                                                        context,
                                                        listen: false)
                                                    .updateBookStatus(
                                                  category: widget
                                                      .bookModel!.category,
                                                  bookId:
                                                      widget.bookModel!.bookId,
                                                  status: "Private",
                                                );
                                              },
                                      ),
                                    ],
                                  ),
                                ));
                      } else {
                        customizedSnackBar(
                            title: "Privacy",
                            message:
                                "$userRole Access denied, you do not have permition!.",
                            contentType: ContentType.failure);
                        ScaffoldMessenger.of(context).showSnackBar(
                            customizedSnackBar(
                                title: "Privacy",
                                message:
                                    "Access denied, you do not have permition!.",
                                contentType: ContentType.failure));
                      }
                    case "resend":
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: titleText(text: "Resend Notification"),
                            content: ListTile(leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: widget.bookModel!.img,),), title: lTitleText(text: widget.bookModel!.book), subtitle: lSubTitleText(text: widget.bookModel!.author),),
                            actions: [
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: buttonText(text: "Cancel")),
                              ElevatedButton(onPressed: (){
                                Navigator.pop(context);
                                Provider.of<NotificationProvider>(context, listen: false).sendNotify(
                                    title: widget.bookModel!.book,
                                    body: widget.bookModel!.author,
                                    imgLink: widget.bookModel!.img,
                                    bookLink: widget.bookModel!.link
                                );
                              }, child: buttonText(text: "Send"))
                            ],
                          ));
                      break;
                    case "delete":
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: titleText(text: "Delete Book"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    lTitleText(text: "Book Name"),
                                    lSubTitleText(text: "Book Author"),
                                  ],
                                ),
                              ));
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  // Defining the options for the popup menu
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'privacy',
                      child: Text('Privicy'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'update',
                      child: Text('Update'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'resend',
                      child: Text('Resend Notify'),
                    ),const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
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
                      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${widget.bookModel!.likes?[AuthServices().fireAuth.currentUser!.uid]!.like}")));
                    },
                    child: widget
                                .bookModel!
                                .likes?[
                                    AuthServices().fireAuth.currentUser!.uid]
                                ?.like !=
                            null
                        ? const Icon(CupertinoIcons.heart_fill)
                        : const Icon(CupertinoIcons.heart),
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