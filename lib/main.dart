import 'package:flutter/material.dart';
import 'package:luna/components/pages/main_layout.dart';
import 'package:luna/components/pages/home.dart';
import 'package:luna/components/pages/favorites.dart';
import 'package:luna/components/pages/history.dart';
import 'package:luna/components/pages/browse.dart';
import 'package:luna/components/pages/settings.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainLayout(
        pages: {
          'home': HomePage(),
          'favorites': FavoritesPage(),
          'browse': BrowsePage(),
          'history': HistoryPage(),
          'settings': SettingsPage(),
        },
      ),
    );
  }
}
