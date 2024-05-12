import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final Map<String, Widget> pages;

  const MainLayout({Key? key, required this.pages}) : super(key: key);

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

  final Map<String, IconData> iconMap = {
    'home': Icons.home,
    'favorites': Icons.favorite,
    'browse': Icons.search,
    'history': Icons.history,
    'settings': Icons.settings,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile view
          return Scaffold(
            body: widget.pages[_selectedPageKey] ?? Container(),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.grey[900], // Set a dark background color
              currentIndex: widget.pages.keys.toList().indexOf(_selectedPageKey),
              onTap: (int index) {
                setState(() {
                  _selectedPageKey = widget.pages.keys.toList()[index];
                });
              },
              items: widget.pages.keys.map((key) {
                return BottomNavigationBarItem(
                  icon: Icon(iconMap[key.toLowerCase()] ?? Icons.error),
                  label: key,
                );
              }).toList(),
            ),
          );
        } else {
          // Desktop view
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
                      icon: Icon(iconMap[key.toLowerCase()] ?? Icons.error),
                      label: Text(key.split(' ').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ')),
                    );
                  }).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Display selected page based on key
                Expanded(child: widget.pages[_selectedPageKey] ?? Container()), // Use ?? Container() for safety
              ],
            ),
          );
        }
      },
    );
  }
}
