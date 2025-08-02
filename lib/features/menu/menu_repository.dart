
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/menu/menu_model.dart';

// 전체 메뉴 목록을 제공하는 Provider
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuRepository {
  final List<Menu> _menus = const [
    Menu(name: 'Home', path: '/home', icon: Icons.home, showInBottomNav: true),
    Menu(name: 'Exchange Rate', path: '/exchange', icon: Icons.attach_money, showInBottomNav: true),
    Menu(name: 'Favorites', path: '/favorites', icon: Icons.favorite, showInBottomNav: true),
    Menu(name: 'Menu', path: '/menu', icon: Icons.menu, showInBottomNav: true), // 전체 메뉴 -> Menu
    Menu(name: 'Profile', path: '/profile', icon: Icons.person, showInBottomNav: false),
    Menu(name: 'Settings', path: '/settings', icon: Icons.settings, showInBottomNav: false),
    Menu(name: 'Storage', path: '/storage', icon: Icons.storage, showInBottomNav: false), // 어드민 메뉴
  ];

  List<Menu> getMenus() => _menus;
}
