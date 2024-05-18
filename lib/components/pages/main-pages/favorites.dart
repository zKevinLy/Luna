import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';
import 'package:luna/components/pages/card-layout.dart';
import 'package:luna/models/content-info.dart';
import 'package:luna/content-type/novels/light-novel-pub.dart';

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
    return FutureBuilder<ContentInfo>(
      future: fetchContentInfo("the-beginning-after-the-end"),
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
          final List<ContentInfo> cardItems = [snapshot.data!];
          return CardLayout(cardItems: cardItems); // Build CardLayout with fetched content
        }
      },
    );
  }

  Future<ContentInfo> fetchContentInfo(String title) async {
    final lightNovelPub = LightNovelPub();
    final contentInfo = await lightNovelPub.fetchContentInfo(title);
    return contentInfo;
  }
}
