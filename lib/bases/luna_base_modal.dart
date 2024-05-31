import 'package:flutter/material.dart';

class BaseModal extends StatelessWidget {
  final List<Widget> content;
  final VoidCallback onDismissed;

  BaseModal({required this.content, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool value) {
        onDismissed();
      },
      child: DraggableScrollableSheet(
        expand: false,
        builder: _buildModalContent,
      ),
    );
  }

  Widget _buildModalContent(BuildContext context, ScrollController scrollController) {
    return Container(
      decoration: _buildContainerDecoration(context),
      child: Column(
        children: [
          _buildDivider(context),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.colorScheme.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10.0,
          spreadRadius: 0.5,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 50,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
