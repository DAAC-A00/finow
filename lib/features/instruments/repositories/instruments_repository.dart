import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/instrument.dart';
import '../services/exchange_api_service.dart';
import '../services/instruments_local_storage_service.dart';

/// 통합 심볼 관리 레포지토리 프로바이더
final instrumentsRepositoryProvider = Provider<InstrumentsRepository>((ref) {
  return InstrumentsRepository();
});

/// 통합 심볼 관리 레포지토리
class InstrumentsRepository {
  final ExchangeApiService _apiService = ExchangeApiService();
  final InstrumentsLocalStorageService _storageService = InstrumentsLocalStorageService();

  /// API에서 최신 심볼 정보를 가져와 로컬 스토리지에 저장
  Future<List<Instrument>> fetchAndSaveInstruments() async {
    try {
      // API에서 최신 데이터 조회
      final instruments = await _apiService.fetchAllInstruments();
      
      // 로컬 스토리지에 저장
      await _storageService.saveInstruments(instruments);
      
      return instruments;
    } catch (e) {
      throw Exception('심볼 정보 조회 및 저장 중 오류 발생: $e');
    }
  }

  /// Binance 전용 동기화: Binance Spot, UM, CM 심볼 정보를 모두 받아와 저장
  /// 주의: 이 메소드는 Binance 데이터만 저장하므로 기존 다른 거래소 데이터를 덮어씁니다.
  /// 전체 거래소 데이터가 필요하다면 fetchAndSaveInstruments()를 사용하세요.
  Future<List<Instrument>> fetchAndSaveBinanceInstruments() async {
    try {
      final spot = await _apiService.fetchBinanceSpotInstruments();
      final um = await _apiService.fetchBinanceUmInstruments();
      final cm = await _apiService.fetchBinanceCmInstruments();
      final all = <Instrument>[];
      all.addAll(spot);
      all.addAll(um);
      all.addAll(cm);
      await _storageService.saveInstruments(all);
      return all;
    } catch (e) {
      throw Exception('Binance 심볼 정보 조회 및 저장 중 오류 발생: $e');
    }
  }

  /// Bitget 전용 동기화: Bitget Spot, UM 심볼 정보를 모두 받아와 저장
  Future<List<Instrument>> fetchAndSaveBitgetInstruments() async {
    try {
      final spot = await _apiService.fetchBitgetSpotInstruments();
      final um = await _apiService.fetchBitgetUmInstruments();
      final all = <Instrument>[];
      all.addAll(spot);
      all.addAll(um);
      await _storageService.saveInstruments(all);
      return all;
    } catch (e) {
      throw Exception('Bitget 심볼 정보 조회 및 저장 중 오류 발생: $e');
    }
  }

  /// Coinbase 전용 동기화: Coinbase 심볼 정보를 모두 받아와 저장
  Future<List<Instrument>> fetchAndSaveCoinbaseInstruments() async {
    try {
      final instruments = await _apiService.fetchCoinbaseInstruments();
      await _storageService.saveInstruments(instruments);
      return instruments;
    } catch (e) {
      throw Exception('Coinbase 심볼 정보 조회 및 저장 중 오류 발생: $e');
    }
  }

  /// 로컬 스토리지에서 심볼 정보 불러오기
  Future<List<Instrument>> getStoredInstruments() async {
    return await _storageService.loadInstruments();
  }

  /// 특정 거래소의 심볼만 조회
  Future<List<Instrument>> getInstrumentsByExchange(String exchange) async {
    return await _storageService.loadInstrumentsByExchange(exchange);
  }

  /// 심볼 검색
  Future<List<Instrument>> searchInstruments(String query) async {
    return await _storageService.searchInstruments(query);
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
  Future<List<Instrument>> getBybitInstruments() async {
    return await getInstrumentsByExchange('bybit');
  }

  /// Bithumb 심볼만 조회
  Future<List<Instrument>> getBithumbInstruments() async {
    return await getInstrumentsByExchange('bithumb');
  }

  /// Binance 심볼만 조회
  Future<List<Instrument>> getBinanceInstruments() async {
    return await getInstrumentsByExchange('binance');
  }

  /// 특정 카테고리의 심볼만 조회
  Future<List<Instrument>> getInstrumentsByCategory(String category) async {
    return await _storageService.loadInstrumentsByCategory(category);
  }

  /// Bybit 특정 카테고리 심볼만 조회
  Future<List<Instrument>> getBybitInstrumentsByCategory(String category) async {
    final instruments = await _storageService.loadInstruments();
    return instruments.where((instrument) => 
        instrument.exchange == 'bybit' && instrument.category == category).toList();
  }

  /// Bybit Spot 심볼만 조회
  Future<List<Instrument>> getBybitSpotInstruments() async {
    return await getBybitInstrumentsByCategory('spot');
  }

  /// Bybit Linear 심볼만 조회
  Future<List<Instrument>> getBybitLinearInstruments() async {
    return await getBybitInstrumentsByCategory('linear');
  }

  /// Bybit Inverse 심볼만 조회
  Future<List<Instrument>> getBybitInverseInstruments() async {
    return await getBybitInstrumentsByCategory('inverse');
  }

  /// Binance 특정 카테고리 심볼만 조회
  Future<List<Instrument>> getBinanceInstrumentsByCategory(String category) async {
    final instruments = await _storageService.loadInstruments();
    return instruments.where((instrument) => 
        instrument.exchange == 'binance' && instrument.category == category).toList();
  }

  /// Binance Spot 심볼만 조회
  Future<List<Instrument>> getBinanceSpotInstruments() async {
    return await getBinanceInstrumentsByCategory('spot');
  }

  /// Binance USDⓈ-M 선물 심볼만 조회
  Future<List<Instrument>> getBinanceUmInstruments() async {
    return await getBinanceInstrumentsByCategory('um');
  }

  /// Binance COIN-M 선물 심볼만 조회
  Future<List<Instrument>> getBinanceCmInstruments() async {
    return await getBinanceInstrumentsByCategory('cm');
  }

  /// 데이터 새로고침 (API 재조회 후 저장)
  Future<List<Instrument>> refreshInstruments() async {
    return await fetchAndSaveInstruments();
  }

  /// API 서비스에 접근 (동기화 서비스에서 사용)
  ExchangeApiService get apiService => _apiService;

  /// 스토리지 서비스에 접근 (동기화 서비스에서 사용)
  InstrumentsLocalStorageService get storageService => _storageService;
}