import 'package:flutter/material.dart';

import 'widgets/animation_test_widget.dart';
import 'widgets/gesture_test_widget.dart';
import 'widgets/show_test_widget.dart';
import 'widgets/toggle_switch_test_widget.dart';

class LaboratoryScreen extends StatelessWidget {
  const LaboratoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 탭 개수 수정
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laboratory'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Show'), // 'Legacy'와 'Dialogs'를 합친 탭
              Tab(text: 'Gestures'),
              Tab(text: 'Animations'),
              Tab(text: 'Toggles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(const ShowTestWidget()), // 새로운 위젯 연결
            _buildTabContent(const GestureTestWidget()),
            _buildTabContent(const AnimationTestWidget()),
            _buildTabContent(const ToggleSwitchTestWidget()),
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
