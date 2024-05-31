import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luna/bases/luna_base_modal.dart';

class FiltersModal extends StatefulWidget {
  final List<String> options;
  final ValueChanged<Map<String, dynamic>> onOptionsChanged;

  FiltersModal({
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  _FiltersModalState createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> {
  late Map<String, dynamic> _optionsState;
  bool _allOptions = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeOptionsState();
    _loadSavedOptions();
  }

  void _initializeOptionsState() {
    _optionsState = {for (var option in widget.options) option: false};
  }

  void _loadSavedOptions() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var option in widget.options) {
        _optionsState[option] = _prefs.getBool(option) ?? false;
      }
      _allOptions = _optionsState.values.every((value) => value);
    });
  }

  void _saveOptionsState() {
    for (var entry in _optionsState.entries) {
      _prefs.setBool(entry.key, entry.value);
    }
  }

  void _toggleAllOptions(bool value) {
    setState(() {
      _allOptions = value;
      _optionsState.updateAll((key, _) => value);
      _saveOptionsState();
      widget.onOptionsChanged(_optionsState);
    });
  }

  List<Widget> _buildContent() {
    final theme = Theme.of(context);
    return [
      ListTile(
        leading: Icon(Icons.select_all, color: theme.primaryColor),
        title: Text(
          'Default/All Options',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
        ),
        trailing: Switch(
          value: _allOptions,
          onChanged: _toggleAllOptions,
        ),
      ),
      ...widget.options.map((option) {
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.trailing,
          title: Text(
            option,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
          ),
          value: _optionsState[option],
          onChanged: (value) {
            setState(() {
              _optionsState[option] = value;
              _saveOptionsState();
              _allOptions = _optionsState.values.every((value) => value);
              widget.onOptionsChanged(_optionsState);
            });
          },
        );
      }).toList(),
    ];
  }

  void _onModalDismissed() {
    widget.onOptionsChanged(_optionsState);
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      content: _buildContent(),
      onDismissed: _onModalDismissed,
    );
  }
}
