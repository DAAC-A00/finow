import 'package:finow/features/instruments/models/instrument.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final instrumentsLocalStorageServiceProvider = Provider<InstrumentsLocalStorageService>((ref) {
  return InstrumentsLocalStorageService();
});

/// 통합 심볼 정보 로컬 스토리지 관리 서비스 (Hive 기반)
/// 각 심볼을 개별 키-값으로 저장하여 Storage Viewer에서 개별 관리 가능
class InstrumentsLocalStorageService {
  static const String _boxName = 'instruments';
  static const String _settingsBoxName = 'settings';
  

  /// Hive Box 가져오기 (없으면 생성)
  Future<Box<Instrument>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Instrument>(_boxName);
    }
    return Hive.box<Instrument>(_boxName);
  }

  /// Settings Box 가져오기 (마지막 업데이트 시간 저장용)
  Future<Box> _getSettingsBox() async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      return await Hive.openBox(_settingsBoxName);
    }
    return Hive.box(_settingsBoxName);
  }

  /// 심볼 키 생성 (예: "BTCUSDT_spot_bybit", "BTCKRW_spot_bithumb")
  String _generateSymbolKey(Instrument instrument) {
    return '${instrument.symbol}_${instrument.category ?? 'unknown'}_${instrument.exchange}';
  }

  /// 통합 심볼 정보를 Hive Box에 개별 저장
  Future<void> saveInstruments(List<Instrument> instruments) async {
    try {
      final box = await _getBox();
      
      // 기존 데이터 삭제 (전체 동기화 시)
      await box.clear();
      
      // 카테고리별 통계
      final categoryStats = <String, int>{};
      
      // 각 심볼을 개별 키-값으로 저장
      for (final instrument in instruments) {
        final key = _generateSymbolKey(instrument);
        await box.put(key, instrument);
        
        // 카테고리 통계 업데이트
        final category = instrument.category ?? 'unknown';
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }
      
      
      
      debugPrint('💾 통합 심볼 정보 저장 완료: ${instruments.length}개 항목');
      debugPrint('📊 카테고리별 저장 통계: $categoryStats');
      
      // 몇 개 샘플의 category 정보 확인
      if (instruments.isNotEmpty) {
        final samples = instruments.take(5);
        debugPrint('🔍 저장된 샘플 데이터 category 확인:');
        for (final sample in samples) {
          debugPrint('   ${sample.symbol} (${sample.exchange}): category=${sample.category}');
        }
      }
    } catch (e) {
      throw Exception('통합 심볼 정보 저장 중 오류 발생: $e');
    }
  }

  /// Hive Box에서 통합 심볼 정보 개별 불러오기
  Future<List<Instrument>> loadInstruments() async {
    try {
      final box = await _getBox();
      final List<Instrument> instruments = [];
      
      // 모든 키를 순회하며 Instrument 객체만 수집
      for (final key in box.keys) {
        final instrument = box.get(key);
        if (instrument != null) {
          instruments.add(instrument);
        }
      }
      
      debugPrint('통합 심볼 정보 개별 불러오기 완료: ${instruments.length}개 항목');
      return instruments;
    } catch (e) {
      debugPrint('통합 심볼 정보 불러오기 중 오류 발생: $e');
      return [];
    }
  }

  

  /// 저장된 데이터가 있는지 확인 (개별 심볼 기준)
  Future<bool> hasStoredData() async {
    try {
      final box = await _getBox();
      // Instrument Box에 데이터가 있는지 확인
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 저장된 데이터 삭제 (모든 개별 심볼 삭제)
  Future<void> clearStoredData() async {
    try {
      final box = await _getBox();
      await box.clear(); // 모든 데이터 삭제
      debugPrint('저장된 통합 심볼 정보 전체 삭제 완료');
    } catch (e) {
      throw Exception('저장된 데이터 삭제 중 오류 발생: $e');
    }
  }

  /// 개별 심볼 저장
  Future<void> saveInstrument(Instrument instrument) async {
    try {
      final box = await _getBox();
      final key = _generateSymbolKey(instrument);
      await box.put(key, instrument);
      debugPrint('개별 심볼 저장 완료: ${instrument.symbol} (${instrument.exchange})');
    } catch (e) {
      throw Exception('개별 심볼 저장 중 오류 발생: $e');
    }
  }

  /// 개별 심볼 삭제
  Future<void> deleteInstrument(String symbol, String category, String exchange) async {
    try {
      final box = await _getBox();
      final key = '${symbol}_${category}_$exchange';
      await box.delete(key);
      debugPrint('개별 심볼 삭제 완료: $symbol ($exchange)');
    } catch (e) {
      throw Exception('개별 심볼 삭제 중 오류 발생: $e');
    }
  }

  /// 개별 심볼 조회
  Future<Instrument?> getInstrument(String symbol, String category, String exchange) async {
    try {
      final box = await _getBox();
      final key = '${symbol}_${category}_$exchange';
      return box.get(key);
    } catch (e) {
      debugPrint('개별 심볼 조회 중 오류 발생: $e');
      return null;
    }
  }

  /// 저장된 모든 심볼 키 목록 조회
  Future<List<String>> getAllSymbolKeys() async {
    try {
      final box = await _getBox();
      return box.keys.cast<String>().toList();
    } catch (e) {
      debugPrint('심볼 키 목록 조회 중 오류 발생: $e');
      return [];
    }
  }

  /// 필터링된 통합 심볼 정보 가져오기 (개별 저장 구조 기반)
  Future<List<Instrument>> getFilteredInstruments({
    String? exchange,
    String? status,
    String? searchQuery,
  }) async {
    final allInstruments = await loadInstruments();
    
    return allInstruments.where((instrument) {
      // 거래소 필터
      if (exchange != null && instrument.exchange != exchange) {
        return false;
      }
      
      // 상태 필터
      if (status != null && instrument.status != status) {
        return false;
      }
      
      // 검색 쿼리 필터
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return instrument.symbol.toLowerCase().contains(query) ||
               instrument.baseCode.toLowerCase().contains(query) ||
               instrument.quoteCode.toLowerCase().contains(query) ||
               (instrument.koreanName?.toLowerCase().contains(query) ?? false) ||
               (instrument.englishName?.toLowerCase().contains(query) ?? false);
      }
      
      return true;
    }).toList();
  }

  /// 특정 거래소의 심볼만 필터링하여 조회
  Future<List<Instrument>> loadInstrumentsByExchange(String exchange) async {
    try {
      final allInstruments = await loadInstruments();
      return allInstruments.where((instrument) => instrument.exchange == exchange).toList();
    } catch (e) {
      debugPrint('거래소별 심볼 정보 필터링 중 오류 발생: $e');
      return [];
    }
  }

  /// 심볼 검색
  Future<List<Instrument>> searchInstruments(String query) async {
    try {
      final allInstruments = await loadInstruments();
      final lowerQuery = query.toLowerCase();
      
      return allInstruments.where((instrument) {
        return instrument.symbol.toLowerCase().contains(lowerQuery) ||
               instrument.baseCode.toLowerCase().contains(lowerQuery) ||
               instrument.quoteCode.toLowerCase().contains(lowerQuery) ||
               (instrument.koreanName?.toLowerCase().contains(lowerQuery) ?? false) ||
               (instrument.englishName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      debugPrint('심볼 검색 중 오류 발생: $e');
      return [];
    }
  }

  /// 특정 카테고리의 심볼만 필터링하여 조회
  Future<List<Instrument>> loadInstrumentsByCategory(String category) async {
    try {
      final allInstruments = await loadInstruments();
      return allInstruments.where((instrument) => instrument.category == category).toList();
    } catch (e) {
      debugPrint('카테고리별 심볼 정보 필터링 중 오류 발생: $e');
      return [];
    }
  }

  /// 특정 거래소와 카테고리의 심볼만 필터링하여 조회
  Future<List<Instrument>> loadInstrumentsByExchangeAndCategory(String exchange, String category) async {
    try {
      final allInstruments = await loadInstruments();
      return allInstruments.where((instrument) => 
          instrument.exchange == exchange && instrument.category == category).toList();
    } catch (e) {
      debugPrint('거래소&카테고리별 심볼 정보 필터링 중 오류 발생: $e');
      return [];
    }
  }
}
