import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateLocalServiceProvider =
    Provider<ExchangeRateLocalService>((ref) {
  // 이미 main.dart에서 열어둔 Box 인스턴스를 가져온다.
  return ExchangeRateLocalService(Hive.box<ExchangeRate>('exchangeRates'));
});

class ExchangeRateLocalService {
  final Box<ExchangeRate> _box;

  ExchangeRateLocalService(this._box);

  Future<void> saveRate(ExchangeRate rate) async {
    // 데이터를 하나만 저장할 것이므로, 고정된 키를 사용한다.
    await _box.put('latest', rate);
  }

  Future<ExchangeRate?> getRate() async {
    return _box.get('latest');
  }
}
