import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/fetch_content.dart';

import 'package:luna/components/viewers/text_viewer.dart';
import 'package:luna/components/viewers/image_viewer.dart';
import 'package:luna/components/viewers/video_viewer.dart';

import 'package:url_launcher/url_launcher.dart';

class ContentLayout extends StatelessWidget {
  final ContentData cardItem;

  const ContentLayout({super.key, required this.cardItem});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder widget is used to handle asynchronous operations.
    return FutureBuilder<ContentData>(
      future: fetchContentDetails(cardItem), // Call the fetchContentDetails method to get the content information asynchronously.
      builder: (context, snapshot) { 
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
  Widget buildContentBody(ContentData contentInfo) {
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
  Widget buildImage(ContentData contentInfo) {
    return Image.network(
      contentInfo.imageURI,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  // Method to display the content description.
  Widget buildCardContent(ContentData contentInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Author: ${contentInfo.author}',
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          'Genre: ${contentInfo.genre.toString()}',
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          'Description: ${contentInfo.summary}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10), // Add some space between the text and the button
        ElevatedButton(
          onPressed: () async {
            final Uri url = Uri.parse(contentInfo.contentURI);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
          child: const Text('Visit Website'),
        ),
      ],
    );
  }

  // Method to build the content list as tiles.
  Widget buildContentList(ContentData parentContentData) {
    return ListView.builder(
      itemCount: parentContentData.contentList.length,
      itemBuilder: (context, index) {
        final contentData = parentContentData.contentList[index]; 
        return ListTile(
          title: contentData.itemID != parentContentData.itemID
              ? Text("#${contentData.contentIndex} : ${contentData.itemID} : ${contentData.title}")
              : Text("#${contentData.contentIndex} : ${contentData.title}"),
          subtitle: const Text(""),
          onTap: () {
            _handleTileTap(context, contentData, index, parentContentData);
          },
        );
      },
    );
  }



  void _handleTileTap(BuildContext context, ContentData contentData, int currentIndex, ContentData parentContentData) {
    // Fetch content item asynchronously
    fetchContentItem(cardItem, contentData).then((contentItems) {
      // Determine the appropriate viewer based on content type
      switch (contentData.contentType) {
        case 'text':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TextViewer(
                contentData: contentData,
                contentItems: contentItems,
                currentIndex: currentIndex,
                cardItem: parentContentData,
              ),
            ),
          );
          break;
        case 'image':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(
                contentData: contentData,
                contentItems: contentItems,
                currentIndex: currentIndex,
                cardItem: parentContentData,
              ),
            ),
          );
          break;
        case 'video':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoViewer(contentData: contentData, contentItems: contentItems),
            ),
          );
          break;
        default:
          // Handle unknown content type or show an error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unknown content type: ${contentData.contentType}')),
          );
          break;
      }
    });
  }
}
