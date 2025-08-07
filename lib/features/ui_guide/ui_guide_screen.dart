import 'package:flutter/material.dart';

import 'widgets/animation_guide_widget.dart';
import 'widgets/gesture_guide_widget.dart';
import 'widgets/show_guide_widget.dart';
import 'widgets/toggle_switch_guide_widget.dart';

class UiGuideScreen extends StatelessWidget {
  const UiGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 탭 개수 수정
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UI Guide'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Show'),
              Tab(text: 'Gestures'),
              Tab(text: 'Animations'),
              Tab(text: 'Toggles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(const ShowGuideWidget()),
            _buildTabContent(const GestureGuideWidget()),
            _buildTabContent(const AnimationGuideWidget()),
            _buildTabContent(const ToggleSwitchGuideWidget()),
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
