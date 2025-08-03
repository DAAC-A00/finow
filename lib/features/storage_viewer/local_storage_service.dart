
import 'package:finow/features/exchange_rate/exchange_rate.dart'; // ExchangeRate 모델 임포트
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// LocalStorageService를 제공하는 Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  // 'settings' Box를 주입하여 서비스 생성
  return LocalStorageService(Hive.box('settings'));
});

class LocalStorageService {
  final Box _settingsBox;

  LocalStorageService(this._settingsBox);

  // 'settings' Box에 값을 저장하는 메서드 (복원)
  Future<void> write<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  // 'settings' Box에서 값을 읽는 메서드 (복원)
  T? read<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // 모든 Box의 데이터를 Map 형태로 반환 (유지)
  Future<Map<String, Map<dynamic, dynamic>>> getAllBoxes() async {
    final allData = <String, Map<dynamic, dynamic>>{};
    final boxNames = ['settings', 'exchangeRates'];

    for (var name in boxNames) {
      if (Hive.isBoxOpen(name)) {
        Box box;
        // 타입이 지정된 Box는 해당 타입으로 접근해야 함
        if (name == 'exchangeRates') {
          box = Hive.box<ExchangeRate>(name);
        } else {
          box = Hive.box(name);
        }
        allData[name] = box.toMap();
      }
    }
    return allData;
  }
}
