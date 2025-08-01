
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// LocalStorageService를 제공하는 Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final box = Hive.box('settings');
  return LocalStorageService(box);
});

class LocalStorageService {
  final Box _box;

  LocalStorageService(this._box);

  // 값을 저장하는 메서드 (모든 타입 지원)
  Future<void> write<T>(String key, T value) async {
    await _box.put(key, value);
  }

  // 값을 읽는 메서드 (모든 타입 지원)
  T? read<T>(String key, {T? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as T?;
  }
  
  // 저장된 모든 데이터를 Map 형태로 반환
  Map<dynamic, dynamic> getAll() {
    return _box.toMap();
  }
}
