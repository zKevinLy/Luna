import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/fetch_content.dart';

class TextViewer extends StatefulWidget {
  final List<String> contentItems;
  final ContentData contentData;
  final int currentIndex;
  final ContentData cardItem;

  const TextViewer({
    super.key,
    required this.contentData,
    required this.contentItems,
    required this.currentIndex,
    required this.cardItem,
  });

  @override
  _TextViewerState createState() => _TextViewerState();
}

class _TextViewerState extends State<TextViewer> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<String> _contentItems = [];
  ContentData _currentContentData = ContentData.empty();
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _contentItems = widget.contentItems;
    _currentContentData = widget.contentData;
    _currentIndex = widget.currentIndex;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreContent();
    }
  }

  Future<void> _loadMoreContent() async {
    if (!_isLoading && _currentIndex < widget.cardItem.contentList.length - 1) {
      setState(() {
        _isLoading = true;
      });

      _currentIndex++;
      _currentContentData = widget.cardItem.contentList[_currentIndex];

      // Fetch new content items asynchronously
      await fetchContentItem(widget.cardItem , _currentContentData);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentContentData.title),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _contentItems.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _contentItems.length) {
            return ListTile(
              title: Text(_contentItems[index]),
            );
          } else {
            return _buildLoadingIndicator();
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
