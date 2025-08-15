import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/font_size_provider.dart';

/// UI 스케일 정보를 제공하는 InheritedWidget
class UIScaleProvider extends InheritedWidget {
  const UIScaleProvider({
    super.key,
    required this.scale,
    required super.child,
  });

  final double scale;

  static UIScaleProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UIScaleProvider>();
  }

  static UIScaleProvider of(BuildContext context) {
    final UIScaleProvider? result = maybeOf(context);
    assert(result != null, 'No UIScaleProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(UIScaleProvider oldWidget) {
    return scale != oldWidget.scale;
  }
}

/// UIScaleProvider를 Riverpod과 연결하는 Consumer 위젯
class UIScaleConsumer extends ConsumerWidget {
  const UIScaleConsumer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeOption = ref.watch(fontSizeNotifierProvider);
    
    return UIScaleProvider(
      scale: fontSizeOption.scale,
      child: child,
    );
  }
}

/// 스케일된 이미지 위젯
class ScaledImage extends StatelessWidget {
  const ScaledImage({
    super.key,
    required this.image,
    this.baseWidth = 40.0,
    this.baseHeight = 40.0,
    this.fit = BoxFit.contain,
  });

  final ImageProvider image;
  final double baseWidth;
  final double baseHeight;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scale = UIScaleProvider.of(context).scale;
    
    return SizedBox(
      width: baseWidth * scale,
      height: baseHeight * scale,
      child: Image(
        image: image,
        fit: fit,
      ),
    );
  }
}

/// Asset 이미지를 위한 스케일된 위젯
class ScaledAssetImage extends StatelessWidget {
  const ScaledAssetImage({
    super.key,
    required this.assetPath,
    this.baseWidth = 40.0,
    this.baseHeight = 40.0,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double baseWidth;
  final double baseHeight;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scale = UIScaleProvider.of(context).scale;
    
    return SizedBox(
      width: baseWidth * scale,
      height: baseHeight * scale,
      child: Image.asset(
        assetPath,
        fit: fit,
      ),
    );
  }
}