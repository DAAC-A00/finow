
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 네비게이션 상태에 따라 동적으로 슬라이드 애니메이션을 적용하는 CustomTransitionPage 빌더
CustomTransitionPage buildPageWithCustomTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final extra = state.extra as Map<String, dynamic>?;
  final fromIndex = extra?['fromIndex'] as int?;
  final toIndex = extra?['toIndex'] as int?;

  // 기본값: 오른쪽에서 슬라이드 (Push 애니메이션)
  Offset begin = const Offset(1.0, 0.0);

  // BottomNav 전환 시, 인덱스 비교를 통해 애니메이션 방향 결정
  if (fromIndex != null && toIndex != null && fromIndex != toIndex) {
    begin = Offset(toIndex > fromIndex ? 1.0 : -1.0, 0.0);
  }

  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Tween을 사용하여 슬라이드 애니메이션 정의
      final tween = Tween(begin: begin, end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));

      // SlideTransition 적용
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
