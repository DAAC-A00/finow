
import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// 앱 시작 시 v6.exchangerate-api.com의 데이터를 사용하여
/// 로컬 환율 정보를 보충하는 일회성 서비스를 제공하는 Provider
final exchangeRateUpdateServiceProvider =
    Provider<ExchangeRateUpdateService>((ref) {
  return ExchangeRateUpdateService(
    ref,
  );
});

class ExchangeRateUpdateService {
  final Ref _ref;

  ExchangeRateUpdateService(this._ref);

  /// v6 API를 통해 로컬에 없는 환율 정보를 보충하고, API 키 상태를 업데이트합니다.
  Future<void> updateRatesAndValidateKeys() async {
    // API 키 유효성 검사
    await _validateApiKeys();

    // 환율 정보 업데이트
    try {
      final localRates = await _ref.read(exchangeRateLocalServiceProvider).getRates();
      final localRateMap = {
        for (var rate in localRates) '${rate.baseCode}/${rate.quoteCode}': rate
      };

      final v6Rates = await _ref.read(exchangeRateRepositoryProvider).getLatestRates('USD');

      final List<ExchangeRate> ratesToSave = [];
      for (var v6Rate in v6Rates) {
        final key = '${v6Rate.baseCode}/${v6Rate.quoteCode}';
        if (!localRateMap.containsKey(key)) {
          ratesToSave.add(v6Rate);
        }
      }

      if (ratesToSave.isNotEmpty) {
        await _ref.read(exchangeRateLocalServiceProvider).saveRates(ratesToSave);
      }
    } catch (e) {
      debugPrint('Error updating exchange rates: $e');
    }
  }

  Future<void> _validateApiKeys() async {
    final apiKeyService = _ref.read(apiKeyServiceProvider);
    final validationService = _ref.read(apiKeyValidationServiceProvider);
    final apiKeys = apiKeyService.getApiKeys();

    for (final apiKeyData in apiKeys) {
      await validationService.validateKey(apiKeyData.key);
    }
  }
}
