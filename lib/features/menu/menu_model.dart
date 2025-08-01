
import 'package:flutter/material.dart';

// 메뉴 항목 데이터 모델
class Menu {
  final String name;
  final String path;
  final IconData icon;
  final bool showInBottomNav; // Bottom Navigation에 표시할지 여부
  final bool isAdmin; // 어드민 전용 메뉴 여부

  const Menu({
    required this.name,
    required this.path,
    required this.icon,
    this.showInBottomNav = false,
    this.isAdmin = false, // 기본값은 false
  });
}
