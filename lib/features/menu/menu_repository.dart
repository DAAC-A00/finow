
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/menu/menu_model.dart';

// 전체 메뉴 목록을 제공하는 Provider
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuRepository {
  final List<Menu> _menus = const [
    Menu(name: '홈', path: '/home', icon: Icons.home, showInBottomNav: true),
    Menu(name: '검색', path: '/search', icon: Icons.search, showInBottomNav: true),
    Menu(name: '알림', path: '/notifications', icon: Icons.notifications, showInBottomNav: true),
    Menu(name: '전체메뉴', path: '/menu', icon: Icons.menu, showInBottomNav: true),
    // 아래 메뉴들은 전체메뉴 화면에서만 보임
    Menu(name: '프로필', path: '/profile', icon: Icons.person),
    Menu(name: '설정', path: '/settings', icon: Icons.settings),
    Menu(name: '도움말', path: '/help', icon: Icons.help),
    // 어드민 전용 메뉴
    Menu(name: '어드민', path: '/admin', icon: Icons.admin_panel_settings, isAdmin: true),
  ];

  List<Menu> getMenus() => _menus;
}
