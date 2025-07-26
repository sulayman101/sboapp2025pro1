/*
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/Constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/Services/auth_services.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/app_model/offline_books_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/awesome_snackbar.dart';
import 'package:sboapp/constants/book_rating.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/offline_books/offline_books_provider.dart';
import 'package:sboapp/services/pdf_text_search.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';


import '../../services/navigate_page_ads.dart';
import 'package:pdfx/pdfx.dart';


class PDFVewerPage extends StatefulWidget {
  final BookModel? bookModel;
  final String? bookLink;
  final String? title;
  const PDFVewerPage({super.key, this.bookLink, this.title, this.bookModel});

  @override
  State<PDFVewerPage> createState() => _PDFVewerPageState();
}

class _PDFVewerPageState extends State<PDFVewerPage> {
  //final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();

  late PdfController _pdfController;
  bool single = false;
  bool visibleIcon = false;
  final List<int> menuItemIdentifiers = [0, 1, 2, 3];

  LocalHistoryEntry? _historyEntry;

  late PdfViewerController _pdfViewerController;
  // ignore: unused_field
  //late PdfTextSearchResult _searchResult;
  late bool _showToolbar;
  late bool _showScrollHead;


  void searchFun() {
    setState(() {
      _showScrollHead = false;
      _showToolbar = true;
      _ensureHistoryEntry();
    });
  }

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry!);
      }
    }
  }

  void _handleHistoryEntryRemoved() {
    _textSearchKey.currentState?.clearSearch();
    setState(() {
      _showToolbar = false;
    });
    _historyEntry = null;
  }

  bool _secureMode = false;

  bool _displayOn = false;

  File? _pdfFile;
  File? _imgFile;

  Future<void> loadPDF() async {
    final file = await downloadPDF(
      widget.bookModel?.link ?? widget.bookLink!,
    );
    setState(() {
      _pdfFile = file;
    });
  }

  double onPdfProgress = 0.0;
  double onCoverProgress = 0.0;

  void _makeOffline() async{
    final provider = Provider.of<OfflineBooksProvider>(context, listen: false);
    final pdfFile = await downloadPDF(
      widget.bookModel?.link ?? widget.bookLink!,
    );
    final imgFile = await downloadCover(
      widget.bookModel!.img,
    );
    setState(() {
      _pdfFile = pdfFile;
      _imgFile = imgFile;
    });
    OfflineBooksModel offlineBooksModel = OfflineBooksModel(
        bookId: widget.bookModel!.bookId,
        book: widget.bookModel!.book,
        bookLang: widget.bookModel!.language,
        bookPath: _pdfFile!.path,
        bookImg: _imgFile!.path,
        author: widget.bookModel!.author,
        bookDate: widget.bookModel!.date,
        uid: AuthServices().fireAuth.currentUser!.uid.toString()
    );
    if(_pdfFile != null && _imgFile != null) {
      provider.addBook(offlineBooksModel);
      ScaffoldMessenger.of(context).showSnackBar(customizedSnackBar(
          title: provider.result.toString(),
          message: provider.result == "successfully" ? "You can get in offline books" : "Book already exists",
          contentType: provider.result == "successfully" ? ContentType.success : ContentType.warning));
      Navigator.pop(context);
    }

  }

  showModelProcess(){
    final provider = Provider.of<OfflineBooksProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final isExist = provider.offlineBooks.any((e)=> e.bookId == widget.bookModel!.bookId);

    showModalBottomSheet(context: context, builder: (context)=> SizedBox(
      width: size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Material(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(width: size.width * 0.2, height: size.height * 0.015,),),
          ),
          SizedBox(height:  size.height * 0.015),
          titleText(text: "Make offline", ),
          SizedBox(height:  size.height * 0.015),
          SizedBox(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 10),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: ImageNetCache(imageUrl: widget.bookModel!.img,  height: size.height * 0.06,)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.bookModel!.book),
                        Text(widget.bookModel!.author),
                        Text(widget.bookModel!.language),
                      ],
                    ),
                  ],
                ),
                !isExist ? Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: onCoverProgress > 0.0 ?  CircularProgressIndicator( value: onCoverProgress, ) : const SizedBox()),
                    Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: IconButton.outlined(onPressed: onCoverProgress > 0.0 ? null : _makeOffline , icon: Icon(Icons.download_for_offline, color: onCoverProgress > 0.0 ? Theme.of(context).colorScheme.primary : null ))),
                  ],
                ) : const Icon(Icons.offline_pin),
              ],
            ),
          ),),
          SizedBox(height:  size.height * 0.015),
        ],
      ),
    ));
  }

  late bool _isPdfDownloading = false;
  HttpClientRequest? _pdfRequest;
  bool _isDisposed = false;

  Future<File> downloadPDF(String url) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${widget.bookModel?.book ?? widget.title}';
    final file = File(filePath);
    _pdfFile = file;

    // Check if the file already exists
    if (await file.exists()) {
      return file;
    }

    final httpClient = HttpClient();
    try {
      _isPdfDownloading = true;
      _pdfRequest = await httpClient.getUrl(Uri.parse(url));
      final response = await _pdfRequest!.close();

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength;
        int downloadedBytes = 0;

        final sink = file.openWrite();

        await response.forEach((chunk) {
          if (_isDisposed) {
            sink.close();
            file.deleteSync(); // Clean up incomplete file
            log('Download cancelled and file deleted');
            throw Exception('Download cancelled');
          }
          downloadedBytes += chunk.length;
          onPdfProgress = downloadedBytes / totalBytes!;
          sink.add(chunk);
          log('Progress: ${(onPdfProgress * 100).toStringAsFixed(2)}%');
        });

        await sink.close();
        _isPdfDownloading = false;

        return file;
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      _isPdfDownloading = false;
      file.deleteSync(); // Ensure cleanup on error
      log('Error occurred, file deleted: $e');
      throw Exception('Failed to download PDF: $e');
    } finally {
      _pdfRequest = null;
      _isPdfDownloading = false;
    }
  }

  late bool _isCoverDownloading = false;
  HttpClientRequest? _coverRequest;
  Future<File> downloadCover(String url) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${widget.bookModel?.bookId}';
    final file = File(filePath);
    _imgFile = file;

    // Check if the file already exists
    if (await file.exists()) {
      return file;
    }

    final httpClient = HttpClient();
    try {
      _isCoverDownloading = true;
      _coverRequest = await httpClient.getUrl(Uri.parse(url));
      final response = await _coverRequest!.close();

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength;
        int downloadedBytes = 0;

        final sink = file.openWrite();

        await response.forEach((chunk) {
          if (_isDisposed) {
            sink.close();
            file.deleteSync(); // Clean up incomplete file
            log('Cover download cancelled and file deleted');
            throw Exception('Cover download cancelled');
          }
          downloadedBytes += chunk.length;
          onCoverProgress = downloadedBytes / totalBytes;
          sink.add(chunk);
          log('Progress: ${(onCoverProgress * 100).toStringAsFixed(0)}%');
        });

        await sink.close();
        _isCoverDownloading = false;

        return file;
      } else {
        throw Exception('Failed to download cover');
      }
    } catch (e) {
      _isCoverDownloading = false;
      file.deleteSync(); // Ensure cleanup on error
      log('Error occurred, file deleted: $e');
      throw Exception('Failed to download cover: $e');
    } finally {
      _coverRequest = null;
      _isCoverDownloading = false;
    }
  }


  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    //_searchResult = PdfTextSearchResult();
    _showToolbar = false;
    _showScrollHead = true;

    loadPDF();
    if (Provider.of<GetDatabase>(context, listen: false).subscriber == false) {
      Provider.of<NavigatePageAds>(context, listen: false).showInterstitialAd();
    }

    //disabled screenshot
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Platform.isAndroid) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        //await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Platform.isAndroid) {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    });

    _isDisposed = true;
    if (_isPdfDownloading) {
      _pdfFile?.deleteSync();
      _pdfFile = null;
      log('Incomplete pdf download deleted');
    }
    if (_isCoverDownloading) {
      _imgFile?.deleteSync();
      _imgFile = null;
      log('Incomplete cover download deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      appBar: _showToolbar
          ? AppBar(
        flexibleSpace: SafeArea(
          child: SearchToolbar(
            key: _textSearchKey,
            showTooltip: true,
            //controller: _pdfViewerController,
            onTap: (Object toolbarItem) async {
              if (toolbarItem.toString() == 'Cancel Search') {
                setState(() {
                  _showToolbar = false;
                  _showScrollHead = true;
                  if (Navigator.canPop(context)) {
                    Navigator.maybePop(context);
                  }
                });
              }
              if (toolbarItem.toString() == 'noResultFound') {
                setState(() {
                  _textSearchKey.currentState?.showToast = true;
                });
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  _textSearchKey.currentState?.showToast = false;
                });
              }
            },
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      )
          : AppBar(
        title: Text(widget.bookModel?.book ?? widget.title!),
        actions: [
          Visibility(
            visible: visibleIcon,
            child: IconButton(
                onPressed: () {
                  setState(() => single = !single);
                },
                icon: Icon(
                    single ? Icons.slideshow : Icons.ad_units_outlined)),
          ),
          Visibility(
              visible: visibleIcon,
              child: IconButton(
                  onPressed: () => searchFun(),
                  icon: const Icon(Icons.search))),
          Visibility(
            visible: visibleIcon,
            child: PopupMenuButton<int>(
                onSelected: (int selectedValue) {
                  switch (selectedValue) {
                    case 0:
                      setState(() {
                        //_pdfViewerKey.currentState?.openBookmarkView();
                      });
                      break;
                    case 1:
                      _showBookRating();
                      break;
                    case 2:
                      _screenDisplay();
                      break;
                    case 3:
                      showModelProcess();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: menuItemIdentifiers[0],
                    child: const ListTile(
                      leading: Icon(Icons.bookmark),
                      title: Text('Bookmarks'),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: menuItemIdentifiers[1],
                    child: const ListTile(
                      leading: Icon(
                        Icons.star,
                      ),
                      title:
                      Text("Rate the book"), // Conditional text
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: menuItemIdentifiers[2],
                    child: ListTile(
                      leading: Icon(
                        Icons.lightbulb,
                        color:
                        _displayOn ? Colors.yellow : Colors.grey,
                      ),
                      title: Text(
                          "Stay awake: ${_displayOn ? "Enabled" : "Disabled"}"), // Conditional text
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: menuItemIdentifiers[3],
                    child: const ListTile(
                      leading: Icon(
                        Icons.offline_pin_rounded,
                      ),
                      title: Text("Make offline"), // Conditional text
                    ),
                  ),
                ]),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child:
              _isPdfDownloading
                  ? _waitingScreen(providerLocale) :
              _pdfViewWidget()
          ),
        ],
      ),
    );
  }
  _pdfViewWidget(){
    if (_pdfController != null)
      Expanded(
        child: PdfViewer.asset(_pdfFile!.path)
      );
  }

  _hyperLinks(){
    // Custom handling of the clicked hyperlink
    String customUrl = "https://play.google.com/store/apps/details?id=com.dsd.sboapp&pli=1";

    // Show a dialog or custom UI
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Book URL"),
        content: const Text(
            "Access to this link has been restricted"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                  customizedSnackBar(title: 'Book URL', message: 'You are not permitted to open this link', contentType: ContentType.warning)
              );
            },
            child: const Text("Open Link"),
          ),
        ],
      ),
    );
  }

  Widget _waitingScreen(providerLocale){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            "assets/images/book.gif",
            scale: 4,
          ),
        ),
        bodyText(text: providerLocale.bodyWait),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CircularProgressIndicator(value: onPdfProgress,),
        ),
        Material(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: bodyText(text: '${(onPdfProgress * 100).toStringAsFixed(0)}%'),
            )),
      ],
    );
  }

  _showBookRating() {
    final Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            width: size.width * 1,
            height: size.height * 0.2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: size.width * 0.2,
                    height: size.height * 0.015,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                titleText(text: "Rate the Book"),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: widget.bookModel != null
                      ? booksRating(
                      context: context, bookModel: widget.bookModel)
                      : const Text("You can not immiditly"),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                customText(
                    text:
                    "Your opinion makes a difference! How would you rate this book’s impact on you?",
                    textAlign: TextAlign.center),
              ],
            ),
          );
        });
  }

  _screenDisplay() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: ListTile(
              leading: Icon(
                Icons.lightbulb,
                color: _displayOn ? Colors.yellow : Colors.grey,
              ),
              subtitle: bodyText(text: "Screen will never sleep."),
              title: titleText(
                  text:
                  "Stay awake: ${_displayOn ? "Enabled" : "Disabled"}"), // Conditional text
              trailing: Switch(
                value: _displayOn,
                onChanged: (bool value) {
                  final secureModeToggle = !_secureMode;
                  WidgetsBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    if (secureModeToggle == true) {
                      if (Platform.isAndroid) {
                        await FlutterWindowManager.addFlags(
                            FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
                        ScaffoldMessenger.of(context).showSnackBar(
                            customizedSnackBar(
                                title: "Display light",
                                message: "Stay awake: Enabled",
                                contentType: ContentType.success));
                        _displayOn = value;
                      }
                    } else {
                      if (Platform.isAndroid) {
                        await FlutterWindowManager.clearFlags(
                            FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
                        _displayOn = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                            customizedSnackBar(
                                title: "Display light",
                                message: "Stay awake: Disabled",
                                contentType: ContentType.success));
                      }
                    }
                  });
                  setState(() {
                    _secureMode = !_secureMode;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          );
        });
  }
}
*/
