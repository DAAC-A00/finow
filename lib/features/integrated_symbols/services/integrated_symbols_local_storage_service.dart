import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/integrated_instrument.dart';
import 'package:flutter/foundation.dart';

/// 통합 심볼 정보 로컬 스토리지 관리 서비스 (Hive 기반)
class IntegratedSymbolsLocalStorageService {
  static const String _boxName = 'integrated_instruments';
  static const String _instrumentsKey = 'instruments_data';
  static const String _lastUpdateKey = 'last_update_time';

  /// Hive Box 가져오기 (없으면 생성)
  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  /// 통합 심볼 정보를 Hive Box에 저장
  Future<void> saveIntegratedInstruments(List<IntegratedInstrument> instruments) async {
    try {
      final box = await _getBox();
      
      // 심볼 정보를 JSON 문자열로 변환하여 저장
      final jsonList = instruments.map((instrument) => instrument.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await box.put(_instrumentsKey, jsonString);
      await box.put(_lastUpdateKey, DateTime.now().toIso8601String());
      
      debugPrint('통합 심볼 정보 저장 완료: ${instruments.length}개 항목');
    } catch (e) {
      throw Exception('통합 심볼 정보 저장 중 오류 발생: $e');
    }
  }

  /// Hive Box에서 통합 심볼 정보 불러오기
  Future<List<IntegratedInstrument>> loadIntegratedInstruments() async {
    try {
      final box = await _getBox();
      final jsonString = box.get(_instrumentsKey) as String?;
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final instruments = jsonList
          .map((json) => IntegratedInstrument.fromJson(json))
          .toList();
      
      debugPrint('통합 심볼 정보 불러오기 완료: ${instruments.length}개 항목');
      return instruments;
    } catch (e) {
      debugPrint('통합 심볼 정보 불러오기 중 오류 발생: $e');
      return [];
    }
  }

  /// 마지막 업데이트 시간 조회
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final box = await _getBox();
      final lastUpdateString = box.get(_lastUpdateKey) as String?;
      
      if (lastUpdateString != null) {
        return DateTime.parse(lastUpdateString);
      }
      
      return null;
    } catch (e) {
      debugPrint('마지막 업데이트 시간 조회 중 오류 발생: $e');
      return null;
    }
  }

  /// 저장된 데이터가 있는지 확인
  Future<bool> hasStoredData() async {
    try {
      final box = await _getBox();
      final jsonString = box.get(_instrumentsKey) as String?;
      return jsonString != null && jsonString.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 저장된 데이터 삭제
  Future<void> clearStoredData() async {
    try {
      final box = await _getBox();
      await box.delete(_instrumentsKey);
      await box.delete(_lastUpdateKey);
      debugPrint('저장된 통합 심볼 정보 삭제 완료');
    } catch (e) {
      throw Exception('저장된 데이터 삭제 중 오류 발생: $e');
    }
  }

  /// 특정 거래소의 심볼만 필터링하여 조회
  Future<List<IntegratedInstrument>> loadInstrumentsByExchange(String exchange) async {
    try {
      final allInstruments = await loadIntegratedInstruments();
      return allInstruments.where((instrument) => instrument.exchange == exchange).toList();
    } catch (e) {
      debugPrint('거래소별 심볼 정보 필터링 중 오류 발생: $e');
      return [];
    }
  }

  /// 심볼 검색
  Future<List<IntegratedInstrument>> searchInstruments(String query) async {
    try {
      final allInstruments = await loadIntegratedInstruments();
      final lowerQuery = query.toLowerCase();
      
      return allInstruments.where((instrument) {
        return instrument.symbol.toLowerCase().contains(lowerQuery) ||
               instrument.baseCoin.toLowerCase().contains(lowerQuery) ||
               instrument.quoteCoin.toLowerCase().contains(lowerQuery) ||
               (instrument.koreanName?.toLowerCase().contains(lowerQuery) ?? false) ||
               (instrument.englishName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      debugPrint('심볼 검색 중 오류 발생: $e');
      return [];
    }
  }
}
