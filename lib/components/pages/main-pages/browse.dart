import 'package:flutter/material.dart';
import 'package:luna/components/modals/filter_modal.dart';
import 'package:luna/components/pages/content_layout.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/Providers/fetch_content.dart';
import 'package:luna/components/modals/settings_modal.dart';
import 'package:luna/components/pages/search.dart'; // Import the SearchBar
class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  String selectedTab = "";
  List<String> tabNames = ["Anime", "Manga", "Novel", "Movie", "TV Shows"];
  List<ContentData> cardItems = [];
  List<ContentData> searchResults = []; // Variable to hold search results
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
                  selectedTab =
                      tabNames[index].toLowerCase().replaceAll(" ", "");
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
    if (_isSearching) {
      return _buildGridView(context, searchResults);
    } else {
      var tabNameLower = tabName.toLowerCase();
      switch (tabName) {
        case 'Manga':
        case 'Novel':
          return _buildSubPage(tabType: tabNameLower);
        default:
          return Center(child: Text('$tabNameLower Content'));
      }
    }
  }

  Widget _buildSubPage({required String tabType}) {
    return FutureBuilder<List<ContentData>>(
      future: fetchBrowseList(tabType, [1]),
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
      builder: (context) => FiltersModal(
        filters: ['Filter 1', 'Filter 2', 'Filter 3'], // Define your filters here
        onFiltersChanged: (updatedFilters) {
          // Handle the updated filters here
          print(updatedFilters);
        },
      ),
    );
  }

  void _onSettingsPressed() {
    List<String> options = ['Option 1', 'Option 2', 'Option 3']; // Define your options here

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsModal(
        options: options,
        onOptionsChanged: (updatedOptions) {
          // Handle the updated options here
          print(updatedOptions);
        },
      ),
    );
  }

  void _onSearchSubmitted(String query) async {
    searchResults = await fetchSearch(selectedTab, [1], query);
    print("Search Results:");
    for (var result in searchResults) {
      print("Title: ${result.title}, Image URI: ${result.imageURI}");
    }
    setState(() {});
  }

  void _onSearchClear() async {
    searchResults.clear();
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
