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
      await _saveRates(rates);
    } catch (e) {
      print('Failed to update exchange rates in background: $e');
    }
  }

  Future<void> _saveRates(List<ExchangeRate> rates) async {
    await _localService.saveRates(rates);
  }
}

