import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';

class SettingsPage extends LunaBasePage {
  SettingsPage({Key? key}) : super(key: key, title: 'Settings Page');

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
      child: Text('Settings Page Content'),
    );
  }
}
