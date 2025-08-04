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

    // 로컬 서비스에서 데이터를 가져와 UI에 즉시 표시
    return _localService.getRates();
  }

  // 새로고침 기능은 사용자가 수동으로 최신 데이터를 가져올 수 있도록 유지
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final rates = await _repository.getLatestRates('USD');
      await _localService.saveRates(rates);
      state = AsyncValue.data(rates);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
