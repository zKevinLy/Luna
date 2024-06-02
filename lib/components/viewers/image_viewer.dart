import 'package:flutter/material.dart';
import 'package:luna/components/loading.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/providers/fetch_content.dart';

class ImageViewer extends StatefulWidget {
  final ContentData contentData;
  final int currentIndex;
  final ContentData cardItem;

  const ImageViewer({
    Key? key,
    required this.contentData,
    required this.currentIndex,
    required this.cardItem,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  ContentData _currentContentData = ContentData.empty();
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
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

      await fetchContentItem(widget.cardItem, _currentContentData);

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
      body: _isLoading
          ? buildLoadingIndicator()
          : Center(
              child: Container(
                width: 800, // Adjust the width as needed
                alignment: Alignment.center,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _currentContentData.contentList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(0.0), // Adjust padding as needed
                      child: Image.network(_currentContentData.contentList[index], fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
