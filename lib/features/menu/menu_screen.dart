
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/menu/menu_repository.dart';
import 'package:finow/features/settings/admin_mode_provider.dart';

// 전체 메뉴 목록을 보여주는 화면
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMenus = ref.watch(menuRepositoryProvider).getMenus();
    final isAdminMode = ref.watch(adminModeProvider);

    // Ground Rule: '전체 메뉴' 화면에서는 모든 메뉴로의 접근을 항상 제공해야 한다.
    // 어드민 모드가 비활성화 상태일 때도, 어드민 메뉴 자체는 리스트에 표시한다.
    // 단, 비활성화 상태에서 해당 메뉴를 탭했을 때의 동작은 각 화면의 진입점에서 제어할 수 있다.
    final visibleMenus = allMenus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 메뉴'),
      ),
      body: ListView.builder(
        itemCount: visibleMenus.length,
        itemBuilder: (context, index) {
          final menu = visibleMenus[index];
          
          // 어드민 메뉴이고, 어드민 모드가 비활성화 상태이면 비활성화된 것처럼 표시
          final bool isAdminMenu = menu.isAdmin;
          final bool isEnabled = !isAdminMenu || isAdminMode;

          return ListTile(
            leading: Icon(menu.icon, color: isEnabled ? null : Colors.grey),
            title: Text(menu.name, style: TextStyle(color: isEnabled ? null : Colors.grey)),
            onTap: isEnabled
                ? () {
                    if (menu.showInBottomNav) {
                      // Bottom Navigation에 노출되는 메뉴는 go()를 사용하여 뒤로가기 버튼 없음
                      context.go(menu.path);
                    } else {
                      // 그 외 메뉴는 push()를 사용하여 뒤로가기 버튼 표시
                      context.push(menu.path);
                    }
                  }
                : null,
            subtitle: isAdminMenu ? const Text('어드민 전용') : null,
          );
        },
      ),
    );
  }
}
