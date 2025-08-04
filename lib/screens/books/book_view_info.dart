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
import 'package:sboapp/services/reports_function.dart'; // Ensure this import exists and is correct
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

import '../../services/navigate_page_ads.dart';
import '../../utils/global_strings.dart';
import '../../utils/short_and_round_num.dart';
import '../../welcome_screen/land_page.dart';
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
  bool? isLike;

  @override
  void initState() {
    super.initState();
    _fetchAgentName();

    // Handle guest users - they can view but not interact
    final isGuest = AuthServices().fireAuth.currentUser == null ||
        AuthServices().fireAuth.currentUser!.isAnonymous;

    isLike = isGuest ? null : widget.bookModel!.likes?[AuthServices().fireAuth.currentUser!.uid]?.like == null;
  }

  void _fetchAgentName() {
    final provider = Provider.of<GetDatabase>(context, listen: false)
        .userProfile(uid: widget.bookModel!.user);
    provider.asyncMap((event) => agentName = event!.name).listen((event) {});
  }

  // Helper method to check if user is guest
  bool get _isGuestUser {
    return AuthServices().fireAuth.currentUser == null ||
        AuthServices().fireAuth.currentUser!.isAnonymous;
  }

  // Helper method to navigate to login
  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingView()),
          (Route<dynamic> route) => false, // remove all routes
    );
  }

  // Helper method to show login prompt
  void _showLoginPrompt(dynamic providerLocale, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(providerLocale.bodyLoginRequired ?? "Login Required"),
        content: Text("${providerLocale.bodyLoginMessage ?? 'Please login to'} $action"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(providerLocale.bodyCancel ?? "Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: Text(providerLocale.bodyLogin ?? "Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    final size = MediaQuery.of(context).size;

    return ScaffoldWidget(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(size, providerLocale),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildBookDetails(size, providerLocale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Size size, dynamic providerLocale) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: size.height * 0.65,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: _buildAppBarTitle(size, providerLocale),
        stretchModes: const [StretchMode.fadeTitle],
        background: Hero(
          tag: widget.bookModel!.book,
          transitionOnUserGestures: true,
          child: Image.network(widget.bookModel!.img, fit: BoxFit.cover),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: _buildBottomAppBar(size),
      ),
    );
  }

  Widget _buildAppBarTitle(Size size, dynamic providerLocale) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.biggest.height <= size.height * 0.17) {
          return Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: _buildAppBarContent(providerLocale),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppBarContent(dynamic providerLocale) {
    return SizedBox(
      height: 50,
      child: Card(
        elevation: 7,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: providerLocale.language == "العربية" ? null : 0,
                right: providerLocale.language == "العربية" ? 0 : null,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ),
              Center(
                  child: titleText(
                      text: providerLocale.bodyBookInfo, fontSize: 24)),
              Positioned(
                left: providerLocale.language == "العربية" ? 0 : null,
                right: providerLocale.language == "العربية" ? null : 0,
                child: GestureDetector(
                  onTap: () => _handleLikeAction(providerLocale),
                  child: likeAction(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAppBar(Size size) {
    return ShakeY(
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                spreadRadius: 0.2,
                blurRadius: 5,
                offset: const Offset(0, -2),
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
    );
  }

  Widget _buildBookDetails(Size size, dynamic providerLocale) {
    return Stack(
      children: [
        _buildBlurredBackground(size),
        _buildBookInfoContent(size, providerLocale),
      ],
    );
  }

  Widget _buildBlurredBackground(Size size) {
    return Container(
      height: size.height * 0.83,
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
        child: Image.network(widget.bookModel!.img, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildBookInfoContent(Size size, dynamic providerLocale) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
      height: size.height * 0.83,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookHeader(providerLocale),
          SizedBox(height: size.height * 0.01),
          _buildBookDetailsRow(providerLocale),
          SizedBox(height: size.height * 0.01),
          _buildBookRate(providerLocale),
          SizedBox(height: size.height * 0.01),
          _buildUploaderInfo(providerLocale),
          SizedBox(height: size.height * 0.025),
          _buildReadNowButton(providerLocale),
          SizedBox(height: size.height * 0.02),
          _buildReportButton(providerLocale),
        ],
      ),
    );
  }

  Widget _buildBookHeader(dynamic providerLocale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(text: providerLocale.bodyBookTitle),
              customText(
                  text: widget.bookModel!.book.toUpperCase(),
                  fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              customText(
                text: widget.bookModel?.translated == true
                    ? providerLocale.bodyTranslated
                    : providerLocale.bodyInfoBookAuthor,
              ),
              customText(
                  text: widget.bookModel!.author, fontWeight: FontWeight.bold),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              customText(text: providerLocale.bodyLblBookPrice),
              customText(
                  text: "\$ ${widget.bookModel!.price}",
                  fontWeight: FontWeight.bold),
              customText(text: providerLocale.bodyBookLikes),
              customText(
                  text: shortNum(number: widget.bookModel!.like),
                  fontWeight: FontWeight.bold),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookDetailsRow(dynamic providerLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(text: providerLocale.bodyLblCategory),
        customText(
          text: providerLocale.language == "English"
              ? widget.bookModel!.category
              : widget.bookModel!.arcategory.toString(),
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 10),
        customText(text: providerLocale.bodyLblLanguage),
        customText(
          text: convertLang(widget.bookModel!.language, providerLocale),
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget _buildUploaderInfo(dynamic providerLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(text: providerLocale.bodyBookUploader),
        GestureDetector(
          onTap: () {
            if (_isGuestUser) {
              _showLoginPrompt(providerLocale, providerLocale.bodyViewProfile ?? "view profile");
              return;
            }
            if (agentName != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileBooks(uid: widget.bookModel!.user),
                ),
              );
            }
          },
          child: Text(
            agentName ?? providerLocale.bodyWaiting,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadNowButton(dynamic providerLocale) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _handleReadNowAction(providerLocale),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _isGuestUser
                    ? "${providerLocale.bodyReadNow} (${providerLocale.bodyLoginRequired ?? 'Login Required'})"
                    : providerLocale.bodyReadNow,
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
      ],
    );
  }

  // Helper method to build rating stars safely
  Widget _buildRatingStars() {
    if (_isGuestUser) {
      // Show read-only stars for guests
      final rating = double.tryParse(widget.bookModel!.averageRate ?? "0.0") ?? 0.0;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          );
        }),
      );
    }

    // For authenticated users, try to use the original booksRating function
    // but wrap it in a try-catch to handle any null pointer exceptions
    try {
      return booksRating(bookModel: widget.bookModel!, context: context);
    } catch (e) {
      // Fallback to read-only stars if there's an error
      final rating = double.tryParse(widget.bookModel!.averageRate ?? "0.0") ?? 0.0;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          );
        }),
      );
    }
  }

  Widget _buildBookRate(dynamic providerLocale) {
    // Get current user ID safely
    final currentUserId = _isGuestUser ? null : AuthServices().fireAuth.currentUser?.uid;

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
              bodyText(
                text: "Book Rate",
              ),
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //rate starts - Modified for guest users
                    GestureDetector(
                      onTap: () {
                        if (_isGuestUser) {
                          _showLoginPrompt(providerLocale, providerLocale.bodyRateBook ?? "rate this book");
                          return;
                        }
                        // Show rating dialog for authenticated users
                        booksRating(bookModel: widget.bookModel!, context: context);
                      },
                      child: _buildRatingStars(),
                    ),

                    //user rate
                    bodyText(
                      text: _isGuestUser || currentUserId == null
                          ? "0.0"
                          : widget.bookModel?.rates?[currentUserId]?.rate ?? "0.0",
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
                bodyText(
                  text: "Book Rated",
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
                      bodyText(
                        text: roundRateAvg(rated:
                        widget.bookModel!.averageRate!),
                        //fontWeight: FontWeight.bold,
                      ),

                      //total person icon
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(Icons.person),
                      ),

                      //total persons
                      bodyText(
                        text: shorNumCount(
                          number: num.parse(widget.bookModel!
                              .totalRates ??
                              "0"),
                        ).toString(),
                        //fontWeight: FontWeight.bold,
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

  Widget _buildReportButton(dynamic providerLocale) {
    return Center(
      child: InkWell(
        onTap: () => _handleReportAction(providerLocale),
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
    );
  }

  // Handle like action - redirect guests to login
  void _handleLikeAction(dynamic providerLocale) {
    if (_isGuestUser) {
      _showLoginPrompt(providerLocale, providerLocale.bodyLikeBook ?? "like this book");
      return;
    }
    _toggleLike();
  }

  // Handle read now action - redirect guests to login
  void _handleReadNowAction(dynamic providerLocale) {
    if (_isGuestUser) {
      _showLoginPrompt(providerLocale, providerLocale.bodyReadBook ?? "read this book");
      return;
    }

    final currentUser = AuthServices().fireAuth.currentUser;
    if (currentUser == null) {
      _showLoginPrompt(providerLocale, providerLocale.bodyReadBook ?? "read this book");
      return;
    }

    // Original read now logic for authenticated users
    if (widget.bookModel!.price <= 0 ||
        widget.bookModel!.paidUsers?[currentUser.uid]?.paid == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadingPage(bookModel: widget.bookModel),
        ),
      );
      if (!Provider.of<GetDatabase>(context, listen: false).subscriber) {
        Provider.of<NavigatePageAds>(context, listen: false).createInterstitialAd();
      }
    } else {
      _showPriceBook(context, providerLocale);
    }
  }

  // Handle report action - redirect guests to login
  void _handleReportAction(dynamic providerLocale) {
    if (_isGuestUser) {
      _showLoginPrompt(providerLocale, providerLocale.bodyReportBook ?? "report this book");
      return;
    }

    _reportBook(
      context,
      widget.bookModel!.img,
      widget.bookModel!.book,
      widget.bookModel!.author,
      providerLocale,
    );
  }

  void _toggleLike() {
    // Double-check authentication
    if (_isGuestUser) return;

    final currentUser = AuthServices().fireAuth.currentUser;
    if (currentUser == null) return;

    final provider = Provider.of<GetDatabase>(context, listen: false);
    provider.likeActions(
      isLiked: widget.bookModel!.likes?[currentUser.uid]?.like != null,
      likes: widget.bookModel!.like,
      category: widget.bookModel!.category,
      bookId: widget.bookModel!.bookId,
      uid: currentUser.uid,
      name: currentUser.displayName ?? "Guest User",
    );
    setState(() {
      isLike = isLike == null ? true : !isLike!;
    });
  }

  void _reportBook(BuildContext context, String img, String book, String author,
      dynamic providerLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(providerLocale.bodyReportTitle),
        content: Text(providerLocale.bodyReportMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(providerLocale.bodyCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final reportsFunction = ReportFunction();
              reportsFunction.sendReportEmail(
                  toEmail: "contactus@sboapp.so",
                  body: book,
                  subject:
                  "Report ${widget.bookModel!.book} - ${widget.bookModel!.bookId}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(providerLocale.bodyReportSuccess)),
              );
            },
            child: Text(providerLocale.bodyConfirm),
          ),
        ],
      ),
    );
  }

  Widget likeAction() {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        if (_isGuestUser) {
          // Show empty heart for guests
          return Icon(
            CupertinoIcons.heart,
            color: Colors.grey.shade600,
          );
        }

        // Safely get current user ID
        final currentUserId = AuthServices().fireAuth.currentUser?.uid;
        if (currentUserId == null) {
          return Icon(
            CupertinoIcons.heart,
            color: Colors.grey.shade600,
          );
        }

        final isLiked = widget.bookModel!.likes?[currentUserId]?.like == null;
        return Icon(isLike ?? isLiked
            ? CupertinoIcons.heart
            : CupertinoIcons.heart_fill);
      },
    );
  }

  void _showPriceBook(BuildContext context, dynamic providerLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(providerLocale.bodyBookPrice),
        content: Text(
          "${providerLocale.bodyBookPriceMessage} \$${widget.bookModel!.price}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(providerLocale.bodyCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logic for purchasing the book here
            },
            child: Text(providerLocale.bodyBuyNow),
          ),
        ],
      ),
    );
  }
}

// import 'dart:ui';
//
// import 'package:animate_do/animate_do.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sboapp/ads/navi_ads.dart';
// import 'package:sboapp/app_model/book_model.dart';
// import 'package:sboapp/components/ads_and_net.dart';
// import 'package:sboapp/constants/book_rating.dart';
// import 'package:sboapp/constants/button_style.dart';
// import 'package:sboapp/constants/languages_convert.dart';
// import 'package:sboapp/constants/short_nums.dart';
//
// import 'package:sboapp/constants/text_form_field.dart';
// import 'package:sboapp/constants/text_style.dart';
// import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
// import 'package:sboapp/screens/users/visit_user_profile.dart';
// import 'package:sboapp/screens/presentation/pdf_reader_page.dart';
// import 'package:sboapp/services/auth_services.dart';
// import 'package:sboapp/services/pay_book.dart';
// import 'package:sboapp/services/reports_function.dart'; // Ensure this import exists and is correct
// import 'package:sboapp/services/lan_services/language_provider.dart';
// import 'package:sboapp/services/get_database.dart';
//
// import '../../services/navigate_page_ads.dart';
// import '../../utils/global_strings.dart';
// import '../../utils/short_and_round_num.dart';
// import '../../welcome_screen/land_page.dart';
// import '../presentation/pdf_viewer.dart';
//
// class BookInfoView extends StatefulWidget {
//   final BookModel? bookModel;
//   final String? arCategory;
//
//   const BookInfoView({super.key, this.bookModel, this.arCategory});
//
//   @override
//   State<BookInfoView> createState() => _BookInfoViewState();
// }
//
// class _BookInfoViewState extends State<BookInfoView> {
//   String? agentName;
//   final _titleSelected = TextEditingController();
//   final _body = TextEditingController();
//   bool? isLike;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAgentName();
//
//     isLike = AuthServices().fireAuth.currentUser != null ? widget.bookModel!.likes![AuthServices().fireAuth.currentUser!.uid]
//             ?.like == null : null;
//   }
//
//   void _fetchAgentName() {
//     final provider = Provider.of<GetDatabase>(context, listen: false)
//         .userProfile(uid: widget.bookModel!.user);
//     provider.asyncMap((event) => agentName = event.name).listen((event) {});
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final providerLocale =
//         Provider.of<AppLocalizationsNotifier>(context, listen: true)
//             .localizations;
//     final size = MediaQuery.of(context).size;
//
//     return ScaffoldWidget(
//       body: CustomScrollView(
//         slivers: [
//           _buildSliverAppBar(size, providerLocale),
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 _buildBookDetails(size, providerLocale),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSliverAppBar(Size size, dynamic providerLocale) {
//     return SliverAppBar(
//       automaticallyImplyLeading: false,
//       expandedHeight: size.height * 0.65,
//       flexibleSpace: FlexibleSpaceBar(
//         centerTitle: true,
//         title: _buildAppBarTitle(size, providerLocale),
//         stretchModes: const [StretchMode.fadeTitle],
//         background: Hero(
//           tag: widget.bookModel!.book,
//           transitionOnUserGestures: true,
//           child: Image.network(widget.bookModel!.img, fit: BoxFit.cover),
//         ),
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: _buildBottomAppBar(size),
//       ),
//     );
//   }
//
//   Widget _buildAppBarTitle(Size size, dynamic providerLocale) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.biggest.height <= size.height * 0.17) {
//           return Align(
//             alignment: Alignment.center,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 15.0),
//               child: _buildAppBarContent(providerLocale),
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }
//
//   Widget _buildAppBarContent(dynamic providerLocale) {
//     return SizedBox(
//       height: 50,
//       child: Card(
//         elevation: 7,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Positioned(
//                 left: providerLocale.language == "العربية" ? null : 0,
//                 right: providerLocale.language == "العربية" ? 0 : null,
//                 child: IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.arrow_back_ios),
//                 ),
//               ),
//               Center(
//                   child: titleText(
//                       text: providerLocale.bodyBookInfo, fontSize: 24)),
//               Positioned(
//                 left: providerLocale.language == "العربية" ? 0 : null,
//                 right: providerLocale.language == "العربية" ? null : 0,
//                 child: GestureDetector(
//                   onTap: _toggleLike,
//                   child: likeAction(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomAppBar(Size size) {
//     return ShakeY(
//       from: 50,
//       duration: const Duration(milliseconds: 500),
//       child: Transform.translate(
//         offset: const Offset(0, 1),
//         child: Container(
//           height: size.height * 0.03,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(30),
//               topRight: Radius.circular(30),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
//                 spreadRadius: 0.2,
//                 blurRadius: 5,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Container(
//               width: size.width * 0.2,
//               height: size.height * 0.015,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade500,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookDetails(Size size, dynamic providerLocale) {
//     return Stack(
//       children: [
//         _buildBlurredBackground(size),
//         _buildBookInfoContent(size, providerLocale),
//       ],
//     );
//   }
//
//   Widget _buildBlurredBackground(Size size) {
//     return Container(
//       height: size.height * 0.83,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.white.withOpacity(0.1),
//             blurRadius: 100,
//             spreadRadius: 5,
//             blurStyle: BlurStyle.solid,
//             offset: const Offset(10, 10),
//           ),
//         ],
//       ),
//       child: ImageFiltered(
//         imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
//         child: Image.network(widget.bookModel!.img, fit: BoxFit.cover),
//       ),
//     );
//   }
//
//   Widget _buildBookInfoContent(Size size, dynamic providerLocale) {
//     return Container(
//       color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
//       height: size.height * 0.83,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildBookHeader(providerLocale),
//           SizedBox(height: size.height * 0.01),
//           _buildBookDetailsRow(providerLocale),
//           SizedBox(height: size.height * 0.01),
//           _buildBookRate(),
//           SizedBox(height: size.height * 0.01),
//           _buildUploaderInfo(providerLocale),
//           SizedBox(height: size.height * 0.025),
//           _buildReadNowButton(providerLocale),
//           SizedBox(height: size.height * 0.02),
//           _buildReportButton(providerLocale),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBookHeader(dynamic providerLocale) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           flex: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               customText(text: providerLocale.bodyBookTitle),
//               customText(
//                   text: widget.bookModel!.book.toUpperCase(),
//                   fontWeight: FontWeight.bold),
//               const SizedBox(height: 10),
//               customText(
//                 text: widget.bookModel?.translated == true
//                     ? providerLocale.bodyTranslated
//                     : providerLocale.bodyInfoBookAuthor,
//               ),
//               customText(
//                   text: widget.bookModel!.author, fontWeight: FontWeight.bold),
//             ],
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Column(
//             children: [
//               customText(text: providerLocale.bodyLblBookPrice),
//               customText(
//                   text: "\$ ${widget.bookModel!.price}",
//                   fontWeight: FontWeight.bold),
//               customText(text: providerLocale.bodyBookLikes),
//               customText(
//                   text: shortNum(number: widget.bookModel!.like),
//                   fontWeight: FontWeight.bold),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBookDetailsRow(dynamic providerLocale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         customText(text: providerLocale.bodyLblCategory),
//         customText(
//           text: providerLocale.language == "English"
//               ? widget.bookModel!.category
//               : widget.bookModel!.arcategory.toString(),
//           fontWeight: FontWeight.bold,
//         ),
//         SizedBox(height: 10),
//         customText(text: providerLocale.bodyLblLanguage),
//         customText(
//           text: convertLang(widget.bookModel!.language, providerLocale),
//           fontWeight: FontWeight.bold,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildUploaderInfo(dynamic providerLocale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         customText(text: providerLocale.bodyBookUploader),
//         GestureDetector(
//           onTap: agentName == null
//               ? null
//               : () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           UserProfileBooks(uid: widget.bookModel!.user),
//                     ),
//                   ),
//           child: Text(
//             agentName ?? providerLocale.bodyWaiting,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildReadNowButton(dynamic providerLocale) {
//     final isGuest = Provider.of<AuthServices>(context).isGuest;
//     return Row(
//       children: [
//         Expanded(
//           child: InkWell(
//             onTap: () {
//               if (widget.bookModel!.price <= 0 ||
//                   widget
//                           .bookModel!
//                           .paidUsers?[AuthServices().fireAuth.currentUser!.uid]
//                           ?.paid ==
//                       true && !isGuest) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         ReadingPage(bookModel: widget.bookModel),
//                   ),
//                 );
//                 if (!Provider.of<GetDatabase>(context, listen: false)
//                     .subscriber) {
//                   Provider.of<NavigatePageAds>(context, listen: false)
//                       .createInterstitialAd();
//                 }
//               } else {
//                 _showPriceBook(context, providerLocale);
//               }
//             },
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Text(
//                 providerLocale.bodyReadNow,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBookRate() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         //rate col
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               bodyText(
//                 text: "Book Rate",
//               ),
//               FittedBox(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     //rate starts
//                     booksRating(
//
//                         bookModel: widget.bookModel!, context: context),
//
//                     //user rate
//                     bodyText(
//                       text: widget
//                           .bookModel
//                           ?.rates?[myUid]
//                           ?.rate ??
//                           "0.0",
//                       //fontWeight: FontWeight.bold,
//                       //),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         //rated col
//         FittedBox(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 bodyText(
//                   text: "Book Rated",
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       // star avg
//                       const Padding(
//                           padding:
//                           EdgeInsets.symmetric(
//                               horizontal: 4.0),
//                           child: Icon(
//                             Icons.star,
//                             applyTextScaling: true,
//                           )),
//                       //avg text
//                       bodyText(
//                         text: roundRateAvg(rated:
//                         widget.bookModel!.averageRate!),
//                         //fontWeight: FontWeight.bold,
//                       ),
//
//                       //total person icon
//                       const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 4.0),
//                         child: Icon(Icons.person),
//                       ),
//
//                       //total persons
//                       bodyText(
//                         text: shorNumCount(
//                           number: num.parse(widget.bookModel!
//                               .totalRates ??
//                               "0"),
//                         ).toString(),
//                         //fontWeight: FontWeight.bold,
//                         //),
//                       ),
//
//                     ],
//                   ),
//                 ),
//
//               ],
//             ),
//           ),
//         ),
//         //rows
//       ],);
//   }
//
//
//   Widget _buildReportButton(dynamic providerLocale) {
//     return Center(
//       child: InkWell(
//         onTap: () {
//           final isGuest = Provider.of<AuthServices>(context).isGuest;
//           if(isGuest){
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => const OnboardingView()),
//                   (Route<dynamic> route) => false, // remove all routes
//             );
//           }
//               _reportBook(
//                 context,
//                 widget.bookModel!.img,
//                 widget.bookModel!.book,
//                 widget.bookModel!.author,
//                 providerLocale,
//               );
//         },
//         child: Text(
//           providerLocale.bodyBookReport,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//             color: Theme.of(context).colorScheme.error,
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _toggleLike() {
//     final provider = Provider.of<GetDatabase>(context, listen: false);
//     provider.likeActions(
//       isLiked: widget.bookModel!
//               .likes?[AuthServices().fireAuth.currentUser!.uid]?.like !=
//           null,
//       likes: widget.bookModel!.like,
//       category: widget.bookModel!.category,
//       bookId: widget.bookModel!.bookId,
//       uid: AuthServices().fireAuth.currentUser!.uid,
//       name: AuthServices().fireAuth.currentUser!.displayName,
//     );
//     setState(() {
//       isLike = isLike == null ? true : !isLike!;
//     });
//   }
//
//   void _reportBook(BuildContext context, String img, String book, String author,
//       dynamic providerLocale) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(providerLocale.bodyReportTitle),
//         content: Text(providerLocale.bodyReportMessage),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(providerLocale.bodyCancel),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               final isGuest = Provider.of<AuthServices>(context).isGuest;
//               if(isGuest ){
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const OnboardingView()),
//                       (Route<dynamic> route) => false, // remove all routes
//                 );
//               }
//               final reportsFunction =
//                   ReportFunction(); // Ensure ReportsFunction is a valid class
//               reportsFunction.sendReportEmail(
//                   toEmail: "contactus@sboapp.so",
//                   body: book,
//                   subject:
//                       "Report ${widget.bookModel!.book} - ${widget.bookModel!.bookId}");
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(providerLocale.bodyReportSuccess)),
//               );
//             },
//             child: Text(providerLocale.bodyConfirm),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget likeAction() {
//     return Consumer<GetDatabase>(
//       builder: (context, provider, child) {
//         final isGuest = Provider.of<AuthServices>(context).isGuest;
//         if(isGuest){
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => const OnboardingView()),
//                 (Route<dynamic> route) => false, // remove all routes
//           );
//         }
//         final isLiked = widget.bookModel!
//                 .likes?[AuthServices().fireAuth.currentUser!.uid]?.like ==
//             null;
//         return Icon(isLike ?? isLiked
//             ? CupertinoIcons.heart
//             : CupertinoIcons.heart_fill);
//       },
//     );
//   }
//
//   void _showPriceBook(BuildContext context, dynamic providerLocale) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(providerLocale.bodyBookPrice),
//         content: Text(
//           "${providerLocale.bodyBookPriceMessage} \$${widget.bookModel!.price}",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(providerLocale.bodyCancel),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Add logic for purchasing the book here
//             },
//             child: Text(providerLocale.bodyBuyNow),
//           ),
//         ],
//       ),
//     );
//   }
// }
