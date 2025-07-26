import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/ads/navi_ads.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/book_rating.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/languages_convert.dart';
import 'package:sboapp/constants/short_nums.dart';

import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/screens/users/visit_user_profile.dart';
import 'package:sboapp/screens/presentation/pdf_reader_page.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/pay_book.dart';
import 'package:sboapp/services/reports_function.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

import '../../services/navigate_page_ads.dart';
import '../presentation/pdf_viewer.dart';

class BookInfoView extends StatefulWidget {
  final BookModel? bookModel;
  final String? arCategory;
  const BookInfoView({super.key, this.bookModel, this.arCategory});

  @override
  State<BookInfoView> createState() => _BookInfoViewState();
}

class _BookInfoViewState extends State<BookInfoView> {
  String? agentName;
  final _titleSelected = TextEditingController();
  final _body = TextEditingController();

  double? rating;
  int starCount = 5; // The average rating
  double? myRate;
  final double containerSize = 0.83;
  final double containerAdSize = 0.79;
  final double headerTitle = 0.17;


  bool? isLike;

  @override
  void initState() {
    final isGuest = Provider.of<AuthServices>(context, listen: false).isGuest;
    super.initState();
    final provider = Provider.of<GetDatabase>(context, listen: false)
        .userProfile(uid: widget.bookModel!.user);
    provider.asyncMap((event) => agentName = event.name).listen((event) {});
    isLike = isGuest ? false : widget.bookModel!.likes?[AuthServices().fireAuth.currentUser!.uid]?.like ==  null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = Provider.of<AuthServices>(context).isGuest;
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    Size size = MediaQuery.of(context).size;

    return ScaffoldWidget(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: size.height * 0.65,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                //double ads = isActiveAds ? 0.16 : 0.16;
                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: constraints.biggest.height <= size.height * headerTitle //0.16
                      ? Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: SizedBox(
                              height: size.height * 0.075,
                              child: Card(
                                elevation: 7,
                                //color: Theme.of(context).colorScheme.secondaryContainer,
                                child: SizedBox(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned(
                                            left: providerLocale.language ==
                                                    "العربية"
                                                ? null
                                                : 0,
                                            right: providerLocale.language ==
                                                    "العربية"
                                                ? 0
                                                : null,
                                            child: IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                alignment: Alignment.center,
                                                icon: const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0,
                                                      top: 4.0,
                                                      bottom: 4.0),
                                                  child: Icon(
                                                      Icons.arrow_back_ios),
                                                )),
                                          ),
                                          //backgroundColor: Theme.of(context).colorScheme.surface,
                                          Center(
                                              child: titleText(
                                                  text: providerLocale
                                                      .bodyBookInfo,
                                                  fontSize: 24)),
                                          Positioned(
                                            left: providerLocale.language ==
                                                    "العربية"
                                                ? 0
                                                : null,
                                            right: providerLocale.language ==
                                                    "العربية"
                                                ? null
                                                : 0,
                                            child: GestureDetector(
                                              onTap: isGuest ? null : () {
                                                final provider =
                                                    Provider.of<GetDatabase>(
                                                        context,
                                                        listen: false);
                                                provider.likeActions(
                                                  isLiked:  widget.bookModel!
                                                                  .likes?[
                                                              AuthServices()
                                                                  .fireAuth
                                                                  .currentUser!
                                                                  .uid] ==
                                                          null
                                                      ? false
                                                      : true,
                                                  likes: widget.bookModel!.like,
                                                  category: widget
                                                      .bookModel!.category,
                                                  bookId:
                                                      widget.bookModel!.bookId,
                                                  uid: AuthServices()
                                                      .fireAuth
                                                      .currentUser!
                                                      .uid,
                                                  name: AuthServices()
                                                      .fireAuth
                                                      .currentUser!
                                                      .displayName,
                                                );
                                                setState(() {
                                                  isLike = isLike == null
                                                      ? true
                                                      : !isLike!;
                                                });
                                              },
                                              child: likeAction(),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        )
                      : null,
                  stretchModes: const [
                    StretchMode.fadeTitle,
                  ],
                  background: Hero(
                    tag: widget.bookModel!.book,
                    transitionOnUserGestures: true,
                    child: Image.network(
                      widget.bookModel!.img,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: ShakeY(
                from: 50,
                duration: const Duration(milliseconds: 500),
                child: Transform.translate(
                  offset: const Offset(0, 1),
                  child: Container(

                    height: size.height * 0.03,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2), // shadow color
                          spreadRadius: 0.2, // how wide the shadow spreads
                          blurRadius: 5, // blur effect
                          offset: const Offset(
                              0, -2), // shadow offset upwards (top)
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: size.width * 0.2,
                        height: size.height * 0.015,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                //fade
                Stack(
                  children: [
                    Container(
                      //color: Colors.blue,
                      height: isActiveAds ? size.height * containerAdSize : size.height * containerSize,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 100,
                            spreadRadius: 5,
                            blurStyle: BlurStyle.solid,
                            offset: const Offset(10, 10),
                          ),
                        ],
                      ),
                      child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                        child: Image.network(widget.bookModel!.img, fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,),
                      ),

                    ),
                    Container(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                      height: isActiveAds ? size.height * containerAdSize /*0.79*/ : size.height * containerSize,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    customText(
                                      text: providerLocale.bodyBookTitle,
                                      //style: TextStyle(
                                        //fontSize: 16,
                                        //color: Colors.grey.shade700,
                                      //),
                                    ),

                                    //fade
                                    customText(
                                      text:
                                      widget.bookModel!.book.toUpperCase(),
                                      maxLines: 3,
                                      fontWeight: FontWeight.bold
                                    ),
                                    const SizedBox(height: 10),
                                    customText(
                                      text: widget.bookModel?.translated != null &&
                                              widget.bookModel!.translated!
                                          ? providerLocale.bodyTranslated
                                          : providerLocale.bodyInfoBookAuthor,
                                      //style: TextStyle(
                                        //fontSize: 16,
                                        //color: Colors.grey.shade700,
                                      //),
                                    ),
                                    //fade
                                    customText(
                                      text:
                                      widget.bookModel!.author,
                                      //style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        //fontSize: 18,
                                      //),
                                    )
                                  ],
                                ),
                              ),
                              //fade
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    customText(
                                      text: providerLocale.bodyLblBookPrice,
                                      //color: Colors.grey.shade700
                                      /*style: TextStyle(
                                        fontSize: 16,
                                        //color: Colors.grey.shade700,
                                      ),*/
                                    ),
                                customText(
                                      text: "\$ ${widget.bookModel!.price}",
                                      //style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          //fontSize: 20
                                      //),
                                    ),
                                customText(
                                      text: providerLocale.bodyBookLikes,
                                      //style: TextStyle(
                                        fontSize: 16,
                                        //color: Colors.grey.shade700,
                                      //),
                                    ),
                                customText(
                                      text: shortNum(number: widget.bookModel!.like),
                                      //style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          //fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          //fade
                          customText(
                            text: providerLocale.bodyLblCategory,
                            //style: TextStyle(
                              //fontSize: 16,
                              //color: Colors.grey.shade700,
                            //),
                          ),
                          customText(
                            text: providerLocale.language == "English" ? widget.bookModel!.category : widget.bookModel!.arcategory.toString(),
                            //style: const TextStyle(
                              //fontSize: 18,
                              fontWeight: FontWeight.bold,
                            //),
                          ),
                          SizedBox(height: size.height * 0.01),
                          customText(
                            text: providerLocale.bodyLblLanguage,
                            //style: TextStyle(
                              //fontSize: 16,
                              //color: Colors.grey.shade700,),
                          ),
                          customText(
                            text: convertLang(widget.bookModel!.language, providerLocale),
                            //style: const TextStyle(
                              //fontSize: 18,
                              fontWeight: FontWeight.bold,
                            //),
                          ),
                          SizedBox(height: size.height * 0.01),
                          //new rate
                          _rateAndData(providerLocale),

                          SizedBox(height: size.height * 0.01),
                          customText(
                            text: providerLocale.bodyBookUploader,
                            //style: TextStyle(
                              //fontSize: 16,
                              //color: Colors.grey.shade700,
                            //),
                          ),
                          //fade
                          GestureDetector(
                            onTap: agentName == null
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserProfileBooks(
                                            uid: widget.bookModel!.user))),
                            child: Text(
                              agentName ?? providerLocale.bodyWaiting,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.025),
                          //stated button
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (widget.bookModel!.price <= 0 ||
                                        widget
                                                .bookModel!
                                                .paidUsers?[AuthServices()
                                                    .fireAuth
                                                    .currentUser!
                                                    .uid]
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
                                      if (Provider.of<GetDatabase>(context,
                                                  listen: false)
                                              .subscriber ==
                                          false) {
                                        Provider.of<NavigatePageAds>(context,
                                                listen: false)
                                            .createInterstitialAd();
                                      }
                                    } else {
                                      _showPriceBook(context, providerLocale);
                                    }
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.bookModel!.price <= 0 ||
                                          widget
                                                  .bookModel!
                                                  .paidUsers?[AuthServices()
                                                      .fireAuth
                                                      .currentUser!
                                                      .uid]
                                                  ?.paid ==
                                              true) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ReadingPage(
                                                      /*bookLink: widget.bookModel!.link,
                                                    title: widget.bookModel!.book*/
                                                      bookModel: widget.bookModel,
                                                    )));
                                        if (Provider.of<GetDatabase>(context,
                                                    listen: false)
                                                .subscriber ==
                                            false) {
                                          Provider.of<NavigatePageAds>(context,
                                                  listen: false)
                                              .createInterstitialAd();
                                        }
                                      } else {
                                        _showPriceBook(context, providerLocale);
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        providerLocale.bodyReadNow,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //ended button
                          SizedBox(height: size.height * 0.02),
                          Center(
                            child: InkWell(
                              onTap: () => _reportBook(
                                  context,
                                  widget.bookModel!.img,
                                  widget.bookModel!.book,
                                  widget.bookModel!.author,
                                  providerLocale),
                              child: Text(
                                providerLocale.bodyBookReport,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                child: Text(providerLocale.bodyPayWithGooglePlay),
              ),
              materialButton(
                color: Theme.of(context).colorScheme.primary,
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
                text: providerLocale.bodyPayWithLocale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _rateAndData(providerLocale){
    final isGuest = Provider.of<AuthServices>(context).isGuest;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
      //rate col
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            customText(
            text: providerLocale.bodyBookRate,
          ),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //rate starts
                  booksRating(
                      context: context,
                      rating: rating,
                      bookModel: widget.bookModel),

                  //user rate
                  customText(
                    text: isGuest ? "0.0" : widget
                        .bookModel
                        ?.rates?[AuthServices()
                        .fireAuth
                        .currentUser!
                        .uid]
                        ?.rate ??
                        "0.0",
                    fontWeight: FontWeight.bold,
                    //),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      //rated col
      FittedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              customText(
                text: providerLocale.bodyBookRated,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // star avg
                    const Padding(
                        padding:
                        EdgeInsets.symmetric(
                            horizontal: 4.0),
                        child: Icon(
                          Icons.star,
                          applyTextScaling: true,
                        )),
                    //avg text
                    customText(
                      text: "${customRound(double.parse(widget.bookModel!.averageRate!))}",
                      fontWeight: FontWeight.bold,
                    ),

                    //total person icon
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.person),
                    ),

                    //total persons
                    customText(
                      text: shortNum(
                        number: num.parse(widget.bookModel!
                            .totalRates ??
                            "0"),
                      ).toString(),
                      fontWeight: FontWeight.bold,
                      //),
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      //rows
    ],);
  }

  _reportBook(BuildContext context, String img, String title, String author,
      providerLocale) {
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

/*
  Widget booksRate() {
    final provider = Provider.of<GetDatabase>(context, listen: false);
    return RatingBar.builder(
      initialRating: double.parse(widget
          .bookModel!.rates![AuthServices().fireAuth.currentUser!.uid]!.rate!
          .toString()),
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (newRating) {
        provider.ratingActions(
          isRated: widget.bookModel
                  ?.rates?[AuthServices().fireAuth.currentUser!.uid]?.rate !=
              null,
          totalRates: int.parse(widget.bookModel!.totalRates!.toString()),
          averageRate: double.parse(widget.bookModel!.averageRate!.toString()),
          rate: newRating,
          category: widget.bookModel!.category, // Book category
          bookId: widget.bookModel!.bookId, // Book ID
          uid: AuthServices().fireAuth.currentUser!.uid, // Current user's UID
          username: AuthServices()
              .fireAuth
              .currentUser!
              .displayName, // Current user's display name
        );
        setState(() {
          rating = newRating;
        });
      },
    );
  }

  Widget _userRate() {
    final provider = Provider.of<GetDatabase>(context, listen: false);
    return StarRating(
      size: 30,
      rating: rating ?? double.parse(widget.bookModel!.averageRate!.toString()),
      starCount: starCount,
      onRatingChanged: (newRating) {
        // Call the rating action method from the provider
        provider.ratingActions(
          isRated: widget.bookModel
                  ?.rates?[AuthServices().fireAuth.currentUser!.uid]?.rate !=
              null,
          totalRates: int.parse(widget.bookModel!.totalRates!.toString()),
          averageRate: double.parse(widget.bookModel!.averageRate!.toString()),
          rate: newRating,
          category: widget.bookModel!.category, // Book category
          bookId: widget.bookModel!.bookId, // Book ID
          uid: AuthServices().fireAuth.currentUser!.uid, // Current user's UID
          username: AuthServices()
              .fireAuth
              .currentUser!
              .displayName, // Current user's display name
        );
        setState(() {
          rating = newRating;
        });
        // Update the rating state using a setState of the main widget
      },
    );
  }
*/
  Widget likeAction() {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        final isLiked = widget.bookModel!
                .likes?[AuthServices().fireAuth.currentUser!.uid]?.like ==
            null;
        return Icon(
          isLike ?? isLiked ? CupertinoIcons.heart : CupertinoIcons.heart_fill,
        );
      },
    );
  }
}
