
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/storage_viewer/local_storage_service.dart';

const _adminModeKey = 'isAdminMode';

// 어드민 모드 상태를 관리하는 Provider
final adminModeProvider = StateNotifierProvider<AdminModeNotifier, bool>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  // Hive에서 저장된 값을 읽어와 초기 상태를 설정합니다. 기본값은 false입니다.
  final bool initialValue = localStorage.read<bool>(_adminModeKey) ?? false;
  return AdminModeNotifier(initialValue, localStorage);
});

class AdminModeNotifier extends StateNotifier<bool> {
  final LocalStorageService _localStorage;

  AdminModeNotifier(bool state, this._localStorage) : super(state);

  // 어드민 모드 상태를 변경하고 Hive에 저장합니다.
  void setAdminMode(bool isAdmin) {
    _localStorage.write(_adminModeKey, isAdmin);
    state = isAdmin;
  }
}
