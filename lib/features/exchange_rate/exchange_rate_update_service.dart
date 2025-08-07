import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:finow/features/exchange_rate/exconvert_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateUpdateServiceProvider =
    Provider<ExchangeRateUpdateService>((ref) {
  return ExchangeRateUpdateService(
    ref.watch(exConvertApiClientProvider),
    ref.watch(exchangeRateRepositoryProvider),
    ref.watch(exchangeRateLocalServiceProvider),
  );
});

class ExchangeRateUpdateService {
  final ExConvertApiClient _exConvertApiClient;
  final ExchangeRateRepository _repository;
  final ExchangeRateLocalService _localService;

  ExchangeRateUpdateService(
      this._exConvertApiClient, this._repository, this._localService);

  Future<void> updateRatesIfNeeded() async {
    final cachedRates = await _localService.getRates();

    if (cachedRates.isNotEmpty) {
      final lastUpdated = DateTime.fromMillisecondsSinceEpoch(
          cachedRates.first.lastUpdatedUnix * 1000);
      final now = DateTime.now();

      // 데이터가 오늘 업데이트되었는지 확인
      final bool isToday = lastUpdated.year == now.year &&
          lastUpdated.month == now.month &&
          lastUpdated.day == now.day;

      // 두 소스의 데이터가 모두 있는지 확인
      final sources = cachedRates.map((rate) => rate.source).toSet();
      final bool hasBothSources = sources.contains('exconvert.com') &&
          sources.contains('v6.exchangerate-api.com');

      if (isToday && hasBothSources) {
        return; // 오늘 데이터가 있고, 두 소스 모두 존재하면 업데이트 안 함
      }
    }

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
    } catch (e) {
      print('Failed to update exchange rates in background: $e');
    }
  }
}