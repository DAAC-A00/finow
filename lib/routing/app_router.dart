
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_repository.dart';
import 'package:finow/features/menu/menu_screen.dart';
import 'package:finow/routing/app_transitions.dart';
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
        pageBuilder: (context, state, child) {
          // ShellRoute 자체에는 애니메이션이 필요 없으므로 NoTransitionPage 사용
          return NoTransitionPage(
            child: MainScreen(child: child),
          );
        },
        // MainScreen 위에 표시될 화면들
        routes: [
          ...menus.where((m) => m.showInBottomNav).map((menu) {
            return GoRoute(
              path: menu.path,
              pageBuilder: (context, state) {
                final screen = (menu.path == '/menu')
                    ? const MenuScreen()
                    : PlaceholderScreen(title: menu.name);
                return buildPageWithCustomTransition(
                  context: context,
                  state: state,
                  child: screen,
                );
              },
            );
          }),
          // BottomNav에 없는 화면들도 여기에 정의
          ...menus.where((m) => !m.showInBottomNav).map((menu) {
            return GoRoute(
              path: menu.path,
              pageBuilder: (context, state) {
                return buildPageWithCustomTransition(
                  context: context,
                  state: state,
                  child: PlaceholderScreen(title: menu.name),
                );
              },
            );
          })
        ],
      ),
    ],
  );
});
