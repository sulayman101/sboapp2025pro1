import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Signature for the [SearchToolbar.onTap] callback.
typedef SearchTapCallback = void Function(Object item);

class SearchToolbar extends StatefulWidget {
  const SearchToolbar({
    this.controller,
    this.onTap,
    this.showTooltip = true,
    super.key,
  });

  final bool showTooltip;
  final PdfViewerController? controller;
  final SearchTapCallback? onTap;

  @override
  SearchToolbarState createState() => SearchToolbarState();
}

class SearchToolbarState extends State<SearchToolbar> {
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late PdfTextSearchResult _searchResult;
  bool _isSearchInitiated = false;

  @override
  void initState() {
    super.initState();
    _searchResult = PdfTextSearchResult();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchResult.removeListener(() {});
    super.dispose();
  }

  void clearSearch() {
    setState(() {
      _isSearchInitiated = false;
      _editingController.clear();
      _searchResult.clear();
    });
  }

  void _showSearchAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Result'),
        content: const Text(
            'No more occurrences found. Would you like to search from the beginning?'),
        actions: [
          TextButton(
            onPressed: () {
              _searchResult.nextInstance();
              Navigator.pop(context);
            },
            child: const Text('YES'),
          ),
          TextButton(
            onPressed: () {
              clearSearch();
              Navigator.pop(context);
            },
            child: const Text('NO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onTap?.call('Cancel Search');
            clearSearch();
          },
        ),
        Expanded(
          child: TextFormField(
            controller: _editingController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Find...',
            ),
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (value) {
              setState(() {
                _isSearchInitiated = true;
                _searchResult = widget.controller!.searchText(value);
                _searchResult.addListener(() {
                  if (mounted) setState(() {});
                  if (!_searchResult.hasResult &&
                      _searchResult.isSearchCompleted) {
                    widget.onTap?.call('noResultFound');
                  }
                });
              });
            },
          ),
        ),
        if (_editingController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSearch,
            tooltip: widget.showTooltip ? 'Clear Text' : null,
          ),
        if (!_searchResult.isSearchCompleted && _isSearchInitiated)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          ),
        if (_searchResult.hasResult)
          Row(
            children: [
              Text(
                  '${_searchResult.currentInstanceIndex} of ${_searchResult.totalInstanceCount}'),
              IconButton(
                icon: const Icon(Icons.navigate_before),
                onPressed: _searchResult.previousInstance,
                tooltip: widget.showTooltip ? 'Previous' : null,
              ),
              IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: () {
                  if (_searchResult.currentInstanceIndex ==
                          _searchResult.totalInstanceCount &&
                      _searchResult.isSearchCompleted) {
                    _showSearchAlertDialog(context);
                  } else {
                    _searchResult.nextInstance();
                  }
                },
                tooltip: widget.showTooltip ? 'Next' : null,
              ),
            ],
          ),
      ],
    );
  }
}
