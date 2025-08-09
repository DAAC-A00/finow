// 이 위젯은 다양한 제스처(스와이프, 드래그, 롱프레스 등) 구현 예시를 제공하여, 프로젝트 내 제스처 UX의 기준점 역할을 합니다.
// 실제 서비스 적용 전, 제스처 동작의 방향성과 일관성을 확인하는 용도로 사용하세요.
import 'package:finow/ui_scale_provider.dart';
import 'package:flutter/material.dart';

class GestureGuideWidget extends StatefulWidget {
  const GestureGuideWidget({super.key});

  @override
  State<GestureGuideWidget> createState() => _GestureGuideWidgetState();
}

class _GestureGuideWidgetState extends State<GestureGuideWidget> {
  List<String> items = List.generate(5, (index) => 'Item ${index + 1}');
  Color? _dragColor;
  String _lastEvent = 'None';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dragColor ??=
        Theme.of(context).colorScheme.surfaceContainerHighest; // surfaceVariant -> surfaceContainerHighest
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        ScaledText(
          'Dismissible (Swipe to delete)',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              color: colorScheme.surface,
              child: Dismissible(
                key: Key(item),
                onDismissed: (direction) {
                  setState(() {
                    items.remove(item);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: ScaledText(
                        '$item dismissed',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
                      ),
                      backgroundColor: colorScheme.inverseSurface,
                    ),
                  );
                },
                background: Container(
                  color: colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: ScaledIcon(
                    Icons.delete,
                    color: colorScheme.onError,
                  ),
                ),
                child: ListTile(
                  title: ScaledText(
                    item,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                  ),
                  leading: ScaledIcon(
                    Icons.drag_handle,
                    color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                  ),
                ),
              ),
            )),
        const SizedBox(height: 20),
        ScaledText(
          'Draggable & DragTarget',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Draggable<Color>(
              data: colorScheme.primary,
              feedback: CircleAvatar(
                backgroundColor: colorScheme.primary,
                radius: 25,
                child: ScaledIcon(
                  Icons.touch_app,
                  color: colorScheme.onPrimary,
                ),
              ),
              childWhenDragging: CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest,
                radius: 25,
                child: ScaledIcon(
                  Icons.touch_app,
                  color: colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round()),
                ),
              ),
              child: CircleAvatar(
                backgroundColor: colorScheme.primary,
                radius: 25,
                child: ScaledIcon(
                  Icons.touch_app,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            DragTarget<Color>(
              onAcceptWithDetails: (details) {
                setState(() {
                  _dragColor = details.data;
                });
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _dragColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isHovering
                          ? colorScheme.primary
                          : colorScheme.outline.withAlpha((255 * 0.3).round()),
                      width: isHovering ? 3 : 1,
                    ),
                  ),
                  child: ScaledIcon(
                    Icons.track_changes,
                    color: colorScheme.onSurface,
                    size: 40,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        ScaledText(
          'Long Press & Double Tap',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onLongPress: () => setState(() => _lastEvent = 'Long Press'),
          onDoubleTap: () => setState(() => _lastEvent = 'Double Tap'),
          child: Container(
            width: 150,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withAlpha((255 * 0.3).round()),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaledIcon(
                    Icons.touch_app,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 4),
                  ScaledText(
                    _lastEvent,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
