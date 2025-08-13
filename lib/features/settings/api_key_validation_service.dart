import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_status.dart';

final apiKeyValidationServiceProvider = Provider<ApiKeyValidationService>((ref) {
  return ApiKeyValidationService(Dio());
});

class ApiKeyValidationService {
  final Dio _dio;
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  ApiKeyValidationService(this._dio);

  Future<ApiKeyStatus> validateKey(String apiKey) async {
    try {
      final response = await _dio.get('$_baseUrl/$apiKey/latest/USD');
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        return ApiKeyStatus.valid;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['result'] == 'error') {
        final errorType = e.response?.data['error-type'];
        switch (errorType) {
          case 'invalid-key':
            return ApiKeyStatus.invalidKey;
          case 'inactive-account':
            return ApiKeyStatus.inactiveAccount;
          case 'quota-reached':
            return ApiKeyStatus.quotaReached;
          case 'unsupported-code':
            return ApiKeyStatus.unsupportedCode;
          case 'malformed-request':
            return ApiKeyStatus.malformedRequest;
        }
      }
    }
    return ApiKeyStatus.unknown;
  }
}

final apiKeyStatusProvider = StateNotifierProvider<ApiKeyStatusNotifier, Map<String, ApiKeyStatus>>((ref) {
  final validationService = ref.watch(apiKeyValidationServiceProvider);
  final apiKeyService = ref.watch(apiKeyServiceProvider);
  return ApiKeyStatusNotifier(validationService, apiKeyService);
});

class ApiKeyStatusNotifier extends StateNotifier<Map<String, ApiKeyStatus>> {
  final ApiKeyValidationService _validationService;
  final ApiKeyService _apiKeyService;

  ApiKeyStatusNotifier(this._validationService, this._apiKeyService) : super({}) {
    _loadStoredStatuses();
  }

  /// 저장된 API 키 상태들을 로드합니다.
  void _loadStoredStatuses() {
    final apiKeys = _apiKeyService.getApiKeys();
    final statusMap = <String, ApiKeyStatus>{};
    
    for (final keyData in apiKeys) {
      statusMap[keyData.key] = keyData.status;
    }
    
    state = statusMap;
  }

  Future<void> validateKey(String apiKey) async {
    state = {...state, apiKey: ApiKeyStatus.validating};
    final status = await _validationService.validateKey(apiKey);
    
    // 검증 결과를 API key 전용 box에 저장
    await _apiKeyService.updateApiKeyStatus(apiKey, status);
    
    state = {...state, apiKey: status};
  }

  void clearStatus(String apiKey) {
    final newState = Map<String, ApiKeyStatus>.from(state);
    newState.remove(apiKey);
    state = newState;
  }

  void clearAllStatuses() {
    state = {};
  }

  /// API 키 목록이 변경될 때 상태를 새로고침합니다.
  void refreshStatuses() {
    _loadStoredStatuses();
  }
}