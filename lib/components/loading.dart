import 'package:flutter/material.dart';

Widget buildLoadingIndicator() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}