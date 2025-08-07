import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateLocalServiceProvider =
    Provider<ExchangeRateLocalService>((ref) {
  return ExchangeRateLocalService(Hive.box<ExchangeRate>('exchangeRates'));
});

class ExchangeRateLocalService {
  final Box<ExchangeRate> _box;

  ExchangeRateLocalService(this._box);

  Future<void> saveRates(List<ExchangeRate> rates) async {
    await _box.clear(); // 기존 데이터를 지우고 새로운 데이터로 대체
    for (var rate in rates) {
      await _box.put('${rate.baseCode}/${rate.quoteCode}', rate);
    }
  }

  /// 기존 데이터를 유지하면서 새로운 환율 정보를 추가/업데이트
  Future<void> updateRates(List<ExchangeRate> rates) async {
    for (var rate in rates) {
      await _box.put('${rate.baseCode}/${rate.quoteCode}', rate);
    }
  }

  Future<List<ExchangeRate>> getRates() async {
    return _box.values.toList();
  }
}
