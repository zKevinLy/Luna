import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';
import 'package:luna/components/pages/card_layout.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/content-type/novels/light_novel_pub.dart';

class FavoritesPage extends LunaBasePage {
  FavoritesPage({Key? key}) : super(key: key, title: 'Favorites Page');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          // Handle settings icon press
        },
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return FutureBuilder<List<ContentPreview>>(
      future: fetchBrowseList([1, 2, 3]), // Fetch content list for given page numbers
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(), // Show a loading indicator while waiting
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'), // Show error message if fetching fails
          );
        } else {
          final List<ContentPreview> cardItems = snapshot.data ?? []; // Get the fetched list
          return CardLayout(cardItems: cardItems); // Build CardLayout with fetched content
        }
      },
    );
  }

  Future<List<ContentPreview>> fetchBrowseList(List<int> pageNumbers) async {
    final lightNovelPub = LightNovelPub();
    final contentList = await lightNovelPub.fetchBrowseList(pageNumbers);
    return contentList;
  }
}
