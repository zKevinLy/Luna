import 'package:flutter/material.dart';
import 'package:luna/bases/luna_base_page.dart';

class HistoryPage extends LunaBasePage {
  HistoryPage({Key? key}) : super(key: key, title: 'History Page');

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
      child: Text('History Page Content'),
    );
  }
}
