
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 네비게이션 상태에 따라 동적으로 슬라이드 애니메이션을 적용하는 CustomTransitionPage 빌더
Page<T> buildPageWithCustomTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<T>(
    key: state.pageKey,
    child: child,
  );
}
