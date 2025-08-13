import 'package:dio/dio.dart';
import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/settings/api_key_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final dio = Dio();
  final apiKeyService = ref.watch(apiKeyServiceProvider);
  return ExchangeRateRepository(dio, apiKeyService);
});

class ExchangeRateRepository {
  final Dio _dio;
  final ApiKeyService _apiKeyService;
  final String _baseUrl =
      'https://v6.exchangerate-api.com/v6';

  ExchangeRateRepository(this._dio, this._apiKeyService);

  Future<List<ExchangeRate>> getLatestRates(String baseCurrency) async {
    try {
      final apiKey = _apiKeyService.getApiKeyByPriority();
      final response = await _dio.get('$_baseUrl/$apiKey/latest/$baseCurrency');
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        final ratesData = response.data['conversion_rates'] as Map<String, dynamic>;
        final lastUpdatedUnix = response.data['time_last_update_unix'] as int;
        final baseCode = response.data['base_code'] as String;

        return ratesData.entries
            .where((entry) => entry.key != baseCode)
            .map<ExchangeRate>((entry) {
          return ExchangeRate(
            lastUpdatedUnix: lastUpdatedUnix,
            baseCode: baseCode,
            quoteCode: entry.key,
            price: entry.value.toDouble(),
            source: 'v6.exchangerate-api.com',
          );
        }).toList();
      } else {
        throw Exception('Failed to load exchange rates from v6.exchangerate-api.com');
      }
    } catch (e) {
      throw Exception('Failed to connect to the v6.exchangerate-api.com server: $e');
    }
  }
}
