
import 'package:flutter/material.dart';

// 메뉴 항목을 정의하는 데이터 클래스
class Menu {
  final String name;
  final String path;
  final IconData icon;
  final bool showInBottomNav;

  const Menu({
    required this.name,
    required this.path,
    required this.icon,
    this.showInBottomNav = false,
  });

  // 이름이 'Storage'인 메뉴를 어드민 전용으로 간주 (기존 로직 복원)
  bool get isAdmin => name == 'Storage';
}

