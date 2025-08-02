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

  Future<ExchangeRate> getLatestRates(String baseCurrency) async {
    try {
      final response = await _dio.get('$_baseUrl/$_apiKey/latest/$baseCurrency');
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        // API 응답의 conversion_rates 필드가 Map<String, dynamic> 형태이므로,
        // Map<String, double>으로 변환해준다.
        final ratesData = response.data['conversion_rates'] as Map<String, dynamic>;
        final convertedRates = ratesData.map((key, value) => MapEntry(key, value.toDouble()));

        // 변환된 맵을 포함하여 새로운 Map 생성
        final updatedData = Map<String, dynamic>.from(response.data);
        updatedData['conversion_rates'] = convertedRates;

        return ExchangeRate.fromJson(updatedData);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
