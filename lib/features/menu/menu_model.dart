import 'package:flutter/material.dart';

class Menu {
  final String name;
  final String path;
  final IconData icon;
  final bool showInBottomNav;

  const Menu({
    required this.name,
    required this.path,
    required this.icon,
    required this.showInBottomNav,
  });
}
