import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 v6.exchangerate-api.com의 데이터를 사용하여
/// 로컬 환율 정보를 보충하는 일회성 서비스를 제공하는 Provider
final exchangeRateUpdateServiceProvider =
    Provider<ExchangeRateUpdateService>((ref) {
  return ExchangeRateUpdateService(
    ref.watch(exchangeRateRepositoryProvider),
    ref.watch(exchangeRateLocalServiceProvider),
  );
});

class ExchangeRateUpdateService {
  final ExchangeRateRepository _repository;
  final ExchangeRateLocalService _localService;

  ExchangeRateUpdateService(this._repository, this._localService);

  /// v6 API를 통해 로컬에 없는 환율 정보를 보충합니다.
  Future<void> updateRatesIfNeeded() async {
    try {
      final localRates = await _localService.getRates();
      final localRateMap = {
        for (var rate in localRates) '${rate.baseCode}/${rate.quoteCode}': rate
      };

      final v6Rates = await _repository.getLatestRates('USD');

      final List<ExchangeRate> ratesToSave = [];
      for (var v6Rate in v6Rates) {
        final key = '${v6Rate.baseCode}/${v6Rate.quoteCode}';
        if (!localRateMap.containsKey(key)) {
          ratesToSave.add(v6Rate);
        }
      }

      if (ratesToSave.isNotEmpty) {
        await _localService.saveRates(ratesToSave);
        
      }
    } catch (e) {
      
    }
  }
}