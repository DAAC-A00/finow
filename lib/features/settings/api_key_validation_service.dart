
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiKeyValidationServiceProvider = Provider<ApiKeyValidationService>((ref) {
  return ApiKeyValidationService(ref);
});

final apiKeyStatusProvider = StateNotifierProvider<ApiKeyStatusNotifier, Map<String, ApiKeyData>>((ref) {
  return ApiKeyStatusNotifier(ref);
});

class ApiKeyStatusNotifier extends StateNotifier<Map<String, ApiKeyData>> {
  final Ref _ref;

  ApiKeyStatusNotifier(this._ref) : super({});

  Future<void> validateKey(String key) async {
    await _ref.read(apiKeyValidationServiceProvider).validateKey(key);
  }

  void updateApiKeys(List<ApiKeyData> apiKeyList) {
    final newMap = { for (var apiKey in apiKeyList) apiKey.key : apiKey };
    state = newMap;
  }
}

class ApiKeyValidationService {
  final Ref _ref;
  final Dio _dio = Dio();

  ApiKeyValidationService(this._ref);

  Future<void> validateKey(String key) async {
    try {
      final response = await _dio.get('https://v6.exchangerate-api.com/v6/$key/quota');
      final data = response.data;

      if (data['result'] == 'success') {
        final apiKeyService = _ref.read(apiKeyServiceProvider);
        final apiKeyData = apiKeyService.getApiKeys().firstWhere((element) => element.key == key);

        final updatedApiKeyData = apiKeyData.copyWith(
          status: ApiKeyStatus.valid,
          lastValidated: DateTime.now().millisecondsSinceEpoch,
          planQuota: data['plan_quota'],
          requestsRemaining: data['requests_remaining'],
          refreshDayOfMonth: data['refresh_day_of_month'],
        );
        
        final index = apiKeyService.getApiKeys().indexWhere((element) => element.key == key);
        await apiKeyService.updateApiKey(index, updatedApiKeyData);

      } else if (data['error-type'] == 'invalid-key') {
        await _ref.read(apiKeyServiceProvider).updateApiKeyStatus(key, ApiKeyStatus.invalidKey);
      } else {
        await _ref.read(apiKeyServiceProvider).updateApiKeyStatus(key, ApiKeyStatus.unknown);
      }
    } catch (e) {
      await _ref.read(apiKeyServiceProvider).updateApiKeyStatus(key, ApiKeyStatus.unknown);
    }
  }
}
