import 'package:flutter/material.dart';
import 'package:luna/models/content-info.dart';
import 'package:luna/content-type/novels/light-novel-pub.dart';

class ContentLayout extends StatefulWidget {
  final ContentInfo cardItem;

  const ContentLayout({required this.cardItem});

  @override
  _ContentLayoutState createState() => _ContentLayoutState();
}

class _ContentLayoutState extends State<ContentLayout> {
  String? _selectedContentURI; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildCardContent(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.cardItem.title,
        style: const TextStyle(fontSize: 20.0), 
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: 150,
      height: 200,
      child: Image.network(
        widget.cardItem.imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthor(),
          const SizedBox(height: 8.0),
          _buildDescription(),
          const SizedBox(height: 8.0),
          _buildChapters(),
        ],
      ),
    );
  }

  Widget _buildAuthor() {
    return Text(
      'Author: ${widget.cardItem.author}',
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'Summary: ${widget.cardItem.summary}',
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildChapters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.cardItem.contentList
          .map(
            (chapter) => ListTile(
              onTap: () {
                setState(() {
                  _selectedContentURI = chapter.contentURL;
                });
              },
              title: Text(
                chapter.title,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          )
          .toList(),
    );
  }


  Widget _buildContent() {
    if (_selectedContentURI == null) {
      return Container(); // Initially no content to show
    }
    return FutureBuilder(
      future: _fetchContentInfo(_selectedContentURI!),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Or any other loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Join the list of strings into a single string for display
          final contentInfo = snapshot.data?.join('\n') ?? 'No content available';
          return Text(contentInfo);
        }
      },
    );
  }

  Future<List<String>> _fetchContentInfo(String contentURI) async {
    List<String> contentInfo;
    switch(widget.cardItem.contentType){
      case "novel":
        final lightNovelPub = LightNovelPub();
        contentInfo = await lightNovelPub.fetchContentItem(contentURI); 
        break;
      default:
        contentInfo = [];
        break;
    }

    // print(contentInfo);
    return contentInfo;
  }

}

