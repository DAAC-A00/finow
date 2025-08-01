
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_repository.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(menuRepositoryProvider).getMenus();
    final bottomNavMenus = menus.where((m) => m.showInBottomNav).toList();
    
    final currentIndex = _calculateCurrentIndex(context, bottomNavMenus);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavMenus.map((menu) {
          return BottomNavigationBarItem(
            icon: Icon(menu.icon),
            label: menu.name,
          );
        }).toList(),
        currentIndex: currentIndex,
        onTap: (index) {
          context.go(bottomNavMenus[index].path);
        },
        // 활성/비활성 탭 스타일 지정
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  int _calculateCurrentIndex(BuildContext context, List<dynamic> bottomNavMenus) {
    final location = GoRouterState.of(context).uri.toString();
    final index = bottomNavMenus.indexWhere((menu) => menu.path == location);
    return index > -1 ? index : 0; // 일치하는 경로가 없으면 0번 인덱스로
  }
}
