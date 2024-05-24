import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/fetch_content.dart';

class ImageViewer extends StatefulWidget {
  final List<String> contentItems;
  final ContentData contentData;
  final int currentIndex;
  final ContentData cardItem;

  const ImageViewer({
    super.key,
    required this.contentData,
    required this.contentItems,
    required this.currentIndex,
    required this.cardItem,
  });

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
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
      final newContentItems = await fetchContentItem(widget.cardItem, _currentContentData);

      setState(() {
        _contentItems.addAll(newContentItems);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemCount: _contentItems.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _contentItems.length) {
                  return Container(
                    margin: EdgeInsets.zero,
                    child: Image.network(_contentItems[index], fit: BoxFit.cover),
                  );
                } else {
                  return _buildLoadingIndicator();
                }
              },
            ),
          ),
        ],
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
