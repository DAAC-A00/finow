
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ApiKeyStatus {
  valid('Valid', icon: Icons.check_circle, color: Colors.green),
  invalidKey('Invalid Key', icon: Icons.error, color: Colors.red),
  inactiveAccount('Inactive Account', icon: Icons.account_circle_outlined, color: Colors.orange),
  quotaReached('Quota Reached', icon: Icons.block, color: Colors.amber),
  unsupportedCode('Unsupported Currency', icon: Icons.money_off, color: Colors.grey),
  malformedRequest('Malformed Request', icon: Icons.warning, color: Colors.yellow),
  unknown('Unknown Status', icon: Icons.help_outline, color: Colors.grey),
  validating('Validating...', icon: Icons.sync, color: Colors.blue);

  const ApiKeyStatus(this.label, {required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;
}

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
    } on DioError catch (e) {
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
  return ApiKeyStatusNotifier(validationService);
});

class ApiKeyStatusNotifier extends StateNotifier<Map<String, ApiKeyStatus>> {
  final ApiKeyValidationService _validationService;

  ApiKeyStatusNotifier(this._validationService) : super({});

  Future<void> validateKey(String apiKey) async {
    state = {...state, apiKey: ApiKeyStatus.validating};
    final status = await _validationService.validateKey(apiKey);
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
}
