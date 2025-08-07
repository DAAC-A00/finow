// 이 위젯은 다양한 제스처(스와이프, 드래그, 롱프레스 등) 구현 예시를 제공하여, 프로젝트 내 제스처 UX의 기준점 역할을 합니다.
// 실제 서비스 적용 전, 제스처 동작의 방향성과 일관성을 확인하는 용도로 사용하세요.
import 'package:flutter/material.dart';

class GestureGuideWidget extends StatefulWidget {
  const GestureGuideWidget({super.key});

  @override
  State<GestureGuideWidget> createState() => _GestureGuideWidgetState();
}

class _GestureGuideWidgetState extends State<GestureGuideWidget> {
  List<String> items = List.generate(5, (index) => 'Item ${index + 1}');
  Color _dragColor = Colors.grey;
  String _lastEvent = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Dismissible (Swipe to delete)'),
        ...items.map((item) => Dismissible(
          key: Key(item),
          onDismissed: (direction) {
            setState(() {
              items.remove(item);
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$item dismissed')));
          },
          background: Container(color: Colors.red),
          child: ListTile(title: Text(item)),
        )),
        const SizedBox(height: 20),
        const Text('Draggable & DragTarget'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Draggable<Color>(
              data: Colors.blue,
              feedback: CircleAvatar(backgroundColor: Colors.blue, radius: 25),
              childWhenDragging: CircleAvatar(backgroundColor: Colors.grey, radius: 25),
              child: CircleAvatar(backgroundColor: Colors.blue, radius: 25),
            ),
            DragTarget<Color>(
              onAccept: (color) {
                setState(() {
                  _dragColor = color;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return CircleAvatar(backgroundColor: _dragColor, radius: 50);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Long Press & Double Tap'),
        GestureDetector(
          onLongPress: () => setState(() => _lastEvent = 'Long Press'),
          onDoubleTap: () => setState(() => _lastEvent = 'Double Tap'),
          child: Container(
            width: 100,
            height: 50,
            color: Colors.amber,
            child: Center(child: Text(_lastEvent)),
          ),
        ),
      ],
    );
  }
}
