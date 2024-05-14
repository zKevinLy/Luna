import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';

class FavoritesPage extends LunaBasePage {
  FavoritesPage({Key? key}) : super(key: key, title: 'Favorites Page');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          // Handle settings icon press
        },
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return const Center(
      child: Text('Favorites Page Content'),
    );
  }
}
