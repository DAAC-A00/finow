
import 'package:flutter/material.dart';

// 각 메뉴를 선택했을 때 보여줄 임시 화면
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
