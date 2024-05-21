import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';
import 'package:luna/components/pages/card_layout.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/content-type/novels/light_novel_pub.dart';
import 'package:luna/content-type/manga/batoto.dart';

class BrowsePage extends LunaBasePage {
  const BrowsePage({super.key}) : super(title: 'Browse Page');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Tooltip(
        message: 'Settings',
        child: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Handle settings icon press
          },
        ),
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return const DefaultTabController(
      length: 5, // Number of tabs
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Anime'),
              Tab(text: 'Manga'),
              Tab(text: 'Novel'),
              Tab(text: 'Movie'),
              Tab(text: 'TV Shows'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Content for Anime tab
                Center(child: Text('Anime Content')),
                // Content for Manga tab
                NovelTab(tabType: 'manga'), 
                // Content for Novel tab
                NovelTab(tabType: 'novel'), 
                // Content for Movie tab
                Center(child: Text('Movie Content')),
                // Content for TV Shows tab
                Center(child: Text('TV Shows Content')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onSearchPressed(BuildContext context) {
    // Custom search action for BrowsePage
  }

  @override
  void onFilterPressed(BuildContext context) {
    // Custom filter action for BrowsePage
  }
}

class NovelTab extends StatelessWidget {
  final String tabType;
  const NovelTab({super.key, required this.tabType});

  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers) async {
    switch(tabType){
      case('novel'):
        final lightNovelPub = LightNovelPub();
        final contentList = await lightNovelPub.fetchBrowseList(pageNumbers);
        return contentList;
      case('manga'):
        final batoto = Batoto();
        final contentList = await batoto.fetchBrowseList(pageNumbers);
        return contentList;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ContentData>>(
      future: fetchBrowseList([1, 2]), // Fetch content list for given page numbers
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
          final List<ContentData> cardItems = snapshot.data ?? []; // Get the fetched list
          return CardLayout(cardItems: cardItems); // Build CardLayout with fetched content
        }
      },
    );
  }
}
