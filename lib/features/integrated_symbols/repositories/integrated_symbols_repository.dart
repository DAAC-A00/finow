import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/integrated_instrument.dart';
import '../services/exchange_api_service.dart';
import '../services/integrated_symbols_local_storage_service.dart';

/// 통합 심볼 관리 레포지토리 프로바이더
final integratedSymbolsRepositoryProvider = Provider<IntegratedSymbolsRepository>((ref) {
  return IntegratedSymbolsRepository();
});

/// 통합 심볼 관리 레포지토리
class IntegratedSymbolsRepository {
  final ExchangeApiService _apiService = ExchangeApiService();
  final IntegratedSymbolsLocalStorageService _storageService = IntegratedSymbolsLocalStorageService();

  /// API에서 최신 심볼 정보를 가져와 로컬 스토리지에 저장
  Future<List<IntegratedInstrument>> fetchAndSaveInstruments() async {
    try {
      // API에서 최신 데이터 조회
      final instruments = await _apiService.fetchAllInstruments();
      
      // 로컬 스토리지에 저장
      await _storageService.saveIntegratedInstruments(instruments);
      
      return instruments;
    } catch (e) {
      throw Exception('심볼 정보 조회 및 저장 중 오류 발생: $e');
    }
  }

  /// 로컬 스토리지에서 심볼 정보 불러오기
  Future<List<IntegratedInstrument>> getStoredInstruments() async {
    return await _storageService.loadIntegratedInstruments();
  }

  /// 특정 거래소의 심볼만 조회
  Future<List<IntegratedInstrument>> getInstrumentsByExchange(String exchange) async {
    return await _storageService.loadInstrumentsByExchange(exchange);
  }

  /// 심볼 검색
  Future<List<IntegratedInstrument>> searchInstruments(String query) async {
    return await _storageService.searchInstruments(query);
  }

  /// 마지막 업데이트 시간 조회
  Future<DateTime?> getLastUpdateTime() async {
    return await _storageService.getLastUpdateTime();
  }

  /// 저장된 데이터가 있는지 확인
  Future<bool> hasStoredData() async {
    return await _storageService.hasStoredData();
  }

  /// 저장된 데이터 삭제
  Future<void> clearStoredData() async {
    await _storageService.clearStoredData();
  }

  /// Bybit 심볼만 조회
  Future<List<IntegratedInstrument>> getBybitInstruments() async {
    return await getInstrumentsByExchange('bybit');
  }

  /// Bithumb 심볼만 조회
  Future<List<IntegratedInstrument>> getBithumbInstruments() async {
    return await getInstrumentsByExchange('bithumb');
  }

  /// 데이터 새로고침 (API 재조회 후 저장)
  Future<List<IntegratedInstrument>> refreshInstruments() async {
    return await fetchAndSaveInstruments();
  }

  /// API 서비스에 접근 (동기화 서비스에서 사용)
  ExchangeApiService get apiService => _apiService;

  /// 스토리지 서비스에 접근 (동기화 서비스에서 사용)
  IntegratedSymbolsLocalStorageService get storageService => _storageService;
}
