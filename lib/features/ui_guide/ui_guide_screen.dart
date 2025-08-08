import 'package:flutter/material.dart';

import 'widgets/animation_guide_widget.dart';
import 'widgets/gesture_guide_widget.dart';
import 'widgets/show_guide_widget.dart';
import 'widgets/toggle_switch_guide_widget.dart';
import 'widgets/providers_guide_widget.dart';
import 'widgets/scaling_guide_widget.dart';
import 'widgets/architecture_guide_widget.dart';
import 'widgets/principles_guide_widget.dart';

class UiGuideScreen extends StatelessWidget {
  const UiGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8, // 탭 개수 8개로 확장
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UI Guide & Code Examples'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Show'),
              Tab(text: 'Gestures'),
              Tab(text: 'Animations'),
              Tab(text: 'Toggles'),
              Tab(text: 'Providers'),
              Tab(text: 'Scaling'),
              Tab(text: 'Architecture'),
              Tab(text: 'Principles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(const ShowGuideWidget()),
            _buildTabContent(const GestureGuideWidget()),
            _buildTabContent(const AnimationGuideWidget()),
            _buildTabContent(const ToggleSwitchGuideWidget()),
            _buildTabContent(const ProvidersGuideWidget()),
            _buildTabContent(const ScalingGuideWidget()),
            _buildTabContent(const ArchitectureGuideWidget()),
            _buildTabContent(const PrinciplesGuideWidget()),
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
