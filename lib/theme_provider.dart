
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeNotifierProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _themeModeKey = 'themeMode';

  @override
  ThemeMode build() {
    final localStorage = ref.watch(localStorageServiceProvider);
    // Hive에서 저장된 테마 모드 값을 읽어옵니다.
    final themeName = localStorage.read<String>(_themeModeKey, defaultValue: ThemeMode.system.name);
    // String을 ThemeMode enum으로 변환하여 반환합니다.
    return ThemeMode.values.firstWhere((e) => e.name == themeName, orElse: () => ThemeMode.system);
  }

  void setThemeMode(ThemeMode mode) {
    final localStorage = ref.read(localStorageServiceProvider);
    // 새로운 테마 모드를 Hive에 저장합니다.
    localStorage.write(_themeModeKey, mode.name);
    state = mode;
  }
}

