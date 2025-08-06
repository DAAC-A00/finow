import 'package:finow/features/settings/admin_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/menu/menu_model.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final isAdminMode = ref.watch(adminModeProvider);
  return MenuRepository(isAdminMode);
});

class MenuRepository {
  final bool _isAdminMode;

  MenuRepository(this._isAdminMode);

  final List<Menu> _baseMenus = const [
    Menu(name: 'Home', path: '/home', icon: Icons.home, showInBottomNav: true),
    Menu(name: 'Exchange Rate', path: '/exchange', icon: Icons.attach_money, showInBottomNav: true),
    Menu(name: 'Menu', path: '/menu', icon: Icons.menu, showInBottomNav: true),
    Menu(name: 'Settings', path: '/settings', icon: Icons.settings, showInBottomNav: false),
  ];

  final List<Menu> _adminMenus = const [
    Menu(name: 'Storage', path: '/storage', icon: Icons.storage, showInBottomNav: false),
    Menu(name: 'Laboratory', path: '/laboratory', icon: Icons.science, showInBottomNav: false),
  ];

  List<Menu> getMenus() {
    if (_isAdminMode) {
      return [..._baseMenus, ..._adminMenus];
    }
    return _baseMenus;
  }
}
