import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';

class HomePage extends LunaBasePage {
  HomePage({Key? key}) : super(key: key, title: 'Home Page');

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
      child: Text('Home Page Content'),
    );
  }
}
