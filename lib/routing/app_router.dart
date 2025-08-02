
import 'package:finow/features/exchange_rate/exchange_rate_screen.dart';
import 'package:finow/features/settings/settings_screen.dart';
import 'package:finow/features/storage_viewer/storage_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_model.dart';
import 'package:finow/features/menu/menu_repository.dart';
import 'package:finow/features/menu/menu_screen.dart';
import 'package:finow/routing/app_transitions.dart';
import 'package:finow/screens/main_screen.dart';
import 'package:finow/screens/placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final menuRepository = ref.watch(menuRepositoryProvider);
  final menus = menuRepository.getMenus();

  // BottomNav가 보이는 화면 (ShellRoute 내부용)
  final List<RouteBase> shellRoutes = menus
      .where((menu) => menu.showInBottomNav)
      .map((menu) => _buildRoute(menu, isTopLevel: false))
      .toList();

  // BottomNav를 가리는 독립적인 화면 (최상위용)
  final List<RouteBase> topLevelRoutes = menus
      .where((menu) => !menu.showInBottomNav)
      .map((menu) => _buildRoute(menu, isTopLevel: true))
      .toList();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // BottomNavigationBar를 포함하는 ShellRoute
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shell'),
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: MainScreen(child: child),
          );
        },
        routes: shellRoutes,
      ),
      // ShellRoute 밖에 최상위 라우트를 정의하여 BottomNav를 가리도록 함
      ...topLevelRoutes,
    ],
  );
});

// 라우트 생성을 위한 헬퍼 함수
GoRoute _buildRoute(Menu menu, {required bool isTopLevel}) {
  return GoRoute(
    path: menu.path,
    pageBuilder: (context, state) {
      Widget screen;
      // 메뉴 경로에 따라 적절한 화면을 매핑
      switch (menu.path) {
        case '/menu':
          screen = const MenuScreen();
          break;
        case '/exchange':
          screen = const ExchangeRateScreen();
          break;
        case '/settings':
          screen = const SettingsScreen();
          break;
        case '/storage':
          screen = const StorageViewerScreen();
          break;
        default:
          screen = PlaceholderScreen(title: menu.name, showBackButton: isTopLevel);
      }

      // isTopLevel이 true일 경우 MaterialPage를 사용하여 fullScreenDialog 효과 적용
      if (isTopLevel) {
        return MaterialPage(
          key: state.pageKey,
          child: screen,
          fullscreenDialog: true,
        );
      } else {
        return buildPageWithCustomTransition(
          context: context,
          state: state,
          child: screen,
        );
      }
    },
  );
}

