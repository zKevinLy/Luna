import 'package:flutter/material.dart';

abstract class LunaBasePage extends StatefulWidget {
  LunaBasePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LunaBasePageState createState() => _LunaBasePageState();

  List<Widget> buildActions(BuildContext context) => [];
  Widget buildBody(BuildContext context);
  
  // To be implemented by inherited classes
  void onSearchPressed(BuildContext context) {}
  void onFilterPressed(BuildContext context) {}
}

class _LunaBasePageState extends State<LunaBasePage> {
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text(widget.title),
        actions: _buildAppBarActions(),
      ),
      body: widget.buildBody(context),
    );
  }

  List<Widget> _buildAppBarActions() {
    List<Widget> defaultActions = [
      Tooltip(
        message: _isSearching ? 'Close search' : 'Search',
        child: IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
            if (!_isSearching) {
              widget.onSearchPressed(context);
            }
          },
        ),
      ),
      Tooltip(
        message: 'Filter',
        child: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            widget.onFilterPressed(context);
          },
        ),
      ),
    ];

    List<Widget> additionalActions = widget.buildActions(context);
    return [...defaultActions, ...additionalActions];
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              autofocus: true,
              onSubmitted: (value) {
                // Handle search query here
                print('Search query: $value');
                _searchController.clear();
              },
            ),
          ),
        ),
      ],
    );
  }


}
