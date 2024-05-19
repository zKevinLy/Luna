import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';

class ImageViewer extends StatelessWidget {
  final List<String> contentItems;
  final ContentData contentData;

  const ImageViewer({super.key, required this.contentData, required this.contentItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contentData.title),
      ),
      body: ListView.builder(
        itemCount: contentItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(contentItems[index]),
          );
        },
      ),
    );
  }
}
