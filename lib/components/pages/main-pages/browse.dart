import 'package:flutter/material.dart';
import 'package:luna/components/modals/filter_modal.dart';
import 'package:luna/components/pages/content_layout.dart';
import 'package:luna/models/page_info.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/fetch_content.dart';
import 'package:luna/components/modals/settings_modal.dart';
import 'package:luna/components/pages/search.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luna/components/pages/controllers/shared_preferences.dart';
import 'package:luna/utils/text_parser.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final pageData = PageData(
    pageID: "browse",
    pageName: "Browse",
    pageURI: "/browse",
    isSearching: false,
    isFiltering: false,
    cardItems: [],
    searchResults: [],
    selectedTab: '',
    selectedSources: {},
    selectedFilters: {},
    tabSources: {
      "Anime": [],
      "Manga": ["batoto", "mangasee"],
      "Novel": ["light_novel_pub"],
      "Movie": [],
      "TV Shows": []
    },
  );

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedSources("Anime");
  }

  void _loadSavedSources(String tabName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var source in pageData.tabSources[sanitize(tabName)] ?? []) {
        pageData.selectedSources[source] = prefs.getBool(source) ?? false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: pageData.tabSources.length,
      child: GestureDetector(
        onTap: () {
          setState(() {
            pageData.isSearching = false;
          });
        },
        child: Scaffold(
          appBar: AppBar(
            title: pageData.isSearching
                ? SearchInput(
                    controller: _searchController,
                    onSearchSubmitted: _onSearchSubmitted,
                  )
                : const Text('Browse', key: ValueKey('Title')),
            actions: _buildAppBarActions(),
            bottom: TabBar(
              tabs: pageData.tabSources.keys
                  .map((name) => Tab(text: name))
                  .toList(),
              onTap: (index) {
                setState(() {
                  pageData.isFiltering = false;
                  pageData.isSearching = false;
                  pageData.selectedTab = sanitize(pageData.tabSources.keys.toList()[index]);
                  pageData.cardItems.clear();
                  _updateCardItems();
                });
              },
            ),
          ),
          body: _buildTabBarView(context),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    List<Widget> actions = [
      Tooltip(
        message: pageData.isSearching ? 'Close search' : 'Search',
        child: IconButton(
          icon: Icon(pageData.isSearching ? Icons.close : Icons.search),
          onPressed: () {
            _onSearchPressed();
          },
        ),
      ),
      Tooltip(
        message: 'Filter',
        child: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            _onFilterPressed();
          },
        ),
      ),
      Tooltip(
        message: 'Settings',
        child: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            _onSettingsPressed();
          },
        ),
      ),
    ];
    return actions;
  }

  Widget _buildTabBarView(BuildContext context) {
    return TabBarView(
      children: pageData.tabSources.keys.map((tabName) {
        if (pageData.isSearching || (pageData.isFiltering && pageData.cardItems.isNotEmpty)) {
          return _buildGridView(context, pageData.searchResults);
        } else {
          var tabNameLower = sanitize(tabName);
          if (pageData.selectedTab == tabNameLower) {
            return _buildSubPage(tabType: tabNameLower);
          } else {
            return Container(); 
          }
        }
      }).toList(),
    );
  }

  Widget _buildSubPage({required String tabType}) {
    return FutureBuilder<List<ContentData>>(
      future: fetchBrowseList(tabType, [1], getActiveSources(pageData.selectedSources)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          pageData.cardItems = snapshot.data!;
          return _buildGridView(context, pageData.cardItems);
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<ContentData> cardItems) {
    return CustomScrollView(
      slivers: [
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width ~/ 200, // Adjust the width here
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.75, // Adjust the aspect ratio here
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildCard(context, cardItems[index]);
            },
            childCount: cardItems.length,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildLoadMoreItem(),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, ContentData cardItem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentLayout(cardItem: cardItem),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                cardItem.imageURI,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cardItem.title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchPressed() {
    setState(() {
      if (pageData.isSearching) {
        pageData.isSearching = false;
        _searchController.clear();
        _onSearchClear();
      } else {
        pageData.isSearching = true;
      }
    });
  }

  void _onFilterPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: fetchBrowseGenreList(pageData.selectedTab, selectedSources: pageData.selectedSources),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return FiltersModal(
              options: snapshot.data!,
              onOptionsChanged: (selectedFilters) async {
                pageData.selectedFilters = selectedFilters;
                pageData.isFiltering = true;
                pageData.searchResults = await fetchSearch(pageData.cardItems, pageData.selectedTab, [1], getActiveGenres(selectedFilters), getActiveSources(pageData.selectedSources));
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  void _onSettingsPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsModal(
        options: pageData.tabSources.entries
            .where((entry) => sanitize(sanitize(entry.key)) == sanitize(pageData.selectedTab))
            .map((entry) => entry.value)
            .first,
        onOptionsChanged: (selected) async {
          pageData.selectedSources = selected;
          saveSelectedSources(pageData); // Save the selected sources
          setState(() {});
        },
      ),
    );
  }

  void _onSearchSubmitted(String query) async {
    pageData.searchResults = await fetchSearch(pageData.cardItems, pageData.selectedTab, [1], getActiveGenres(pageData.selectedFilters), getActiveSources(pageData.selectedSources), searchTerm: query);
    setState(() {});
  }

  void _onSearchClear() async {
    pageData.searchResults = pageData.cardItems;
    setState(() {});
  }

  Widget _buildLoadMoreItem() {
    // Implement load more item
    return Container();
  }

  void _updateCardItems() {
    setState(() {});
  }
}
