
import 'package:finow/features/settings/admin_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_repository.dart';

// 전체 메뉴 목록을 보여주는 화면
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMenus = ref.watch(menuRepositoryProvider).getMenus();
    final isAdminMode = ref.watch(adminModeProvider);

    // 어드민 모드가 아닐 경우, 어드민 전용 메뉴를 필터링하여 제외합니다.
    final visibleMenus = allMenus.where((menu) => !menu.isAdmin || isAdminMode).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 메뉴'),
      ),
      body: ListView.builder(
        itemCount: visibleMenus.length,
        itemBuilder: (context, index) {
          final menu = visibleMenus[index];
          return ListTile(
            leading: Icon(menu.icon),
            title: Text(menu.name),
            onTap: () => context.go(menu.path),
          );
        },
      ),
    );
  }
}
