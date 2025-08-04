
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/constants/languages_convert.dart';
import 'package:sboapp/constants/short_nums.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/screens/books/book_view_Info.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

class HomeRowsList extends StatefulWidget {
  final String bookCategory;
  final String lanCategory;
  final VoidCallback onTap;

  const HomeRowsList({
    super.key,
    required this.bookCategory,
    required this.lanCategory,
    required this.onTap,
  });

  @override
  State<HomeRowsList> createState() => _HomeRowsListState();
}

class _HomeRowsListState extends State<HomeRowsList>
    with AutomaticKeepAliveClientMixin {

  // Stream subscription to manage memory
  StreamSubscription<List<BookModel>>? _booksStreamSubscription;

  // Database instance - reuse instead of creating new instances
  late GetDatabase _database;

  // Cached locale data to avoid repeated lookups
  late AppLocalizationsNotifier _localeNotifier;

  // Number formatter cache to avoid recreation
  late Map<String, NumberFormat> _formatters;

  // Cached size to avoid repeated MediaQuery calls
  Size? _cachedSize;

  @override
  bool get wantKeepAlive => true; // Keep the state alive for better performance

  @override
  void initState() {
    super.initState();

    // Initialize database instance once
    _database = context.read<GetDatabase>();

    // Initialize locale notifier once
    _localeNotifier = context.read<AppLocalizationsNotifier>();

    // Initialize formatter cache
    _formatters = <String, NumberFormat>{};
  }

  @override
  void dispose() {
    // Cancel stream subscription to prevent memory leaks
    _booksStreamSubscription?.cancel();

    // Clear formatter cache
    _formatters.clear();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the size to avoid repeated MediaQuery calls
    _cachedSize = MediaQuery.of(context).size;
  }

  // Optimized number conversion with caching
  String _convertNumber({required num number, required String languageCode}) {
    // Use cached formatter or create new one
    _formatters[languageCode] ??= NumberFormat.decimalPattern(languageCode);
    return _formatters[languageCode]!.format(number);
  }

  // Safe navigation method that checks if widget is mounted
  void _navigateToBookInfo(BookModel book) {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookInfoView(
          bookModel: book,
          arCategory: widget.lanCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Use cached locale data
    final providerLocale = _localeNotifier.localizations;
    final Size size = _cachedSize ?? MediaQuery.of(context).size;

    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<BookModel>>(
            stream: _database.getTopBooks(category: widget.bookCategory),
            builder: (BuildContext context, AsyncSnapshot<List<BookModel>> snapshot) {
              // Handle different connection states properly
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return HomeRowsShimmer(bookCategory: widget.lanCategory);
              }

              if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString(), providerLocale);
              }

              if (snapshot.hasData && snapshot.data != null) {
                final books = snapshot.data!;
                return _buildBookList(books, size, providerLocale);
              }

              return _buildEmptyWidget(providerLocale);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error, dynamic providerLocale) {
    return SizedBox(
      height: _cachedSize!.height * 0.53,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading books: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {}); // Trigger rebuild
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(dynamic providerLocale) {
    return SizedBox(
      height: _cachedSize!.height * 0.53,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              providerLocale.bodyNotFound ?? 'No books found',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(List<BookModel> books, Size size, dynamic providerLocale) {
    // Filter public books once instead of in each card build
    final publicBooks = books.where((book) => book.status == "Public").toList();

    if (publicBooks.isEmpty) {
      return _buildEmptyWidget(providerLocale);
    }

    return SizedBox(
      height: size.height * 0.53,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(size, providerLocale),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Add physics for better scrolling performance
              physics: const BouncingScrollPhysics(),
              // Optimize for performance
              cacheExtent: 500,
              itemCount: publicBooks.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < publicBooks.length) {
                  return _buildBookCard(publicBooks[index], size, providerLocale);
                } else {
                  return _buildSeeMoreButton(providerLocale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(Size size, dynamic providerLocale) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: titleText(
                text: widget.lanCategory,
                fontSize: kDefaultFontSize * 1.5,
              ),
            ),
            const Icon(Icons.arrow_forward_ios_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BookModel book, Size size, dynamic providerLocale) {
    return GestureDetector(
      onTap: () => _navigateToBookInfo(book),
      child: Hero(
        tag: '${book.book}_${widget.bookCategory}', // Make hero tag unique
        child: Card.filled(
          // Add margin for better spacing
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: size.width * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Optimize layout
                children: [
                  _buildBookImage(book.img ?? '', size),
                  const SizedBox(height: 8),
                  _buildBookTitle(book.book ?? 'Unknown Title'),
                  const SizedBox(height: 4),
                  _buildBookAuthor(book.author ?? 'Unknown Author'),
                  const SizedBox(height: 4),
                  _buildBookDetailsRow(book, providerLocale),
                  const SizedBox(height: 4),
                  _buildBookStatsRow(book),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBookAuthor(String author) {
    return Text(
      author,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBookImage(String imageUrl, Size size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl.isNotEmpty
            ? ImageNetCache(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: size.width * 0.4,
          height: size.height * 0.25,
          errorWidget: _buildImageErrorWidget(size),
        )
            : _buildImageErrorWidget(size),
      ),
    );
  }

  Widget _buildImageErrorWidget(Size size) {
    return Container(
      width: size.width * 0.4,
      height: size.height * 0.25,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.book,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildBookDetailsRow(BookModel book, dynamic providerLocale) {
    // Parse rating safely
    double rating = 0.0;
    try {
      rating = double.parse(book.averageRate ?? "0.0");
    } catch (e) {
      rating = 0.0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            convertLang(book.language ?? '', providerLocale),
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        RatingBarIndicator(
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemSize: 14,
          rating: customRound(rating),
        ),
      ],
    );
  }

  Widget _buildBookStatsRow(BookModel book) {
    // Parse values safely
    int likes = 0;
    double rating = 0.0;
    int totalRates = 0;

    try {
      likes = book.like ?? 0;
      rating = double.parse(book.averageRate ?? "0.0");
      totalRates = int.parse(book.totalRates ?? "0");
    } catch (e) {
      // Values remain at defaults
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 16, color: Colors.red),
            const SizedBox(width: 2),
            Text(
              shortNum(number: likes),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              "${customRound(rating)}",
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.person, size: 16, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              shortNum(number: totalRates).toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeeMoreButton(dynamic providerLocale) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 32,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                Text(
                  providerLocale.bodySeeMore ?? 'See More',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:sboapp/app_model/book_model.dart';
// import 'package:sboapp/constants/languages_convert.dart';
// import 'package:sboapp/constants/short_nums.dart';
// import 'package:sboapp/constants/text_style.dart';
// import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
// import 'package:sboapp/screens/books/book_view_Info.dart';
// import 'package:sboapp/services/lan_services/language_provider.dart';
// import 'package:sboapp/services/get_database.dart';
// //
//
// class HomeRowsList extends StatefulWidget {
//   final String bookCategory;
//   final String lanCategory;
//   final VoidCallback onTap;
//
//   const HomeRowsList({
//     super.key,
//     required this.bookCategory,
//     required this.lanCategory,
//     required this.onTap,
//   });
//
//   @override
//   State<HomeRowsList> createState() => _HomeRowsListState();
// }
//
// class _HomeRowsListState extends State<HomeRowsList> {
//   String _convertNumber({required num number, required String languageCode}) {
//     final formatter = NumberFormat.decimalPattern(languageCode);
//     return formatter.format(number);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final providerLocale =
//         Provider.of<AppLocalizationsNotifier>(context, listen: false)
//             .localizations;
//     final provider = Provider.of<GetDatabase>(context, listen: false);
//     final Size size = MediaQuery.of(context).size;
//
//     return Row(
//       children: [
//         Expanded(
//           child: StreamBuilder<List<BookModel>>(
//             stream: provider.getTopBooks(category: widget.bookCategory),
//             builder: (BuildContext context,
//                 AsyncSnapshot<List<BookModel>> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting &&
//                   !snapshot.hasData) {
//                 return HomeRowsShimmer(bookCategory: widget.lanCategory);
//               }
//               if (snapshot.hasData) {
//                 return _buildBookList(snapshot.data!, size, providerLocale);
//               } else {
//                 return Center(child: Text(providerLocale.bodyNotFound));
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBookList(
//       List<BookModel> books, Size size, dynamic providerLocale) {
//     return SizedBox(
//       height: size.height * 0.53,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           GestureDetector(
//             onTap: widget.onTap,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   titleText(
//                       text: widget.lanCategory,
//                       fontSize: kDefaultFontSize * 1.5),
//                   const Icon(Icons.arrow_forward_ios_outlined),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: books.length + 1,
//               itemBuilder: (BuildContext context, int index) {
//                 if (index < books.length) {
//                   return _buildBookCard(books[index], size, providerLocale);
//                 } else {
//                   return _buildSeeMoreButton(providerLocale);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBookCard(BookModel book, Size size, dynamic providerLocale) {
//     if (book.status != "Public") return const SizedBox.shrink();
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => BookInfoView(
//               bookModel: book,
//               arCategory: widget.lanCategory,
//             ),
//           ),
//         );
//       },
//       child: Hero(
//         tag: book.book,
//         child: Card.filled(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: FittedBox(
//               child: SizedBox(
//                 width: size.width * 0.4,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildBookImage(book.img, size),
//                     rowTitleText(text: book.book.toUpperCase()),
//                     SizedBox(height: size.height * 0.005),
//                     rowSubTitleText(text: book.author),
//                     SizedBox(height: size.height * 0.005),
//                     _buildBookDetailsRow(book, providerLocale),
//                     SizedBox(height: size.height * 0.005),
//                     _buildBookStatsRow(book),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookImage(String imageUrl, Size size) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: ImageNetCache(
//           imageUrl: imageUrl,
//           fit: BoxFit.cover,
//           width: size.width * 0.4,
//           height: size.height * 0.25,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookDetailsRow(BookModel book, dynamic providerLocale) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         bodyText(
//           text: convertLang(book.language, providerLocale),
//         ),
//         RatingBarIndicator(
//           itemBuilder: (context, _) => const Icon(
//             Icons.star,
//             color: Colors.amber,
//           ),
//           itemSize: kDefaultFontSize * 1.3,
//           rating: customRound(double.parse(book.averageRate ?? "0.0")),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBookStatsRow(BookModel book) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(right: 4.0),
//               child: Icon(Icons.favorite, size: 18),
//             ),
//             bodyText(text: shortNum(number: book.like)),
//           ],
//         ),
//         Row(
//           children: [
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.0),
//               child: Icon(Icons.star, size: 18),
//             ),
//             bodyText(text: "${customRound(double.parse(book.averageRate!))}"),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.0),
//               child: Icon(Icons.person, size: 18),
//             ),
//             bodyText(
//               text: shortNum(
//                 number: num.parse(book.totalRates ?? "0"),
//               ).toString(),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSeeMoreButton(dynamic providerLocale) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             children: [
//               titleText(text: providerLocale.bodySeeMore),
//               const Icon(Icons.arrow_forward_ios_outlined),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
