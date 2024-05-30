import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';

class ExamplePage extends LunaBasePage {
  ExamplePage({Key? key}) : super(key: key, title: 'Example Page');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Tooltip(
        message: 'Settings',
        child: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // Handle settings icon press
            print('Settings pressed');
          },
        ),
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return const Center(
      child: Text('Example Page Content'),
    );
  }
}
