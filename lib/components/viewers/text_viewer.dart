import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';

class TextViewer extends StatelessWidget {
  final List<String> contentItems;
  final ContentData contentData;

  const TextViewer({required this.contentData, required this.contentItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contentData.title),
      ),
      body: ListView.builder(
        itemCount: contentItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contentItems[index]),
            // You can add more customization as needed
          );
        },
      ),
    );
  }
}
