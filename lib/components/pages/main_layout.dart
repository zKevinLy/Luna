import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final Map<String, Map<String, dynamic>> pages; // Modified to accept Map<String, Map<String, dynamic>>

  const MainLayout({super.key, required this.pages});

  @override
  MainLayoutState createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  late String _selectedPageKey;

  @override
  void initState() {
    super.initState();
    _selectedPageKey = widget.pages.keys.first; // Set initial page
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile view
          return _buildMobileView();
        } else {
          // Desktop view
          return _buildDesktopView();
        }
      },
    );
  }

  Widget _buildMobileView() {
    return Scaffold(
      body: widget.pages[_selectedPageKey]?['page'] ?? Container(), // Updated to access the 'page' key
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        currentIndex: widget.pages.keys.toList().indexOf(_selectedPageKey),
        onTap: (int index) {
          setState(() {
            _selectedPageKey = widget.pages.keys.toList()[index];
          });
        },
        items: widget.pages.keys.map((key) {
          return BottomNavigationBarItem(
            icon: Icon(
              widget.pages[key]?['icon'] ?? Icons.error, // Updated to access the 'icon' key
              color: Theme.of(context).iconTheme.color,
            ),
            label: key.split(' ').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' '),
          );
        }).toList(),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  Widget _buildDesktopView() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.pages.keys.toList().indexOf(_selectedPageKey),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedPageKey = widget.pages.keys.toList()[index];
              });
            },
            // Nav Buttons
            labelType: NavigationRailLabelType.all,
            destinations: widget.pages.keys.map((key) {
              return NavigationRailDestination(
                icon: Icon(widget.pages[key]?['icon'] ?? Icons.error),
                label: Text(key.split(' ').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ')),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Display selected page based on key
          Expanded(child: widget.pages[_selectedPageKey]?['page'] ?? Container()), 
        ],
      ),
    );
  }
}