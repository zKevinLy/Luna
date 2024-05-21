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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 1, // Number of columns
              crossAxisSpacing: 0, // Horizontal spacing between tiles
              mainAxisSpacing: 0, // Vertical spacing between tiles
              padding: EdgeInsets.zero, 
              children: List.generate(contentItems.length, (index) {
                return Container(
                  margin: EdgeInsets.zero,
                  child: Image.network(contentItems[index], fit: BoxFit.cover), 
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

}
