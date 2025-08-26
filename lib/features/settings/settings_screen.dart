// ignore_for_file: deprecated_member_use

import 'package:finow/features/settings/admin_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:finow/theme_provider.dart';
import 'package:finow/font_size_provider.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeNotifierProvider);
    final isAdminMode = ref.watch(adminModeProvider);
    final currentFontSize = ref.watch(fontSizeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Theme Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioListTile.adaptive(
            title: const Text('System Theme'),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile.adaptive(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile.adaptive(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Font Size Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...FontSizeOption.values.map((fontSize) => RadioListTile.adaptive(
            title: Text(fontSize.label),
            value: fontSize,
            groupValue: currentFontSize,
            onChanged: (FontSizeOption? value) {
              if (value != null) {
                ref.read(fontSizeNotifierProvider.notifier).setFontSize(value);
              }
            },
          )),
          const Divider(),
          SwitchListTile(
            title: const Text('Admin Mode'),
            value: isAdminMode,
            onChanged: (bool value) {
              ref.read(adminModeProvider.notifier).setAdminMode(value);
            },
          ),
        ],
      ),
    );
  }
}
