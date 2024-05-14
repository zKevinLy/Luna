import 'package:flutter/material.dart';
import 'package:luna/components/pages/main_layout.dart';
import 'package:luna/components/pages/main-pages/home.dart';
import 'package:luna/components/pages/main-pages/favorites.dart';
import 'package:luna/components/pages/main-pages/history.dart';
import 'package:luna/components/pages/main-pages/browse.dart';
import 'package:luna/components/pages/main-pages/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark, // Set the theme mode to dark
      darkTheme: ThemeData.dark(),
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
