import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:finow/features/settings/api_quota_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';

final apiKeyValidationServiceProvider = Provider<ApiKeyValidationService>((ref) {
  final quotaService = ref.watch(apiQuotaServiceProvider);
  return ApiKeyValidationService(quotaService);
});

class ApiKeyValidationService {
  final ApiQuotaService _quotaService;

  ApiKeyValidationService(this._quotaService);

  Future<Map<String, dynamic>> validateKey(String apiKey) async {
    return await _quotaService.getQuota(apiKey);
  }
}

final apiKeyStatusProvider = StateNotifierProvider<ApiKeyStatusNotifier, Map<String, ApiKeyData>>((ref) {
  final validationService = ref.watch(apiKeyValidationServiceProvider);
  final apiKeyService = ref.watch(apiKeyServiceProvider);
  return ApiKeyStatusNotifier(validationService, apiKeyService);
});

class ApiKeyStatusNotifier extends StateNotifier<Map<String, ApiKeyData>> {
  final ApiKeyValidationService _validationService;
  final ApiKeyService _apiKeyService;

  ApiKeyStatusNotifier(this._validationService, this._apiKeyService) : super({}) {
    _loadStoredStatuses();
  }

  void _loadStoredStatuses() {
    final apiKeys = _apiKeyService.getApiKeys();
    final statusMap = <String, ApiKeyData>{};
    for (final keyData in apiKeys) {
      statusMap[keyData.key] = keyData;
    }
    state = statusMap;
  }

  Future<void> validateKey(String apiKey) async {
    final currentData = state[apiKey] ?? ApiKeyData(key: apiKey, status: ApiKeyStatus.unknown);
    state = {...state, apiKey: currentData.copyWith(status: ApiKeyStatus.validating)};

    final result = await _validationService.validateKey(apiKey);
    final status = result['status'] as ApiKeyStatus;
    final planQuota = result['plan_quota'] as int?;
    final requestsRemaining = result['requests_remaining'] as int?;

    final updatedData = currentData.copyWith(
      status: status,
      planQuota: planQuota,
      requestsRemaining: requestsRemaining,
      lastValidated: DateTime.now().millisecondsSinceEpoch,
    );

    final apiKeys = _apiKeyService.getApiKeys();
    final index = apiKeys.indexWhere((key) => key.key == apiKey);
    if (index != -1) {
      await _apiKeyService.updateApiKey(index, updatedData);
    }

    state = {...state, apiKey: updatedData};
  }

  void clearStatus(String apiKey) {
    final newState = Map<String, ApiKeyData>.from(state);
    newState.remove(apiKey);
    state = newState;
  }

  void clearAllStatuses() {
    state = {};
  }

  void refreshStatuses() {
    _loadStoredStatuses();
  }
}