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

/// 스케일된 텍스트 위젯 - MediaQuery textScaler를 사용하므로 일반 Text와 동일하게 처리
/// 호환성을 위해 유지하지만, 내부적으로는 일반 Text 위젯을 사용
class ScaledText extends StatelessWidget {
  const ScaledText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) {
    // MediaQuery textScaler를 사용하므로 일반 Text 위젯과 동일하게 동작
    return Text(
      data,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// 스케일된 아이콘 위젯
class ScaledIcon extends StatelessWidget {
  const ScaledIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final scale = UIScaleProvider.of(context).scale;
    final scaledSize = (size ?? 24.0) * scale;

    return Icon(
      icon,
      size: scaledSize,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
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