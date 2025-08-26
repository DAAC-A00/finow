import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_detail_screen.dart';
import 'package:finow/features/exchange_rate/exchange_rate_screen.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/instruments/screens/instrument_details_screen.dart';
import 'package:finow/features/instruments/screens/instruments_screen.dart';
import 'package:finow/features/ticker/models/ticker_price_data.dart';
import 'package:finow/features/ticker/screens/ticker_screen.dart';
import 'package:finow/features/ticker/screens/ticker_details_screen.dart';

import 'package:finow/features/menu/menu_screen.dart';
import 'package:finow/features/settings/api_settings_screen.dart';
import 'package:finow/features/settings/settings_screen.dart';
import 'package:finow/features/settings/api_status_screen.dart';
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
      // New route for InstrumentDetailsScreen
      GoRoute(
        path: '/instruments/details',
        pageBuilder: (context, state) {
          final instrument = state.extra as Instrument;
          return NoTransitionPage(
            child: InstrumentDetailsScreen(instrument: instrument),
          );
        },
      ),
      // New route for TickerDetailsScreen
      GoRoute(
        path: '/ticker/details',
        builder: (context, state) => TickerDetailsScreen(
          ticker: state.extra as IntegratedTickerPriceData,
        ),
      ),
      ...topLevelRoutes,
      GoRoute(
        path: '/api-status',
        builder: (context, state) => const ApiStatusScreen(),
      ),
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
        case '/instruments':
          screen = const InstrumentsScreen();
          break;
        case '/ticker':
          screen = const TickerScreen();
          break;
        case '/settings':
          screen = const SettingsScreen();
          break;
        case '/api-settings':
          screen = const ApiSettingsScreen();
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