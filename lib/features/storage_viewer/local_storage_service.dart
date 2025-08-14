import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class LocalStorageService {
  // 모든 Box의 데이터를 가져오는 메소드
  Future<Map<String, Map>> getAllBoxes() async {
    final settingsBox = Hive.box('settings');
    final exchangeRatesBox = Hive.box<ExchangeRate>('exchangeRates');
    final instrumentsBox = Hive.box<Instrument>('instruments');

    return {
      'settings': settingsBox.toMap(),
      'exchangeRates': exchangeRatesBox.toMap(),
      'instruments': instrumentsBox.toMap(),
    };
  }

  // 특정 Box의 특정 키에 해당하는 데이터를 삭제하는 메소드
  Future<void> deleteEntry(String boxName, dynamic key) async {
    dynamic box;
    if (boxName == 'exchangeRates') {
      box = Hive.box<ExchangeRate>(boxName);
    } else if (boxName == 'instruments') {
      box = Hive.box<Instrument>(boxName);
    } else {
      box = Hive.box(boxName);
    }
    await box.delete(key);
  }

  // 특정 Box의 특정 키에 해당하는 데이터를 수정하는 메소드
  Future<void> updateEntry(String boxName, dynamic key, dynamic value) async {
    dynamic box;
    if (boxName == 'exchangeRates') {
      box = Hive.box<ExchangeRate>(boxName);
    } else if (boxName == 'instruments') {
      box = Hive.box<Instrument>(boxName);
    } else {
      box = Hive.box(boxName);
    }
    await box.put(key, value);
  }

  // 특정 Box의 모든 데이터를 삭제하는 메소드
  Future<void> clearBox(String boxName) async {
    dynamic box;
    if (boxName == 'exchangeRates') {
      box = Hive.box<ExchangeRate>(boxName);
    } else if (boxName == 'instruments') {
      box = Hive.box<Instrument>(boxName);
    } else {
      box = Hive.box(boxName);
    }
    await box.clear();
  }

  // 총 스토리지 사용량을 계산하는 메소드
  Future<int> getTotalStorageUsage() async {
    final settingsBox = Hive.box('settings');
    final exchangeRatesBox = Hive.box<ExchangeRate>('exchangeRates');
    final instrumentsBox = Hive.box<Instrument>('instruments');

    // 각 Box의 사용량을 바이트 단위로 추정 (실제와 다를 수 있음)
    int totalSize = 0;
    settingsBox.toMap().forEach((key, value) {
      totalSize += key.toString().length + value.toString().length;
    });
    exchangeRatesBox.toMap().forEach((key, value) {
      totalSize += key.toString().length + value.toJson().toString().length;
    });
    instrumentsBox.toMap().forEach((key, value) {
      totalSize += key.toString().length + value.toJson().toString().length;
    });

    return totalSize;
  }

  // Helper methods for direct read/write (for providers)
  T? read<T>(String key) => Hive.box('settings').get(key) as T?;
  void write<T>(String key, T value) => Hive.box('settings').put(key, value);
}