import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_detail_screen.dart';
import 'package:finow/features/exchange_rate/exchange_rate_screen.dart';
import 'package:finow/features/menu/menu_screen.dart';
import 'package:finow/features/settings/settings_screen.dart';
import 'package:finow/features/storage_viewer/storage_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_model.dart';
import 'package:finow/features/menu/menu_repository.dart';
import 'package:finow/routing/app_transitions.dart';
import 'package:finow/screens/main_screen.dart';
import 'package:finow/screens/placeholder_screen.dart';
import 'package:finow/features/ui_guide/ui_guide_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final menuRepository = ref.watch(menuRepositoryProvider);
  final menus = menuRepository.getMenus();

  final List<RouteBase> shellRoutes = menus
      .where((menu) => menu.showInBottomNav)
      .map((menu) => _buildRoute(menu, isTopLevel: false))
      .toList();

  final List<RouteBase> topLevelRoutes = menus
      .where((menu) => !menu.showInBottomNav)
      .map((menu) => _buildRoute(menu, isTopLevel: true))
      .toList();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shell'),
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: MainScreen(child: child),
          );
        },
        routes: [
          ...shellRoutes,
        ],
      ),
      GoRoute(
        path: '/exchange/:quoteCode',
        pageBuilder: (context, state) {
          final exchangeRate = state.extra as ExchangeRate;
          return NoTransitionPage(
            child: ExchangeRateDetailScreen(exchangeRate: exchangeRate),
          );
        },
      ),
      ...topLevelRoutes,
    ],
  );
});

GoRoute _buildRoute(Menu menu, {required bool isTopLevel}) {
  return GoRoute(
    path: menu.path,
    pageBuilder: (context, state) {
      Widget screen;
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
        case '/ui_guide':
          screen = const UiGuideScreen();
          break;
        default:
          screen = PlaceholderScreen(title: menu.name, showBackButton: isTopLevel);
      }

      return buildPageWithCustomTransition(
        context: context,
        state: state,
        child: screen,
      );
    },
  );
}
