
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_repository.dart';
import 'package:finow/features/menu/menu_screen.dart';
import 'package:finow/screens/main_screen.dart';
import 'package:finow/screens/placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final menuRepository = ref.watch(menuRepositoryProvider);
  final menus = menuRepository.getMenus();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // BottomNavigationBar가 있는 메인 화면 레이아웃
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        // MainScreen 위에 표시될 화면들
        routes: [
          ...menus.where((m) => m.showInBottomNav).map((menu) {
            return GoRoute(
              path: menu.path,
              builder: (context, state) {
                if (menu.path == '/menu') {
                  return const MenuScreen();
                }
                return PlaceholderScreen(title: menu.name);
              },
            );
          }),
          // BottomNav에 없는 화면들도 여기에 정의
          ...menus.where((m) => !m.showInBottomNav).map((menu) {
             return GoRoute(
              path: menu.path,
              // 이 화면들은 별도의 Navigator에 표시될 수 있도록 parentNavigatorKey 설정 가능
              builder: (context, state) => PlaceholderScreen(title: menu.name),
            );
          })
        ],
      ),
    ],
  );
});
