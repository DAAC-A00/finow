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
    return _fetchAndCacheRates();
  }

  Future<List<ExchangeRate>> _fetchAndCacheRates() async {
    try {
      final rates = await _repository.getLatestRates('USD');
      await _localService.saveRates(rates);
      return rates;
    } catch (e) {
      final cachedRates = await _localService.getRates();
      if (cachedRates.isNotEmpty) {
        return cachedRates;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAndCacheRates());
  }
}
