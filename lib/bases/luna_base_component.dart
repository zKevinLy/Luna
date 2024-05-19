import 'package:flutter/material.dart';

// Base component class
abstract class BaseComponent extends StatelessWidget {
  final String title;

  const BaseComponent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the title provided to the component
           Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          // Custom build method for extending components to implement
          buildCustomContent(context),
        ],
      );
  }

  // Abstract method for extending components to implement
  Widget buildCustomContent(BuildContext context);
}
