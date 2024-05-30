import 'package:flutter/material.dart';

class SettingsModal extends StatefulWidget {
  final List<String> options;
  final ValueChanged<Map<String, bool>> onOptionsChanged;

  SettingsModal({
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  _SettingsModalState createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late Map<String, bool> _optionsState;
  bool _allOptions = false;

  @override
  void initState() {
    super.initState();
    _initializeOptionsState();
  }

  void _initializeOptionsState() {
    _optionsState = {for (var option in widget.options) option: false};
  }

  void _toggleAllOptions(bool value) {
    setState(() {
      _allOptions = value;
      _optionsState.updateAll((key, _) => value);
    });
  }

  void _checkAllOptions() {
    setState(() {
      _allOptions = _optionsState.values.every((value) => value);
    });
  }

  void _onDone(bool value) {
    widget.onOptionsChanged(_optionsState);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onDone,
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
          _buildAllOptionsSwitch(),
          _buildOptionsList(scrollController),
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

  Widget _buildAllOptionsSwitch() {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.select_all, color: theme.primaryColor),
      title: Text(
        'All Options',
        style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
      ),
      trailing: Switch(
        value: _allOptions,
        onChanged: _toggleAllOptions,
      ),
    );
  }

  Widget _buildOptionsList(ScrollController scrollController) {
    return Expanded(
      child: ListView(
        controller: scrollController,
        children: widget.options.map(_buildSettingsOption).toList(),
      ),
    );
  }

  Widget _buildSettingsOption(String option) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.settings, color: theme.primaryColor),
      title: Text(
        option,
        style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
      ),
      trailing: Switch(
        value: _optionsState[option]!,
        onChanged: (value) {
          setState(() {
            _optionsState[option] = value;
            _checkAllOptions();
          });
        },
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
