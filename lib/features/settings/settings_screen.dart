
import 'package:finow/features/settings/admin_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finow/theme_provider.dart';
import 'package:finow/font_size_provider.dart';
import 'package:finow/ui_scale_provider.dart';

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
        title: const ScaledText('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: ScaledText('Theme Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioListTile<ThemeMode>(
            title: const ScaledText('System Theme'),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const ScaledText('Light Mode'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const ScaledText('Dark Mode'),
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
            title: ScaledText('Font Size Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...FontSizeOption.values.map((fontSize) => RadioListTile<FontSizeOption>(
            title: ScaledText(fontSize.label),
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
            title: const ScaledText('Admin Mode'),
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
