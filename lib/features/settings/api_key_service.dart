import 'dart:async';

import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:math';

final apiKeyServiceProvider = Provider<ApiKeyService>((ref) {
  final box = Hive.box<ApiKeyData>('api_keys');
  return ApiKeyService(box);
});

final apiKeyListProvider = StreamProvider<List<ApiKeyData>>((ref) {
  final apiKeyService = ref.watch(apiKeyServiceProvider);
  final controller = StreamController<List<ApiKeyData>>();

  // Add the initial data
  controller.add(apiKeyService.getApiKeys());

  // Listen for box changes
  final subscription = apiKeyService._box.watch().listen((event) {
    controller.add(apiKeyService.getApiKeys());
  });

  // When the provider is destroyed, close the controller and cancel the subscription
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

class ApiKeyService {
  final Box<ApiKeyData> _box;
  final List<String> _defaultApiKeys = const [
    '842f9ce049b12b202bc6932f',
    '9bc45de7f3b69ae2eafd2930',
  ];

  ApiKeyService(this._box) {
    _initializeDefaultKeys();
  }

  void _initializeDefaultKeys() {
    if (_box.isEmpty) {
      // 기본 API 키들을 초기화
      for (final keyString in _defaultApiKeys) {
        final apiKeyData = ApiKeyData(
          key: keyString,
          status: ApiKeyStatus.unknown,
        );
        _box.add(apiKeyData);
      }
    }
  }

  List<ApiKeyData> getApiKeys() {
    return _box.values.toList();
  }

  Future<void> addApiKey(String key) async {
    // 중복 체크
    final existing = _box.values.where((apiKeyData) => apiKeyData.key == key);
    if (existing.isEmpty) {
      final newApiKeyData = ApiKeyData(
        key: key,
        status: ApiKeyStatus.unknown,
      );
      await _box.add(newApiKeyData);
    }
  }

  Future<void> updateApiKeyStatus(String key, ApiKeyStatus status) async {
    final apiKeyDataList = _box.values.toList();
    final index = apiKeyDataList.indexWhere((data) => data.key == key);
    
    if (index != -1) {
      final updatedData = apiKeyDataList[index].copyWith(
        status: status,
        lastValidated: DateTime.now().millisecondsSinceEpoch,
      );
      await _box.putAt(index, updatedData);
    }
  }

  Future<void> updateApiKey(int index, ApiKeyData updatedApiKeyData) async {
    if (index >= 0 && index < _box.length) {
      await _box.putAt(index, updatedApiKeyData);
    }
  }

  Future<void> deleteApiKey(String key) async {
    final apiKeyDataList = _box.values.toList();
    final index = apiKeyDataList.indexWhere((data) => data.key == key);
    
    if (index != -1) {
      await _box.deleteAt(index);
    }
  }

  /// 우선순위에 따라 API 키를 선택합니다.
  /// 동일한 우선순위 내에서는 랜덤하게 선택됩니다.
  String getApiKeyByPriority() {
    final keys = getApiKeys();
    if (keys.isEmpty) {
      return _defaultApiKeys.first;
    }

    // 우선순위별로 그룹화
    final Map<int, List<ApiKeyData>> priorityGroups = {};
    for (final keyData in keys) {
      final priority = keyData.priority;
      if (!priorityGroups.containsKey(priority)) {
        priorityGroups[priority] = [];
      }
      priorityGroups[priority]!.add(keyData);
    }

    // 가장 높은 우선순위(가장 낮은 숫자) 그룹을 찾기
    final sortedPriorities = priorityGroups.keys.toList()..sort();
    final highestPriorityGroup = priorityGroups[sortedPriorities.first]!;

    // 동일한 우선순위 내에서 랜덤 선택
    final random = Random();
    final selectedKeyData = highestPriorityGroup[random.nextInt(highestPriorityGroup.length)];
    return selectedKeyData.key;
  }

  /// 기존 호환성을 위한 메소드 (deprecated)
  @Deprecated('Use getApiKeyByPriority() instead')
  String getRandomApiKey() {
    return getApiKeyByPriority();
  }
}
