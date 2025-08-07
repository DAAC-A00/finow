import 'package:dio/dio.dart';
import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exConvertApiClientProvider = Provider<ExConvertApiClient>((ref) {
  return ExConvertApiClient();
});

class ExConvertApiClient {
  final Dio _dio;
  final String _accessKey = '1898dca6-e1682f60-3a785bd4-1114dc4c';
  final String _baseUrl = 'https://api.exconvert.com/fetchAll';

  ExConvertApiClient() : _dio = Dio();

  Future<List<ExchangeRate>> getLatestRates(String baseCurrency) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'access_key': _accessKey,
          'from': baseCurrency,
        },
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final ratesData = response.data['result'] as Map<String, dynamic>;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final baseCode = response.data['base'] as String;

        return ratesData.entries
            .where((entry) => entry.key != baseCode) // baseCode와 quoteCode가 다른 경우만 필터링
            .map<ExchangeRate>((entry) {
          return ExchangeRate(
            lastUpdatedUnix: now,
            baseCode: baseCode,
            quoteCode: entry.key,
            price: (entry.value as num).toDouble(),
            source: 'exconvert.com',
          );
        }).toList();
      } else {
        throw Exception('Failed to load exchange rates from exconvert.com. Response: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the exconvert.com server: $e');
    }
  }
}
