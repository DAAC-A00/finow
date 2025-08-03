import 'package:dio/dio.dart';
import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final dio = Dio();
  return ExchangeRateRepository(dio);
});

class ExchangeRateRepository {
  final Dio _dio;
  final String _apiKey = '842f9ce049b12b202bc6932f';
  final String _baseUrl =
      'https://v6.exchangerate-api.com/v6';

  ExchangeRateRepository(this._dio);

  Future<List<ExchangeRate>> getLatestRates(String baseCurrency) async {
    try {
      final response = await _dio.get('$_baseUrl/$_apiKey/latest/$baseCurrency');
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        final ratesData = response.data['conversion_rates'] as Map<String, dynamic>;
        final lastUpdatedUnix = response.data['time_last_update_unix'] as int;
        final baseCode = response.data['base_code'] as String;

        return ratesData.entries.map((entry) {
          return ExchangeRate(
            lastUpdatedUnix: lastUpdatedUnix,
            baseCode: baseCode,
            quoteCode: entry.key,
            rate: entry.value.toDouble(),
          );
        }).toList();
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
