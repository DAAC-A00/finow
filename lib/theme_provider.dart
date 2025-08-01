
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ThemeModeNotifierProvider는 ThemeModeNotifier를 제공하는 Provider입니다.
// 사용자가 선택한 테마 모드(System, Light, Dark)를 관리합니다.
final themeModeNotifierProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // 앱의 초기 테마 모드를 시스템 설정에 따르도록 설정합니다.
    return ThemeMode.system;
  }

  // 사용자가 선택한 테마로 변경하는 메서드
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

