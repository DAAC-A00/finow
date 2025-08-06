import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateUpdateServiceProvider = Provider<ExchangeRateUpdateService>((ref) {
  return ExchangeRateUpdateService(
    ref.watch(exchangeRateRepositoryProvider),
    ref.watch(exchangeRateLocalServiceProvider),
  );
});

class ExchangeRateUpdateService {
  final ExchangeRateRepository _repository;
  final ExchangeRateLocalService _localService;

  ExchangeRateUpdateService(this._repository, this._localService);

  Future<void> updateRatesIfNeeded() async {
    final cachedRates = await _localService.getRates();

    if (cachedRates.isNotEmpty) {
      final lastUpdated = DateTime.fromMillisecondsSinceEpoch(
          cachedRates.first.lastUpdatedUnix * 1000);
      final now = DateTime.now();

      if (lastUpdated.year == now.year &&
          lastUpdated.month == now.month &&
          lastUpdated.day == now.day) {
        return;
      }
    }

    try {
      final rates = await _repository.getLatestRates('USD');
      await _expandAndSaveRates(rates);
    } catch (e) {
      print('Failed to update exchange rates in background: $e');
    }
  }

  Future<void> _expandAndSaveRates(List<ExchangeRate> baseRates) async {
    final allRates = {...baseRates};

    // USD 기반 환율로 다른 모든 통화 쌍 계산
    for (int i = 0; i < baseRates.length; i++) {
      for (int j = 0; j < baseRates.length; j++) {
        if (i == j) continue;

        final rate1 = baseRates[i]; // USD -> Currency1
        final rate2 = baseRates[j]; // USD -> Currency2

        // Currency1 -> Currency2 계산
        allRates.add(ExchangeRate(
          baseCode: rate1.quoteCode,
          quoteCode: rate2.quoteCode,
          rate: rate2.rate / rate1.rate,
          lastUpdatedUnix: rate1.lastUpdatedUnix,
        ));
      }
    }

    // 역방향 환율 (KRW/USD -> USD/KRW) 추가
    final List<ExchangeRate> inverseRates = [];
    for (var rate in allRates) {
      inverseRates.add(ExchangeRate(
        baseCode: rate.quoteCode,
        quoteCode: rate.baseCode,
        rate: 1 / rate.rate,
        lastUpdatedUnix: rate.lastUpdatedUnix,
      ));
    }
    allRates.addAll(inverseRates);

    await _localService.saveRates(allRates.toList());
  }
}

