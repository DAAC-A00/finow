import 'package:flutter/material.dart';

class GestureTestWidget extends StatefulWidget {
  const GestureTestWidget({super.key});

  @override
  State<GestureTestWidget> createState() => _GestureTestWidgetState();
}

class _GestureTestWidgetState extends State<GestureTestWidget> {
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
