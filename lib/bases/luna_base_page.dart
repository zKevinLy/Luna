import 'package:flutter/material.dart';

// Base Page class
abstract class BasePage extends StatelessWidget {
  // Title of the page
  final String title;

  // Content widget of the page
  final Widget content;


  const BasePage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: content,
      key: key,
    );
  }
}
