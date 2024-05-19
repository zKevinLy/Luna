import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';

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
                Center(child: Text('Manga Content')),
                // Content for Novel tab
                Center(child: Text('Novel Content')),
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
