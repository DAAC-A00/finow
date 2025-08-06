import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_repository.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(menuRepositoryProvider).getMenus();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Menus'),
      ),
      body: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          return ListTile(
            leading: Icon(menu.icon),
            title: Text(menu.name),
            onTap: () {
              if (menu.path == '/menu') return;

              if (menu.showInBottomNav) {
                context.go(menu.path);
              } else {
                context.push(menu.path);
              }
            },
          );
        },
      ),
    );
  }
}
