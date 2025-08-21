
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/settings/api_key_status.dart';

final apiQuotaServiceProvider = Provider<ApiQuotaService>((ref) {
  return ApiQuotaService(Dio());
});

class ApiQuotaService {
  final Dio _dio;
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  ApiQuotaService(this._dio);

  Future<Map<String, dynamic>> getQuota(String apiKey) async {
    try {
      final response = await _dio.get('$_baseUrl/$apiKey/quota');
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        return {
          'status': ApiKeyStatus.valid,
          'plan_quota': response.data['plan_quota'],
          'requests_remaining': response.data['requests_remaining'],
        };
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['result'] == 'error') {
        final errorType = e.response?.data['error-type'];
        switch (errorType) {
          case 'invalid-key':
            return {'status': ApiKeyStatus.invalidKey};
          case 'inactive-account':
            return {'status': ApiKeyStatus.inactiveAccount};
          case 'quota-reached':
            return {'status': ApiKeyStatus.quotaReached};
        }
      }
    }
    return {'status': ApiKeyStatus.unknown};
  }
}
