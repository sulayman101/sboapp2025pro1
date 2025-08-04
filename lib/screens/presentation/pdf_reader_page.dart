
// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../services/navigate_page_ads.dart';
import '../../welcome_screen/land_page.dart';

enum ViewMode { pdf, text }

class ReadingPage extends StatefulWidget {
  final BookModel? bookModel;
  final String? bookLink;
  final String? title;

  const ReadingPage({super.key, this.bookLink, this.title, this.bookModel});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> with TickerProviderStateMixin {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
  final ScrollController _textScrollController = ScrollController();
  late PdfViewerController _pdfViewerController;
  late PdfTextSearchResult _searchResult;
  late AnimationController _settingsAnimationController;
  late Animation<Offset> _settingsSlideAnimation;

  bool _showToolbar = false;
  bool _showScrollHead = true;
  bool _isPdfDownloading = false;
  bool _isCoverDownloading = false;
  bool _isDisposed = false;
  bool _displayOn = false;
  bool _secureMode = false;
  bool visibleIcon = false;
  bool single = false;
  bool _isTextExtracting = false;
  bool _textExtractionSupported = false;
  bool _showSettings = false;

  ViewMode _currentViewMode = ViewMode.pdf;
  String _extractedText = '';

  // Text customization properties
  double _textSize = 16.0;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  String _fontFamily = 'Default';
  double _lineHeight = 1.5;
  double _letterSpacing = 0.0;

  // Available customization options
  final List<Color> _backgroundColors = [
    Colors.white,
    Colors.black,
    const Color(0xFFF5F5DC), // Beige
    const Color(0xFFF0F8FF), // Alice Blue
    const Color(0xFFFFF8DC), // Cornsilk
    const Color(0xFF2E2E2E), // Dark Gray
    const Color(0xFF1A1A1A), // Almost Black
  ];

  final List<Color> _textColors = [
    Colors.black,
    Colors.white,
    const Color(0xFF333333), // Dark Gray
    const Color(0xFF4A4A4A), // Medium Gray
    const Color(0xFFE0E0E0), // Light Gray
    const Color(0xFF8B4513), // Saddle Brown
  ];

  final List<String> _fontFamilies = [
    'Default',
    'Serif',
    'Sans-serif',
    'Monospace',
  ];

  File? _pdfFile;
  File? _imgFile;
  double onPdfProgress = 0.0;
  double onCoverProgress = 0.0;
  int? lastPage;

  @override
  void initState() {
    super.initState();
    _initializePdfViewer();
    _loadLastPage();
    _loadPdfFile();
    _disableScreenshot();
    _showAdsIfNotSubscriber();
    _loadTextSettings();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _settingsSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _settingsAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _settingsAnimationController.dispose();
    _textScrollController.dispose();
    _cleanupResources();
    super.dispose();
  }

  void _initializePdfViewer() {
    _pdfViewerController = PdfViewerController();
    _searchResult = PdfTextSearchResult();
  }

  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBookId = prefs.getString('lastBookId');
    if (savedBookId == widget.bookModel?.bookId) {
      lastPage = prefs.getInt('lastPage') ?? 1;
    } else {
      lastPage = 1;
    }
  }

  Future<void> _loadTextSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textSize = prefs.getDouble('textSize') ?? 16.0;
      _backgroundColor = Color(prefs.getInt('backgroundColor') ?? Colors.white.value);
      _textColor = Color(prefs.getInt('textColor') ?? Colors.black.value);
      _fontFamily = prefs.getString('fontFamily') ?? 'Default';
      _lineHeight = prefs.getDouble('lineHeight') ?? 1.5;
      _letterSpacing = prefs.getDouble('letterSpacing') ?? 0.0;
    });
  }

  Future<void> _saveTextSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', _textSize);
    await prefs.setInt('backgroundColor', _backgroundColor.value);
    await prefs.setInt('textColor', _textColor.value);
    await prefs.setString('fontFamily', _fontFamily);
    await prefs.setDouble('lineHeight', _lineHeight);
    await prefs.setDouble('letterSpacing', _letterSpacing);
  }

  Future<void> _loadPdfFile() async {
    final file = await _downloadFile(widget.bookModel?.link ?? widget.bookLink!);
    setState(() {
      _pdfFile = file;
    });
    // Try to extract text after PDF is loaded
    _extractTextFromPdf();
  }

  Future<void> _extractTextFromPdf() async {
    if (_pdfFile == null) return;

    setState(() {
      _isTextExtracting = true;
    });

    try {
      final bytes = await _pdfFile!.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Create PdfTextExtractor instance
      PdfTextExtractor extractor = PdfTextExtractor(document);

      // Extract text from all pages
      String extractedText = extractor.extractText();

      // If no text extracted, try page by page approach
      if (extractedText.trim().isEmpty) {
        StringBuffer textBuffer = StringBuffer();

        for (int i = 0; i < document.pages.count; i++) {
          try {
            // Extract text from specific page range
            String pageText = extractor.extractText(
              startPageIndex: i,
              endPageIndex: i,
            );
            if (pageText.trim().isNotEmpty) {
              textBuffer.writeln('--- Page ${i + 1} ---\n');
              textBuffer.writeln(pageText);
              textBuffer.writeln('\n');
            }
          } catch (pageError) {
            log('Failed to extract text from page ${i + 1}: $pageError');
            // Continue with other pages
          }
        }

        extractedText = textBuffer.toString().trim();
      }

      document.dispose();

      setState(() {
        _extractedText = extractedText;
        _textExtractionSupported = extractedText.isNotEmpty && extractedText.length > 50; // Minimum text threshold
        _isTextExtracting = false;
      });

      if (!_textExtractionSupported) {
        _showTextExtractionFailedMessage();
      }

    } catch (e) {
      setState(() {
        _isTextExtracting = false;
        _textExtractionSupported = false;
      });
      log('Text extraction failed: $e');
      _showTextExtractionFailedMessage();
    }
  }

  void _showTextExtractionFailedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Text extraction not supported for this PDF. You can still view it in PDF mode.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<File> _downloadFile(String url) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${widget.bookModel?.book ?? widget.title}';
    final file = File(filePath);

    if (await file.exists()) return file;

    final httpClient = HttpClient();
    try {
      _isPdfDownloading = true;
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength;
        int downloadedBytes = 0;

        final sink = file.openWrite();
        await response.forEach((chunk) {
          if (_isDisposed) {
            sink.close();
            file.deleteSync();
            throw Exception('Download cancelled');
          }
          downloadedBytes += chunk.length;
          if (totalBytes != null && totalBytes > 0) {
            setState(() {
              onPdfProgress = downloadedBytes / totalBytes;
            });
          }
          sink.add(chunk);
        });

        await sink.close();
        setState(() {
          _isPdfDownloading = false;
        });
        return file;
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      setState(() {
        _isPdfDownloading = false;
      });
      if (await file.exists()) {
        file.deleteSync();
      }
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> _disableScreenshot() async {
    if (Platform.isAndroid) {
      await WakelockPlus.enable();
    }
  }

  void _showAdsIfNotSubscriber() {
    if (!Provider.of<GetDatabase>(context, listen: false).subscriber) {
      Provider.of<NavigatePageAds>(context, listen: false).showInterstitialAd();
    }
  }

  Future<void> _cleanupResources() async {
    if (_isPdfDownloading && _pdfFile != null) {
      _pdfFile?.deleteSync();
    }
    if (_isCoverDownloading && _imgFile != null) {
      _imgFile?.deleteSync();
    }
    if (Platform.isAndroid) {
      await WakelockPlus.disable();
    }
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale = Provider.of<AppLocalizationsNotifier>(context, listen: true).localizations;

    return Scaffold(
      backgroundColor: _currentViewMode == ViewMode.text ? _backgroundColor : null,
      appBar: _showToolbar ? _buildSearchToolbar() : _buildDefaultAppBar(),
      body: Stack(
        children: [
          _isPdfDownloading
              ? _buildLoadingScreen(providerLocale)
              : _currentViewMode == ViewMode.pdf
              ? _buildPdfViewer()
              : _buildTextViewer(),

          // Settings Panel
          if (_showSettings)
            _buildSettingsPanel(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  AppBar _buildSearchToolbar() {
    return AppBar(
      flexibleSpace: SafeArea(
        child: SearchToolbar(
          key: _textSearchKey,
          controller: _pdfViewerController,
          onTap: (Object toolbarItem) {
            if (toolbarItem.toString() == 'Cancel Search') {
              setState(() {
                _showToolbar = false;
                _showScrollHead = true;
              });
            }
          },
        ),
      ),
      automaticallyImplyLeading: false,
    );
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(widget.bookModel?.book ?? widget.title!),
      backgroundColor: _currentViewMode == ViewMode.text ? _backgroundColor : null,
      foregroundColor: _currentViewMode == ViewMode.text ? _textColor : null,
      actions: [
        // View Mode Toggle
        if (visibleIcon && _textExtractionSupported)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ToggleButtons(
              isSelected: [
                _currentViewMode == ViewMode.pdf,
                _currentViewMode == ViewMode.text,
              ],
              onPressed: (index) {
                setState(() {
                  _currentViewMode = index == 0 ? ViewMode.pdf : ViewMode.text;
                });
              },
              borderRadius: BorderRadius.circular(20),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 32),
              children: const [
                Icon(Icons.picture_as_pdf, size: 18),
                Icon(Icons.text_fields, size: 18),
              ],
            ),
          ),

        // Settings for text mode
        if (_currentViewMode == ViewMode.text && _textExtractionSupported)
          IconButton(
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
              if (_showSettings) {
                _settingsAnimationController.forward();
              } else {
                _settingsAnimationController.reverse();
              }
            },
            icon: const Icon(Icons.settings),
          ),

        if (visibleIcon && _currentViewMode == ViewMode.pdf)
          IconButton(
            onPressed: () => setState(() => single = !single),
            icon: Icon(single ? Icons.slideshow : Icons.ad_units_outlined),
          ),

        if (visibleIcon && _currentViewMode == ViewMode.pdf)
          IconButton(
            onPressed: () => setState(() => _showToolbar = true),
            icon: const Icon(Icons.search),
          ),

        PopupMenuButton<int>(
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            if (_currentViewMode == ViewMode.pdf)
              const PopupMenuItem(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Bookmarks'),
                ),
              ),
            const PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text('Rate the book'),
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: Icon(
                  Icons.lightbulb,
                  color: _displayOn ? Colors.yellow : Colors.grey,
                ),
                title: Text("Stay awake: ${_displayOn ? "Enabled" : "Disabled"}"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingScreen(dynamic providerLocale) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/book.gif", scale: 4),
          const SizedBox(height: 20),
          bodyText(text: providerLocale.bodyWait),
          const SizedBox(height: 20),
          Container(
            width: 200,
            child: LinearProgressIndicator(
              value: onPdfProgress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: bodyText(text: '${(onPdfProgress * 100).toStringAsFixed(0)}%'),
            ),
          ),
          if (_isTextExtracting) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            bodyText(text: 'Extracting text for better reading experience...'),
          ],
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.file(
      _pdfFile!,
      controller: _pdfViewerController,
      key: _pdfViewerKey,
      canShowScrollHead: _showScrollHead,
      pageLayoutMode: single ? PdfPageLayoutMode.single : PdfPageLayoutMode.continuous,
      onDocumentLoaded: (details) {
        final isGuest = Provider.of<AuthServices>(context, listen: false).isGuest;
        if (isGuest && _pdfViewerController.pageNumber > 5) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingView()),
          );
        }
        setState(() => visibleIcon = true);
        if (lastPage != null) {
          _pdfViewerController.jumpToPage(lastPage!);
        }
      },
      onDocumentLoadFailed: (details) {
        ScaffoldMessenger.of(context).showSnackBar(
          customizedSnackBar(
            title: "Failed request",
            message: "Can't open the document. Please try again.",
            contentType: ContentType.failure,
          ),
        );
      },
    );
  }

  Widget _buildTextViewer() {
    if (!_textExtractionSupported) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_fields_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Text extraction not supported for this PDF',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please use PDF mode to view this document',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      color: _backgroundColor,
      child: SingleChildScrollView(
        controller: _textScrollController,
        padding: const EdgeInsets.all(20),
        child: SelectableText(
          _extractedText,
          style: TextStyle(
            fontSize: _textSize,
            color: _textColor,
            height: _lineHeight,
            letterSpacing: _letterSpacing,
            fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: SlideTransition(
        position: _settingsSlideAnimation,
        child: Container(
          width: 300,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.palette, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Reading Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showSettings = false;
                        });
                        _settingsAnimationController.reverse();
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Settings Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTextSizeSlider(),
                    const SizedBox(height: 20),
                    _buildLineHeightSlider(),
                    const SizedBox(height: 20),
                    _buildLetterSpacingSlider(),
                    const SizedBox(height: 20),
                    _buildFontFamilySelector(),
                    const SizedBox(height: 20),
                    _buildBackgroundColorSelector(),
                    const SizedBox(height: 20),
                    _buildTextColorSelector(),
                    const SizedBox(height: 30),
                    _buildResetButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Text Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Slider(
          value: _textSize,
          min: 12.0,
          max: 32.0,
          divisions: 20,
          label: _textSize.round().toString(),
          onChanged: (value) {
            setState(() {
              _textSize = value;
            });
            _saveTextSettings();
          },
        ),
        Text('${_textSize.round()}px', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildLineHeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Line Height', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Slider(
          value: _lineHeight,
          min: 1.0,
          max: 3.0,
          divisions: 20,
          label: _lineHeight.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _lineHeight = value;
            });
            _saveTextSettings();
          },
        ),
        Text('${_lineHeight.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildLetterSpacingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Letter Spacing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Slider(
          value: _letterSpacing,
          min: -2.0,
          max: 4.0,
          divisions: 60,
          label: _letterSpacing.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _letterSpacing = value;
            });
            _saveTextSettings();
          },
        ),
        Text('${_letterSpacing.toStringAsFixed(1)}px', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFontFamilySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Font Family', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _fontFamilies.map((font) {
            final isSelected = _fontFamily == font;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _fontFamily = font;
                });
                _saveTextSettings();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  font,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontFamily: font == 'Default' ? null : font,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBackgroundColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Background Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _backgroundColors.map((color) {
            final isSelected = _backgroundColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _backgroundColor = color;
                });
                _saveTextSettings();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  color: color == Colors.white || color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Text Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _textColors.map((color) {
            final isSelected = _textColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _textColor = color;
                });
                _saveTextSettings();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  color: color == Colors.white || color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _textSize = 16.0;
          _backgroundColor = Colors.white;
          _textColor = Colors.black;
          _fontFamily = 'Default';
          _lineHeight = 1.5;
          _letterSpacing = 0.0;
        });
        _saveTextSettings();
      },
      icon: const Icon(Icons.refresh),
      label: const Text('Reset to Defaults'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (_currentViewMode != ViewMode.text || !_textExtractionSupported) {
      return const SizedBox(); // Return empty widget if not in text mode
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: "scroll_top",
          onPressed: () {
            _textScrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Icon(Icons.keyboard_arrow_up),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: "scroll_bottom",
          onPressed: () {
            _textScrollController.animateTo(
              _textScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }

  void _handleMenuSelection(int value) {
    final isGuest = Provider.of<AuthServices>(context, listen: false).isGuest;

    switch (value) {
      case 0:
        if (_currentViewMode == ViewMode.pdf) {
          _pdfViewerKey.currentState?.openBookmarkView();
        }
        break;
      case 1:
        if (isGuest) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingView()),
          );
        } else {
          _showBookRating();
        }
        break;
      case 2:
        _toggleScreenAwake();
        break;
    }
  }

  void _showBookRating() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              "Rate this Book",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Book info
            if (widget.bookModel != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.bookModel!.img,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.book),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bookModel!.book,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.bookModel!.author,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Rating component
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: booksRating(
                    context: context,
                    bookModel: widget.bookModel!
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleScreenAwake() async {
    setState(() {
      _displayOn = !_displayOn;
    });

    try {
      if (_displayOn) {
        await ScreenProtector.protectDataLeakageOn();
        await WakelockPlus.enable();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow),
                SizedBox(width: 8),
                Text('Screen will stay awake while reading'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        await ScreenProtector.protectDataLeakageOff();
        await WakelockPlus.disable();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.grey),
                SizedBox(width: 8),
                Text('Screen timeout restored to normal'),
              ],
            ),
            backgroundColor: Colors.grey.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      log('Error toggling screen awake: $e');
    }
  }
}

// // ignore_for_file: use_build_context_synchronously
//
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// //import 'package:flutter_windowmanager/flutter_windowmanager.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:sboapp/Constants/shimmer_widgets/home_shimmer.dart';
// import 'package:sboapp/Services/auth_services.dart';
// import 'package:sboapp/app_model/book_model.dart';
// import 'package:sboapp/app_model/offline_books_model.dart';
// import 'package:sboapp/components/ads_and_net.dart';
// import 'package:sboapp/components/awesome_snackbar.dart';
// import 'package:sboapp/constants/book_rating.dart';
// import 'package:sboapp/constants/text_style.dart';
// import 'package:sboapp/services/get_database.dart';
// import 'package:sboapp/services/offline_books/offline_books_provider.dart';
// import 'package:sboapp/services/pdf_text_search.dart';
// import 'package:sboapp/services/lan_services/language_provider.dart';
// import 'package:screen_protector/screen_protector.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'dart:async';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
//
// import '../../services/navigate_page_ads.dart';
// import '../../welcome_screen/land_page.dart';
//
// class ReadingPage extends StatefulWidget {
//   final BookModel? bookModel;
//   final String? bookLink;
//   final String? title;
//
//   const ReadingPage({super.key, this.bookLink, this.title, this.bookModel});
//
//   @override
//   State<ReadingPage> createState() => _ReadingPageState();
// }
//
// class _ReadingPageState extends State<ReadingPage> {
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
//   final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
//   late PdfViewerController _pdfViewerController;
//   late PdfTextSearchResult _searchResult;
//
//   bool _showToolbar = false;
//   bool _showScrollHead = true;
//   bool _isPdfDownloading = false;
//   bool _isCoverDownloading = false;
//   bool _isDisposed = false;
//   bool _displayOn = false;
//   bool _secureMode = false;
//   bool visibleIcon = false;
//   bool single = false;
//
//   File? _pdfFile;
//   File? _imgFile;
//   double onPdfProgress = 0.0;
//   double onCoverProgress = 0.0;
//   int? lastPage;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePdfViewer();
//     _loadLastPage();
//     _loadPdfFile();
//     _disableScreenshot();
//     _showAdsIfNotSubscriber();
//   }
//
//   @override
//   void dispose() {
//     _cleanupResources();
//     super.dispose();
//   }
//
//   void _initializePdfViewer() {
//     _pdfViewerController = PdfViewerController();
//     _searchResult = PdfTextSearchResult();
//   }
//
//   Future<void> _loadLastPage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedBookId = prefs.getString('lastBookId');
//     if (savedBookId == widget.bookModel?.bookId) {
//       lastPage = prefs.getInt('lastPage') ?? 1;
//     } else {
//       lastPage = 1;
//     }
//   }
//
//   Future<void> _loadPdfFile() async {
//     final file =
//         await _downloadFile(widget.bookModel?.link ?? widget.bookLink!);
//     setState(() {
//       _pdfFile = file;
//     });
//   }
//
//   Future<File> _downloadFile(String url) async {
//     final directory = await getTemporaryDirectory();
//     final filePath =
//         '${directory.path}/${widget.bookModel?.book ?? widget.title}';
//     final file = File(filePath);
//
//     if (await file.exists()) return file;
//
//     final httpClient = HttpClient();
//     try {
//       _isPdfDownloading = true;
//       final request = await httpClient.getUrl(Uri.parse(url));
//       final response = await request.close();
//
//       if (response.statusCode == 200) {
//         final totalBytes = response.contentLength;
//         int downloadedBytes = 0;
//
//         final sink = file.openWrite();
//         await response.forEach((chunk) {
//           if (_isDisposed) {
//             sink.close();
//             file.deleteSync();
//             throw Exception('Download cancelled');
//           }
//           downloadedBytes += chunk.length;
//           onPdfProgress = downloadedBytes / totalBytes!;
//           sink.add(chunk);
//         });
//
//         await sink.close();
//         _isPdfDownloading = false;
//         return file;
//       } else {
//         throw Exception('Failed to download file');
//       }
//     } catch (e) {
//       _isPdfDownloading = false;
//       file.deleteSync();
//       throw Exception('Failed to download file: $e');
//     }
//   }
//
//   Future<void> _disableScreenshot() async {
//     if (Platform.isAndroid) {
//       //await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
//       await WakelockPlus.enable();
//     }
//   }
//
//   void _showAdsIfNotSubscriber() {
//     if (!Provider.of<GetDatabase>(context, listen: false).subscriber) {
//       Provider.of<NavigatePageAds>(context, listen: false).showInterstitialAd();
//     }
//   }
//
//   Future<void> _cleanupResources() async {
//     if (_isPdfDownloading) {
//       _pdfFile?.deleteSync();
//     }
//     if (_isCoverDownloading) {
//       _imgFile?.deleteSync();
//     }
//     if (Platform.isAndroid) {
//       //FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
//       await WakelockPlus.disable();
//     }
//     _isDisposed = true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final providerLocale =
//         Provider.of<AppLocalizationsNotifier>(context, listen: true)
//             .localizations;
//
//     return ScaffoldWidget(
//       appBar: _showToolbar ? _buildSearchToolbar() : _buildDefaultAppBar(),
//       body: _isPdfDownloading
//           ? _buildLoadingScreen(providerLocale)
//           : _buildPdfViewer(),
//     );
//   }
//
//   AppBar _buildSearchToolbar() {
//     return AppBar(
//       flexibleSpace: SafeArea(
//         child: SearchToolbar(
//           key: _textSearchKey,
//           controller: _pdfViewerController,
//           onTap: (Object toolbarItem) {
//             if (toolbarItem.toString() == 'Cancel Search') {
//               setState(() {
//                 _showToolbar = false;
//                 _showScrollHead = true;
//               });
//             }
//           },
//         ),
//       ),
//       automaticallyImplyLeading: false,
//     );
//   }
//
//   AppBar _buildDefaultAppBar() {
//     return AppBar(
//       title: Text(widget.bookModel?.book ?? widget.title!),
//       actions: [
//         if (visibleIcon)
//           IconButton(
//             onPressed: () => setState(() => single = !single),
//             icon: Icon(single ? Icons.slideshow : Icons.ad_units_outlined),
//           ),
//         if (visibleIcon)
//           IconButton(
//             onPressed: () => setState(() => _showToolbar = true),
//             icon: const Icon(Icons.search),
//           ),
//         PopupMenuButton<int>(
//           onSelected: _handleMenuSelection,
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//                 value: 0,
//                 child: ListTile(
//                     leading: Icon(Icons.bookmark), title: Text('Bookmarks'))),
//             const PopupMenuItem(
//                 value: 1,
//                 child: ListTile(
//                     leading: Icon(Icons.star), title: Text('Rate the book'))),
//             PopupMenuItem(
//               value: 2,
//               child: ListTile(
//                 leading: Icon(Icons.lightbulb,
//                     color: _displayOn ? Colors.yellow : Colors.grey),
//                 title:
//                     Text("Stay awake: ${_displayOn ? "Enabled" : "Disabled"}"),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoadingScreen(dynamic providerLocale) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Image.asset("assets/images/book.gif", scale: 4),
//         bodyText(text: providerLocale.bodyWait),
//         CircularProgressIndicator(value: onPdfProgress),
//         Material(
//           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
//           borderRadius: BorderRadius.circular(50),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//             child:
//                 bodyText(text: '${(onPdfProgress * 100).toStringAsFixed(0)}%'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPdfViewer() {
//     return SfPdfViewer.file(
//       _pdfFile!,
//       controller: _pdfViewerController,
//       key: _pdfViewerKey,
//       canShowScrollHead: _showScrollHead,
//       pageLayoutMode:
//           single ? PdfPageLayoutMode.single : PdfPageLayoutMode.continuous,
//       onDocumentLoaded: (details) {
//         final isGuest = Provider.of<AuthServices>(context).isGuest;
//         if(isGuest && _pdfViewerController.pageNumber > 5){
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const OnboardingView()),
//           );
//         }
//         setState(() => visibleIcon = true);
//         if (lastPage != null) {
//           _pdfViewerController.jumpToPage(lastPage!);
//         }
//       },
//       onDocumentLoadFailed: (details) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           customizedSnackBar(
//             title: "Failed request",
//             message: "Can't open the document. Please try again.",
//             contentType: ContentType.failure,
//           ),
//         );
//       },
//     );
//   }
//
//   void _handleMenuSelection(int value) {
//     switch (value) {
//       case 0:
//         _pdfViewerKey.currentState?.openBookmarkView();
//         break;
//       case 1:
//         _showBookRating();
//         break;
//       case 2:
//         _toggleScreenAwake();
//         break;
//     }
//   }
//
//   void _showBookRating() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           titleText(text: "Rate the Book"),
//           booksRating(context: context, bookModel: widget.bookModel!),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _toggleScreenAwake() async {
//     setState(() {
//       _displayOn = !_displayOn;
//     });
//     if (_displayOn) {
//       await ScreenProtector.protectDataLeakageOn();
//       //FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
//     } else {
//       await ScreenProtector.protectDataLeakageOff();
//       //FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
//     }
//   }
// }
