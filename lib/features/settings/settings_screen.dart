
import 'package:finow/features/settings/admin_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeNotifierProvider);
    final isAdminMode = ref.watch(adminModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('테마 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('시스템 설정'),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('라이트 모드'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('다크 모드'),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('어드민 모드'),
            value: isAdminMode,
            onChanged: (bool value) {
              // 변경된 값을 AdminModeNotifier를 통해 업데이트합니다.
              ref.read(adminModeProvider.notifier).setAdminMode(value);
            },
          ),
        ],
      ),
    );
  }
}
