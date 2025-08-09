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

/// 스케일된 SizedBox 위젯
class ScaledSizedBox extends StatelessWidget {
  const ScaledSizedBox({
    super.key,
    this.baseWidth,
    this.baseHeight,
    this.child,
  });

  /// 정사각형 SizedBox 생성자
  const ScaledSizedBox.square({
    super.key,
    required double baseDimension,
    this.child,
  }) : baseWidth = baseDimension,
       baseHeight = baseDimension;

  final double? baseWidth;
  final double? baseHeight;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scale = UIScaleProvider.of(context).scale;
    
    return SizedBox(
      width: baseWidth != null ? baseWidth! * scale : null,
      height: baseHeight != null ? baseHeight! * scale : null,
      child: child,
    );
  }
}

/// 스케일된 Padding 위젯
class ScaledPadding extends StatelessWidget {
  const ScaledPadding({
    super.key,
    required this.basePadding,
    required this.child,
  });

  /// 모든 방향에 동일한 패딩 적용
  const ScaledPadding.all({
    super.key,
    required double baseValue,
    required this.child,
  }) : basePadding = EdgeInsets.all(baseValue);

  /// 대칭 패딩 적용
  const ScaledPadding.symmetric({
    super.key,
    double baseVertical = 0.0,
    double baseHorizontal = 0.0,
    required this.child,
  }) : basePadding = EdgeInsets.symmetric(
         vertical: baseVertical,
         horizontal: baseHorizontal,
       );

  /// 개별 방향 패딩 적용
  const ScaledPadding.only({
    super.key,
    double baseLeft = 0.0,
    double baseTop = 0.0,
    double baseRight = 0.0,
    double baseBottom = 0.0,
    required this.child,
  }) : basePadding = EdgeInsets.only(
         left: baseLeft,
         top: baseTop,
         right: baseRight,
         bottom: baseBottom,
       );

  final EdgeInsets basePadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scale = UIScaleProvider.of(context).scale;
    
    return Padding(
      padding: basePadding * scale,
      child: child,
    );
  }
}

/// 스케일된 Container 위젯
class ScaledContainer extends StatelessWidget {
  const ScaledContainer({
    super.key,
    this.alignment,
    this.basePadding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.baseWidth,
    this.baseHeight,
    this.constraints,
    this.baseMargin,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.none,
  });

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? basePadding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? baseWidth;
  final double? baseHeight;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? baseMargin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Widget? child;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final scale = UIScaleProvider.of(context).scale;
    
    return Container(
      alignment: alignment,
      padding: basePadding != null ? basePadding! * scale : null,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: baseWidth != null ? baseWidth! * scale : null,
      height: baseHeight != null ? baseHeight! * scale : null,
      constraints: constraints,
      margin: baseMargin != null ? baseMargin! * scale : null,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// 스케일된 BorderRadius 헬퍼
class ScaledBorderRadius {
  /// 모든 모서리에 동일한 반지름 적용
  static BorderRadius all(BuildContext context, double baseRadius) {
    final scale = UIScaleProvider.of(context).scale;
    return BorderRadius.circular(baseRadius * scale);
  }

  /// 원형 BorderRadius
  static BorderRadius circular(BuildContext context, double baseRadius) {
    final scale = UIScaleProvider.of(context).scale;
    return BorderRadius.circular(baseRadius * scale);
  }

  /// 개별 모서리 반지름 적용
  static BorderRadius only({
    required BuildContext context,
    double topLeft = 0.0,
    double topRight = 0.0,
    double bottomLeft = 0.0,
    double bottomRight = 0.0,
  }) {
    final scale = UIScaleProvider.of(context).scale;
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft * scale),
      topRight: Radius.circular(topRight * scale),
      bottomLeft: Radius.circular(bottomLeft * scale),
      bottomRight: Radius.circular(bottomRight * scale),
    );
  }
}

/// 스케일된 EdgeInsets 헬퍼
class ScaledEdgeInsets {
  /// 모든 방향에 동일한 값 적용
  static EdgeInsets all(BuildContext context, double baseValue) {
    final scale = UIScaleProvider.of(context).scale;
    return EdgeInsets.all(baseValue * scale);
  }

  /// 대칭 EdgeInsets
  static EdgeInsets symmetric({
    required BuildContext context,
    double vertical = 0.0,
    double horizontal = 0.0,
  }) {
    final scale = UIScaleProvider.of(context).scale;
    return EdgeInsets.symmetric(
      vertical: vertical * scale,
      horizontal: horizontal * scale,
    );
  }

  /// 개별 방향 EdgeInsets
  static EdgeInsets only({
    required BuildContext context,
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    final scale = UIScaleProvider.of(context).scale;
    return EdgeInsets.only(
      left: left * scale,
      top: top * scale,
      right: right * scale,
      bottom: bottom * scale,
    );
  }
}