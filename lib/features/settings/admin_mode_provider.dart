
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 어드민 모드 활성화 상태를 관리하는 Provider
// StateProvider는 외부에서 값을 수정할 수 있는 간단한 상태를 관리할 때 유용합니다.
final adminModeProvider = StateProvider<bool>((ref) => false); // 기본값은 비활성화
