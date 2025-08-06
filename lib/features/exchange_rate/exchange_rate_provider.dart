import 'dart:async';

import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateProvider =
    AsyncNotifierProvider<ExchangeRateNotifier, List<ExchangeRate>>(() {
  return ExchangeRateNotifier();
});

class ExchangeRateNotifier extends AsyncNotifier<List<ExchangeRate>> {
  late ExchangeRateRepository _repository;
  late ExchangeRateLocalService _localService;

  @override
  FutureOr<List<ExchangeRate>> build() async {
    _repository = ref.watch(exchangeRateRepositoryProvider);
    _localService = ref.watch(exchangeRateLocalServiceProvider);

    return _localService.getRates();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final rates = await _repository.getLatestRates('USD');
      await _expandAndSaveRates(rates);
      state = AsyncValue.data(await _localService.getRates());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _expandAndSaveRates(List<ExchangeRate> baseRates) async {
    final allRates = {...baseRates};

    for (int i = 0; i < baseRates.length; i++) {
      for (int j = 0; j < baseRates.length; j++) {
        if (i == j) continue;

        final rate1 = baseRates[i];
        final rate2 = baseRates[j];

        allRates.add(ExchangeRate(
          baseCode: rate1.quoteCode,
          quoteCode: rate2.quoteCode,
          rate: rate2.rate / rate1.rate,
          quantity: 1,
          lastUpdatedUnix: rate1.lastUpdatedUnix,
        ));
      }
    }

    final List<ExchangeRate> inverseRates = [];
    for (var rate in allRates) {
      inverseRates.add(ExchangeRate(
        baseCode: rate.quoteCode,
        quoteCode: rate.baseCode,
        rate: 1 / rate.rate,
        quantity: 1,
        lastUpdatedUnix: rate.lastUpdatedUnix,
      ));
    }
    allRates.addAll(inverseRates);

    await _localService.saveRates(allRates.toList());
  }
}

