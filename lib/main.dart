
import 'package:flutter/material.dart';
import 'package:luna/components/pages/main_layout.dart';
import 'package:luna/components/pages/main-pages/home.dart';
import 'package:luna/components/pages/main-pages/favorites.dart';
import 'package:luna/components/pages/main-pages/history.dart';
import 'package:luna/components/pages/main-pages/browse.dart';
import 'package:luna/components/pages/main-pages/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark, // Set the theme mode to dark
      darkTheme: ThemeData.dark(),
      home: const MainLayout(
        pages: {
          'home':       {'page': BrowsePage(), 'icon': Icons.home}, 
          'favorites':  {'page': BrowsePage(), 'icon': Icons.favorite}, 
          'browse':     {'page': BrowsePage(), 'icon': Icons.search}, 
          'history':    {'page': BrowsePage(), 'icon': Icons.history}, 
          'settings':   {'page': BrowsePage(), 'icon': Icons.settings}, 
        },
      ),
    );
  }
}