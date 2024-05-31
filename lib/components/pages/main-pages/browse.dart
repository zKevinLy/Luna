import 'package:flutter/material.dart';
import 'package:luna/components/modals/filter_modal.dart';
import 'package:luna/components/pages/content_layout.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/fetch_content.dart';
import 'package:luna/components/modals/settings_modal.dart';
import 'package:luna/components/pages/search.dart'; // Import the SearchBar
import 'package:shared_preferences/shared_preferences.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  String selectedTab = "";
  Map<String, dynamic> selectedSources = {};
  Map<String, dynamic> selectedFilters = {};

  List<String> tabNames = ["Anime", "Manga", "Novel", "Movie", "TV Shows"];
  Map<String, List<String>> tabSources = {
    "anime": [],
    "manga": ["batoto", "mangasee"],
    "novel": ["light_novel_pub"],
    "movie": [],
    "tvshows": []
  };

  List<ContentData> cardItems = [];
  List<ContentData> searchResults = []; // Variable to hold search results
  bool _isSearching = false;
  bool _isFiltering = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedSources("Anime");
  }

  void _loadSavedSources(String tabName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var key = tabName.toLowerCase();
    setState(() {
      for (var source in tabSources[key] ?? []) {
        selectedSources[source] = prefs.getBool(source) ?? false;
      }
    });
  }


  void _saveSelectedSources() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var entry in selectedSources.entries) {
      prefs.setBool(entry.key, entry.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabNames.length,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSearching = false;
          });
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? SearchInput(
                    controller: _searchController,
                    onSearchSubmitted: _onSearchSubmitted,
                  )
                : const Text('Browse', key: ValueKey('Title')),
            actions: _buildAppBarActions(),
            bottom: TabBar(
              tabs: tabNames.map((name) => Tab(text: name)).toList(),
              onTap: (index) {
                setState(() {
                  _isFiltering = false;
                  _isSearching = false;
                  selectedTab = tabNames[index].toLowerCase().replaceAll(" ", "");
                  cardItems.clear();
                  _updateCardItems();
                });
              },
            ),
          ),
          body: _buildTabBarView(),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    List<Widget> actions = [
      Tooltip(
        message: _isSearching ? 'Close search' : 'Search',
        child: IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
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

  Widget _buildTabBarView() {
    return TabBarView(
      children: [
        for (var tabName in tabNames) _buildTabContent(tabName),
      ],
    );
  }

  Widget _buildTabContent(String tabName) {
    if (_isSearching || _isFiltering && cardItems.isNotEmpty) {
      return _buildGridView(context, searchResults);
    } else {
      var tabNameLower = tabName.toLowerCase().replaceAll(" ", "");
      switch (tabNameLower) {
        case 'manga':
        case 'novel':
          if (selectedTab == tabNameLower) {
            return _buildSubPage(tabType: tabNameLower);
          }
          return Container();
        default:
          return Center(child: Text('$tabNameLower Content'));
      }
    }
  }

  Widget _buildSubPage({required String tabType}) {
    return FutureBuilder<List<ContentData>>(
      future: fetchBrowseList(tabType, [1], getActiveSources(selectedSources)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          cardItems = snapshot.data!;
          return _buildGridView(context, cardItems);
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
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
        _onSearchClear();
      } else {
        _isSearching = true;
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
          future: fetchBrowseGenreList(selectedTab, selectedSources: selectedSources),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return FiltersModal(
              options: snapshot.data!,
              onOptionsChanged: (selectedFilters) async {
                selectedFilters = selectedFilters;
                _isFiltering = true;
                searchResults = await fetchSearch(cardItems, selectedTab, [1], getActiveGenres(selectedFilters), getActiveSources(selectedSources));
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
        options: tabSources[selectedTab] ?? [],
        onOptionsChanged: (selected) async {
          selectedSources = selected;
          _saveSelectedSources(); // Save the selected sources
          setState(() {});
        },
      ),
    );
  }

  void _onSearchSubmitted(String query) async {
    searchResults = await fetchSearch(cardItems, selectedTab, [1], getActiveGenres(selectedFilters), getActiveSources(selectedSources), searchTerm: query);
    setState(() {});
  }

  List<String> getActiveGenres(Map<String, dynamic> selectedFilters) {
    return selectedFilters.entries
      .where((entry) => entry.value == true)
      .map((entry) => entry.key)
      .toList();
  }

  List<String> getActiveSources(Map<String, dynamic> selectedSources) {
    return selectedSources.entries
      .where((entry) => entry.value == true)
      .map((entry) => entry.key)
      .toList();
  }

  void _onSearchClear() async {
    searchResults = cardItems;
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
