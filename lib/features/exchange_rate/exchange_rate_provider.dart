import 'dart:async';

import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:finow/features/exchange_rate/exconvert_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateProvider =
    AsyncNotifierProvider<ExchangeRateNotifier, List<ExchangeRate>>(() {
  return ExchangeRateNotifier();
});

class ExchangeRateNotifier extends AsyncNotifier<List<ExchangeRate>> {
  late ExConvertApiClient _exConvertApiClient;
  late ExchangeRateRepository _repository;
  late ExchangeRateLocalService _localService;

  @override
  FutureOr<List<ExchangeRate>> build() async {
    _exConvertApiClient = ref.watch(exConvertApiClientProvider);
    _repository = ref.watch(exchangeRateRepositoryProvider);
    _localService = ref.watch(exchangeRateLocalServiceProvider);

    return _localService.getRates();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      // 1. exconvert.com에서 데이터 가져오기
      final exConvertRates = await _exConvertApiClient.getLatestRates('USD');
      final exConvertRateMap = {
        for (var rate in exConvertRates) '${rate.baseCode}/${rate.quoteCode}': rate
      };

      // 2. v6.exchangerate-api.com에서 데이터 가져오기
      final v6Rates = await _repository.getLatestRates('USD');

      // 3. v6 데이터에서 exconvert에 없는 정보만 필터링
      final combinedRates = List<ExchangeRate>.from(exConvertRates);
      for (var v6Rate in v6Rates) {
        final key = '${v6Rate.baseCode}/${v6Rate.quoteCode}';
        if (!exConvertRateMap.containsKey(key)) {
          combinedRates.add(v6Rate);
        }
      }

      await _localService.saveRates(combinedRates);
      state = AsyncValue.data(await _localService.getRates());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

