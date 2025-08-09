import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/theme_provider.dart';

import 'widgets/animation_guide_widget.dart';
import 'widgets/gesture_guide_widget.dart';
import 'widgets/show_guide_widget.dart';
import 'widgets/providers_guide_widget.dart';
import 'widgets/scaling_guide_widget.dart';
import 'widgets/architecture_guide_widget.dart';
import 'widgets/principles_guide_widget.dart';
import 'widgets/theme_guide_widget.dart';

class UiGuideScreen extends ConsumerWidget {
  const UiGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return DefaultTabController(
      length: 8, // 탭 개수 8개로 변경 (Toggles 탭 제거)
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UI & Code Guide'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          actions: [
            // 테마 토글 버튼
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                final newThemeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(newThemeMode);
              },
              tooltip: isDarkMode ? '라이트 모드로 전환' : '다크 모드로 전환',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha(153), // withOpacity(0.6)
            tabs: const [
              Tab(text: 'Show'),
              Tab(text: 'Gestures'),
              Tab(text: 'Animations'),
              Tab(text: 'Providers'),
              Tab(text: 'Scaling'),
              Tab(text: 'Architecture'),
              Tab(text: 'Principles'),
              Tab(text: 'Theme'),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface, // background -> surface
        body: TabBarView(
          children: [
            _buildTabContent(const ShowGuideWidget()),
            _buildTabContent(const GestureGuideWidget()),
            _buildTabContent(const AnimationGuideWidget()),
            _buildTabContent(const ProvidersGuideWidget()),
            _buildTabContent(const ScalingGuideWidget()),
            _buildTabContent(const ArchitectureGuideWidget()),
            _buildTabContent(const PrinciplesGuideWidget()),
            _buildTabContent(const ThemeGuideWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: child),
    );
  }
}