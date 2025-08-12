
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:math';

final apiKeyServiceProvider = Provider<ApiKeyService>((ref) {
  final box = Hive.box('settings');
  return ApiKeyService(box);
});

final apiKeyListProvider = StateProvider<List<String>>((ref) {
  final apiKeyService = ref.watch(apiKeyServiceProvider);
  return apiKeyService.getApiKeys();
});

class ApiKeyService {
  final Box _box;
  final String _apiKeyStorageKey = 'apiKeys_v6ExchangeRate';
  final List<String> _defaultApiKeys = const [
    '842f9ce049b12b202bc6932f',
    '9bc45de7f3b69ae2eafd2930',
  ];

  ApiKeyService(this._box) {
    _initializeDefaultKeys();
  }

  void _initializeDefaultKeys() {
    if (_box.get(_apiKeyStorageKey) == null || (_box.get(_apiKeyStorageKey) as List).isEmpty) {
      _box.put(_apiKeyStorageKey, _defaultApiKeys);
    }
  }

  List<String> getApiKeys() {
    final keys = _box.get(_apiKeyStorageKey, defaultValue: _defaultApiKeys);
    // Hive can return List<dynamic>, so we ensure it's List<String>
    return List<String>.from(keys);
  }

  Future<void> addApiKey(String key) async {
    final keys = getApiKeys();
    if (!keys.contains(key)) {
      keys.add(key);
      await _box.put(_apiKeyStorageKey, keys);
    }
  }

  Future<void> updateApiKey(int index, String newKey) async {
    final keys = getApiKeys();
    if (index >= 0 && index < keys.length) {
      keys[index] = newKey;
      await _box.put(_apiKeyStorageKey, keys);
    }
  }

  Future<void> deleteApiKey(String key) async {
    final keys = getApiKeys();
    keys.remove(key);
    await _box.put(_apiKeyStorageKey, keys);
  }

  String getRandomApiKey() {
    final keys = getApiKeys();
    if (keys.isEmpty) {
      // This should not happen if defaults are initialized, but as a fallback.
      return _defaultApiKeys.first;
    }
    final random = Random();
    return keys[random.nextInt(keys.length)];
  }
}
