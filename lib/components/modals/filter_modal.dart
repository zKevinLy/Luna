import 'package:flutter/material.dart';

class FiltersModal extends StatefulWidget {
  final List<String> filters;
  final ValueChanged<Map<String, bool>> onFiltersChanged;

  FiltersModal({
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  _FiltersModalState createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> {
  late Map<String, bool> _filtersState;
  late bool _selectAll;

  @override
  void initState() {
    super.initState();
    _initializeFiltersState();
  }

  void _initializeFiltersState() {
    _filtersState = {for (var filter in widget.filters) filter: false};
    _selectAll = false;
  }

  void _onDone(bool value) {
    widget.onFiltersChanged(_filtersState);
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      _filtersState.forEach((key, _) {
        _filtersState[key] = value ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool value) {
        _onDone(value);
      },
      child: DraggableScrollableSheet(
        expand: false,
        builder: _buildModalContent,
      ),
    );
  }

  Widget _buildModalContent(BuildContext context, ScrollController scrollController) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: Column(
        children: [
          _buildDivider(),
          _buildSelectAllCheckbox(),
          _buildOptionsList(scrollController)
          
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
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

  Widget _buildSelectAllCheckbox() {
    return CheckboxListTile(
      title: Text(
        'Select All',
        style: _buildTitleStyle(),
      ),
      value: _selectAll,
      onChanged: _toggleSelectAll,
    );
  }

  TextStyle _buildTitleStyle() {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color) ?? const TextStyle();
  }

  Widget _buildOptionsList(ScrollController scrollController) {
    return Expanded(
      child: ListView(
        controller: scrollController,
        children: widget.filters.map((filter) {
          return _buildFilterOption(
            title: filter,
            value: _filtersState[filter]!,
            onChanged: (value) {
              setState(() {
                _filtersState[filter] = value ?? false;
              });
            },
            color: Theme.of(context).colorScheme.secondary,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterOption({required String title, required bool value, required ValueChanged<bool?> onChanged, required Color color}) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
      ),
      trailing: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }

  Widget _buildDivider() {
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
