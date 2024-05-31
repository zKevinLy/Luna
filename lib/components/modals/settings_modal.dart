import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luna/bases/luna_base_modal.dart';

class SettingsModal extends StatefulWidget {
  final List<String> options;
  final ValueChanged<Map<String, dynamic>> onOptionsChanged;

  SettingsModal({
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  _SettingsModalState createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late Map<String, dynamic> _optionsState;
  bool _allOptions = false;
  int _selectedCount = 0;
  final int _selectionLimit = 1;
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
        if (_optionsState[option]) {
          _selectedCount++;
        }
      }
      _allOptions = _selectedCount == widget.options.length;
    });
  }

  void _saveOptionsState() {
    for (var entry in _optionsState.entries) {
      _prefs.setBool(entry.key, entry.value);
    }
  }

  void _toggleAllOptions(bool value) {
    setState(() {
      if (value) {
        _selectedCount = 0;
        _optionsState.updateAll((key, _) => false);
        for (var option in widget.options) {
          if (_selectedCount < _selectionLimit) {
            _optionsState[option] = true;
            _selectedCount++;
          } else {
            break;
          }
        }
        _allOptions = true;
      } else {
        _allOptions = false;
        _optionsState.updateAll((key, _) => false);
        _selectedCount = 0;
      }
      _saveOptionsState();
    });
  }

  void _checkAllOptions() {
    setState(() {
      _allOptions = _optionsState.values.every((value) => value);
    });
  }

  void _onOptionChanged(String option, bool value) {
    setState(() {
      if (value && _selectedCount < _selectionLimit) {
        _optionsState[option] = value;
        _selectedCount++;
      } else if (!value) {
        _optionsState[option] = value;
        _selectedCount--;
      }
      _checkAllOptions();
      _saveOptionsState();
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
          onChanged: (value) {
            _toggleAllOptions(value);
          },
        ),
      ),
      ...widget.options.map((option) {
        return ListTile(
          leading: Icon(Icons.settings, color: theme.primaryColor),
          title: Text(
            option,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
          ),
          trailing: Switch(
            value: _optionsState[option],
            onChanged: (value) {
              if (!value || _selectedCount < _selectionLimit) {
                _onOptionChanged(option, value);
              }
            },
            activeColor: _optionsState[option] || _selectedCount < _selectionLimit
                ? theme.toggleableActiveColor
                : theme.disabledColor,
          ),
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
