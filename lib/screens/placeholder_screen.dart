
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
        leading: showBackButton && Navigator.of(context).canPop() ? const BackButton() : null,
      ),
      body: Center(
        child: Text(
          '$title Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
