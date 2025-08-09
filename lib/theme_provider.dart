import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeNotifierProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _themeModeKey = 'themeMode';

  @override
  ThemeMode build() {
    final localStorage = ref.watch(localStorageServiceProvider);
    final themeName = localStorage.read<String>(_themeModeKey) ?? ThemeMode.system.name;
    return ThemeMode.values.firstWhere((e) => e.name == themeName, orElse: () => ThemeMode.system);
  }

  void setThemeMode(ThemeMode mode) {
    final localStorage = ref.read(localStorageServiceProvider);
    localStorage.write(_themeModeKey, mode.name);
    state = mode;
  }
}

class AppTheme {
  static ThemeData getLightTheme(double scale) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
      brightness: Brightness.light,
    );
    return _getScaledTheme(baseTheme, scale);
  }

  static ThemeData getDarkTheme(double scale) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      brightness: Brightness.dark,
    );
    return _getScaledTheme(baseTheme, scale);
  }

  static ThemeData _getScaledTheme(ThemeData baseTheme, double scale) {
    return baseTheme.copyWith(
      cardTheme: baseTheme.cardTheme.copyWith(
        elevation: 2.0,
        margin: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 6.0 * scale),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0 * scale),
        ),
      ),
      listTileTheme: baseTheme.listTileTheme.copyWith(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 8.0 * scale),
        horizontalTitleGap: 16.0 * scale,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
          textStyle: baseTheme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * scale),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
          textStyle: baseTheme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * scale),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
          textStyle: baseTheme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * scale),
          ),
        ),
      ),
      iconTheme: baseTheme.iconTheme.copyWith(
        size: 24.0 * scale,
      ),
      tabBarTheme: baseTheme.tabBarTheme.copyWith(
        labelPadding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 8.0 * scale),
      ),
    );
  }
}