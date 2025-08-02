import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateLocalServiceProvider =
    Provider<ExchangeRateLocalService>((ref) {
  return ExchangeRateLocalService();
});

class ExchangeRateLocalService {
  static const String _boxName = 'exchangeRates';

  Future<Box<ExchangeRate>> _openBox() async {
    return await Hive.openBox<ExchangeRate>(_boxName);
  }

  Future<void> saveRate(ExchangeRate rate) async {
    final box = await _openBox();
    // 데이터를 하나만 저장할 것이므로, 고정된 키를 사용한다.
    await box.put('latest', rate);
  }

  Future<ExchangeRate?> getRate() async {
    final box = await _openBox();
    return box.get('latest');
  }
}
