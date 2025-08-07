import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exconvert_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exConvertUpdateServiceProvider = Provider<ExConvertUpdateService>((ref) {
  return ExConvertUpdateService(
    ref.watch(exchangeRateLocalServiceProvider),
    ExConvertApiClient(),
  );
});

class ExConvertUpdateService {
  final ExchangeRateLocalService _localService;
  final ExConvertApiClient _apiClient;

  ExConvertUpdateService(this._localService, this._apiClient);

  Future<void> updateExConvertRates() async {
    try {
      final List<ExchangeRate> rates = await _apiClient.getLatestRates('USD');
      await _localService.saveRates(rates);
      print('Successfully updated rates from exconvert.com');
    } catch (e) {
      print('Failed to update rates from exconvert.com: $e');
    }
  }
}