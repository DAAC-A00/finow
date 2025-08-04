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
        // 날짜가 같으면 아무것도 하지 않음
        return;
      }
    }

    // 날짜가 다르거나 캐시가 없으면 네트워크에서 데이터를 가져와 저장
    try {
      final rates = await _repository.getLatestRates('USD');
      await _localService.saveRates(rates);
    } catch (e) {
      // 에러 처리 (예: 로그 출력)
      print('Failed to update exchange rates in background: $e');
    }
  }
}
