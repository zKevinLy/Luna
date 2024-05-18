import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/content-type/novels/light_novel_pub.dart';
import 'package:luna/components/viewers/text_viewer.dart';

class ContentLayout extends StatelessWidget {
  final ContentPreview cardItem;

  const ContentLayout({required this.cardItem});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder widget is used to handle asynchronous operations.
    return FutureBuilder<ContentInfo>(
      future: _fetchContentInfo(), // Call the fetchContentInfo method to get the content information asynchronously.
      builder: (context, snapshot) { // Builder function that returns different UI based on the snapshot state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data.
          return Scaffold(
            appBar: AppBar(
              title: Text(cardItem.title),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Show an error message if there's an error during data fetching.
          return Scaffold(
            appBar: AppBar(
              title: Text(cardItem.title),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // Build the UI with fetched data if the future completes successfully.
          final contentInfo = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(cardItem.title),
            ),
            body: buildContentBody(contentInfo), // Build the body of the content layout.
          );
        }
      },
    );
  }

  // Method to build the body of the content layout.
  Widget buildContentBody(ContentInfo contentInfo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildImage(contentInfo), // Display the image.
              const SizedBox(height: 20),
              buildCardContent(contentInfo), // Display the content description.
            ],
          ),
        ),
        const SizedBox(width: 20), // Add some space between the left and right sides.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Content List:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: buildContentList(contentInfo), // Display the content list as tiles.
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to display the image.
  Widget buildImage(ContentInfo contentInfo) {
    return Image.network(
      contentInfo.imageURI,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  // Method to display the content description.
  Widget buildCardContent(ContentInfo contentInfo) {
    return Text(
      'Description: ${contentInfo.summary}',
      style: const TextStyle(fontSize: 18),
    );
  }

  // Method to build the content list as tiles.
  Widget buildContentList(ContentInfo contentInfo) {
    return ListView.builder(
      itemCount: contentInfo.contentList.length,
      itemBuilder: (context, index) {
        final contentData = contentInfo.contentList[index];
        return ListTile(
          title: Text("#$index ${contentData.title}"),
          subtitle: const Text(""),
          onTap: () {
            _handleTileTap(context, contentData);
          },
        );
      },
    );
  }


  void _handleTileTap(BuildContext context, ContentData contentData) {
    // Fetch content item asynchronously
    _fetchContentItem(contentData.contentURI).then((contentItems) {
      // Show content items using TextViewer widget
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextViewer(contentData: contentData, contentItems: contentItems),
        ),
      );
    });
  }


  Future<List<String>> _fetchContentItem(String contentURI) async {
    final lightNovelPub = LightNovelPub();
    return await lightNovelPub.fetchContentItem(contentURI);
  }


  // Method to fetch content information asynchronously.
  Future<ContentInfo> _fetchContentInfo() async {
    final lightNovelPub = LightNovelPub();
    return await lightNovelPub.fetchContentDetails(cardItem);
  }
}
