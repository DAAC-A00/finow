import 'dart:async';

import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:finow/features/exchange_rate/exconvert_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1분마다 exconvert.com API를 호출하고 이어서 v6 API로 보완하여 환율 정보를 주기적으로 업데이트하는 서비스를 제공하는 Provider
final exConvertPeriodicUpdateServiceProvider = Provider<ExConvertPeriodicUpdateService>((ref) {
  return ExConvertPeriodicUpdateService(
    ref.watch(exConvertApiClientProvider),
    ref.watch(exchangeRateRepositoryProvider),
    ref.watch(exchangeRateLocalServiceProvider),
  );
});

class ExConvertPeriodicUpdateService {
  final ExConvertApiClient _exconvertApiClient;
  final ExchangeRateRepository _v6Repository;
  final ExchangeRateLocalService _localService;
  Timer? _timer;

  ExConvertPeriodicUpdateService(this._exconvertApiClient, this._v6Repository, this._localService);

  /// 주기적인 환율 정보 업데이트를 시작합니다.
  void startPeriodicUpdates() {
    // 이미 타이머가 실행 중이면 중복 실행 방지
    if (_timer?.isActive ?? false) return;

    // 즉시 한 번 실행
    _updateRates();

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _updateRates();
    });
  }

  /// 환율 정보를 업데이트하는 내부 로직
  Future<void> _updateRates() async {
    try {
      // 1단계: exconvert를 통해 환율 정보 수집
      await _collectFromExconvert();
      
      // 2단계: v6 exchange rate를 통해 보완 수집
      await _collectFromV6ExchangeRate();
      
    } catch (e) {
      // 에러 처리
    }
  }

  /// exconvert API를 통한 환율 정보 수집
  Future<void> _collectFromExconvert() async {
    try {
      final exconvertRates = await _exconvertApiClient.getLatestRates('USD');
      
      if (exconvertRates.isNotEmpty) {
        await _localService.updateRates(exconvertRates);
      }
    } catch (e) {
      // 에러 처리
    }
  }

  /// v6 exchange rate API를 통한 보완 수집
  Future<void> _collectFromV6ExchangeRate() async {
    try {
      // UTC 기준 오늘 날짜 확인
      final utcNow = DateTime.now().toUtc();
      final todayUtc = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);
      
      // 로컬에서 오늘 v6 데이터가 있는지 확인
      if (await _hasV6DataForToday(todayUtc)) {
        return;
      }
      
      // 현재 로컬에 저장된 환율 정보 가져오기
      final localRates = await _localService.getRates();
      final localRateMap = {
        for (var rate in localRates) '${rate.baseCode}/${rate.quoteCode}': rate
      };

      // v6 API에서 환율 정보 가져오기
      final v6Rates = await _v6Repository.getLatestRates('USD');

      // exconvert에서 확보하지 못한 환율 데이터만 필터링
      final List<ExchangeRate> ratesToSave = [];
      for (var v6Rate in v6Rates) {
        final key = '${v6Rate.baseCode}/${v6Rate.quoteCode}';
        if (!localRateMap.containsKey(key)) {
          ratesToSave.add(v6Rate);
        }
      }

      if (ratesToSave.isNotEmpty) {
        await _localService.updateRates(ratesToSave);
      } else {
        // 추가할 데이터 없음
      }
    } catch (e) {
      // 에러 처리
    }
  }

  /// UTC 기준 오늘 날짜에 v6 데이터가 있는지 확인
  Future<bool> _hasV6DataForToday(DateTime todayUtc) async {
    try {
      final localRates = await _localService.getRates();
      final todayStartUnix = todayUtc.millisecondsSinceEpoch ~/ 1000;
      final todayEndUnix = todayUtc.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
      
      // v6 소스에서 오늘 날짜 범위 내의 데이터가 있는지 확인
      return localRates.any((rate) => 
        rate.source == 'v6.exchangerate-api.com' &&
        rate.lastUpdatedUnix >= todayStartUnix &&
        rate.lastUpdatedUnix < todayEndUnix
      );
    } catch (e) {
      return false;
    }
  }

  /// 서비스 종료 시 타이머를 취소합니다.
  void dispose() {
    _timer?.cancel();
  }
}