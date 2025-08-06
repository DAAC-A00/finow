import 'package:flutter/material.dart';

class ToggleSwitchTestWidget extends StatefulWidget {
  const ToggleSwitchTestWidget({super.key});

  @override
  State<ToggleSwitchTestWidget> createState() => _ToggleSwitchTestWidgetState();
}

class _ToggleSwitchTestWidgetState extends State<ToggleSwitchTestWidget> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Toggle Switch'),
      value: _isSwitched,
      onChanged: (value) {
        setState(() {
          _isSwitched = value;
        });
      },
    );
  }
}
