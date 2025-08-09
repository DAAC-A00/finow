import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/integrated_instrument.dart';
import '../repositories/integrated_symbols_repository.dart';

/// 통합 심볼 정보 동기화 서비스 프로바이더
final integratedSymbolsSyncServiceProvider = Provider<IntegratedSymbolsSyncService>((ref) {
  final repository = ref.watch(integratedSymbolsRepositoryProvider);
  return IntegratedSymbolsSyncService(repository);
});

/// 통합 심볼 정보 동기화 서비스
class IntegratedSymbolsSyncService {
  final IntegratedSymbolsRepository _repository;
  Timer? _warningUpdateTimer;
  bool _isInitialSyncCompleted = false;

  IntegratedSymbolsSyncService(this._repository);

  /// 앱 시작 시 초기 동기화 (한 번만 실행)
  Future<void> performInitialSync() async {
    if (_isInitialSyncCompleted) {
      print('통합 심볼 정보 초기 동기화는 이미 완료되었습니다.');
      return;
    }

    try {
      print('통합 심볼 정보 초기 동기화를 시작합니다...');
      
      // 저장된 데이터가 있는지 확인
      final hasStoredData = await _repository.hasStoredData();
      final lastUpdateTime = await _repository.getLastUpdateTime();
      
      // 저장된 데이터가 없거나 24시간이 지났다면 전체 동기화
      final shouldFullSync = !hasStoredData || 
          (lastUpdateTime != null && 
           DateTime.now().difference(lastUpdateTime).inHours >= 24);

      if (shouldFullSync) {
        print('전체 심볼 정보를 동기화합니다...');
        await _repository.fetchAndSaveInstruments();
        print('전체 심볼 정보 동기화 완료');
      } else {
        print('저장된 심볼 정보가 최신 상태입니다.');
      }

      _isInitialSyncCompleted = true;
      
      // 초기 동기화 완료 후 Bithumb 경고 정보 주기적 업데이트 시작
      startPeriodicWarningUpdates();
      
    } catch (e) {
      print('통합 심볼 정보 초기 동기화 중 오류 발생: $e');
      // 오류가 발생해도 주기적 업데이트는 시작
      startPeriodicWarningUpdates();
    }
  }

  /// Bithumb 경고 정보 주기적 업데이트 시작 (1분마다)
  void startPeriodicWarningUpdates() {
    // 기존 타이머가 있다면 취소
    _warningUpdateTimer?.cancel();
    
    print('Bithumb 경고 정보 주기적 업데이트를 시작합니다 (1분 간격)...');
    
    _warningUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        try {
          await _updateBithumbWarnings();
        } catch (e) {
          print('Bithumb 경고 정보 업데이트 중 오류 발생: $e');
        }
      },
    );
  }

  /// Bithumb 경고 정보만 업데이트
  Future<void> _updateBithumbWarnings() async {
    try {
      print('Bithumb 경고 정보를 업데이트합니다...');
      
      // 현재 저장된 모든 심볼 정보 가져오기
      final currentInstruments = await _repository.getStoredInstruments();
      
      if (currentInstruments.isEmpty) {
        print('저장된 심볼 정보가 없어 경고 정보 업데이트를 건너뜁니다.');
        return;
      }

      // Bithumb 심볼만 필터링
      final bithumbInstruments = currentInstruments
          .where((instrument) => instrument.exchange == 'bithumb')
          .toList();

      if (bithumbInstruments.isEmpty) {
        print('Bithumb 심볼 정보가 없어 경고 정보 업데이트를 건너뜁니다.');
        return;
      }

      // 최신 Bithumb 경고 정보 조회
      final updatedBithumbInstruments = await _repository.apiService
          .fetchBithumbInstruments();

      // 경고 정보만 업데이트된 심볼들로 교체
      final updatedInstruments = <IntegratedInstrument>[];
      
      for (final currentInstrument in currentInstruments) {
        if (currentInstrument.exchange == 'bithumb') {
          // Bithumb 심볼의 경우 최신 경고 정보로 교체
          final updatedInstrument = updatedBithumbInstruments.firstWhere(
            (updated) => updated.symbol == currentInstrument.symbol,
            orElse: () => currentInstrument,
          );
          updatedInstruments.add(updatedInstrument);
        } else {
          // Bybit 심볼은 그대로 유지
          updatedInstruments.add(currentInstrument);
        }
      }

      // 업데이트된 정보 저장
      await _repository.storageService.saveIntegratedInstruments(updatedInstruments);
      
      print('Bithumb 경고 정보 업데이트 완료 (${bithumbInstruments.length}개 심볼)');
      
    } catch (e) {
      print('Bithumb 경고 정보 업데이트 중 오류 발생: $e');
    }
  }

  /// 수동으로 전체 동기화 실행
  Future<void> performManualSync() async {
    try {
      print('수동 전체 동기화를 시작합니다...');
      await _repository.fetchAndSaveInstruments();
      print('수동 전체 동기화 완료');
    } catch (e) {
      print('수동 전체 동기화 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 주기적 업데이트 중지
  void stopPeriodicUpdates() {
    _warningUpdateTimer?.cancel();
    _warningUpdateTimer = null;
    print('Bithumb 경고 정보 주기적 업데이트를 중지했습니다.');
  }

  /// 서비스 정리
  void dispose() {
    stopPeriodicUpdates();
  }
}
