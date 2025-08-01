
import 'package:flutter/material.dart';

// 각 메뉴를 선택했을 때 보여줄 임시 화면
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // showBackButton 값에 따라 뒤로가기 버튼 자동 표시 여부 결정
        // ShellRoute 내부 화면에서는 false, 최상위 화면에서는 true가 됨
        automaticallyImplyLeading: showBackButton,
      ),
      body: Center(
        child: Text(
          '$title 화면',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
