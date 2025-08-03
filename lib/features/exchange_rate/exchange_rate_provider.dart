import 'dart:async';

import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Notifier 클래스 정의
class ExchangeRateNotifier extends AsyncNotifier<ExchangeRate> {
  // build 메서드가 초기 데이터 로드를 처리
  @override
  Future<ExchangeRate> build() async {
    final localService = ref.watch(exchangeRateLocalServiceProvider);
    final localData = await localService.getRate();

    // 로컬 데이터가 있으면 즉시 반환
    if (localData != null) {
      return localData;
    }

    // 로컬 데이터가 없으면 API에서 가져와서 저장 후 반환
    return _fetchFromApiAndSave();
  }

  // API 호출 및 저장을 담당하는 내부 메서드
  Future<ExchangeRate> _fetchFromApiAndSave() async {
    final repository = ref.read(exchangeRateRepositoryProvider);
    final localService = ref.read(exchangeRateLocalServiceProvider);

    final newRate = await repository.getLatestRates('USD');
    await localService.saveRate(newRate);
    return newRate;
  }

  // UI에서 호출할 수 있는 수동 새로고침 메서드
  Future<void> refresh() async {
    // 상태를 로딩 중으로 변경하여 UI에 프로그레스 바 표시
    state = const AsyncValue.loading();
    // API를 통해 데이터를 강제로 다시 가져와 상태를 업데이트
    state = await AsyncValue.guard(() => _fetchFromApiAndSave());
  }
}

// 2. Notifier를 제공하는 Provider 정의
final exchangeRateProvider =
    AsyncNotifierProvider<ExchangeRateNotifier, ExchangeRate>(() {
  return ExchangeRateNotifier();
});