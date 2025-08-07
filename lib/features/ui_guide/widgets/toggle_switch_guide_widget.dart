// 이 위젯은 토글 스위치 UI의 구현 예시를 제공하여, 프로젝트 내 토글/스위치 컴포넌트의 기준점 역할을 합니다.
// 실제 서비스 적용 전, 토글 UI의 스타일과 동작 일관성을 확인하는 용도로 사용하세요.
import 'package:flutter/material.dart';

class ToggleSwitchGuideWidget extends StatefulWidget {
  const ToggleSwitchGuideWidget({super.key});

  @override
  State<ToggleSwitchGuideWidget> createState() => _ToggleSwitchGuideWidgetState();
}

class _ToggleSwitchGuideWidgetState extends State<ToggleSwitchGuideWidget> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Toggle Switch'),
      value: _isSwitched,
      onChanged: (value) {
        setState(() {
          _isSwitched = value;
        });
      },
    );
  }
}
