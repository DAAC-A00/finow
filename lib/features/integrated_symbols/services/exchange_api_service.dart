import 'package:dio/dio.dart';
import '../models/integrated_instrument.dart';

/// 거래소 API 서비스 (Dio 기반)
class ExchangeApiService {
  static const String _bybitBaseUrl = 'https://api.bybit.com/v5';
  static const String _bithumbBaseUrl = 'https://api.bithumb.com/v1';
  
  late final Dio _dio;
  
  ExchangeApiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Bybit 스팟 거래 심볼 정보 조회
  Future<List<IntegratedInstrument>> fetchBybitInstruments() async {
    try {
      final response = await _dio.get(
        '$_bybitBaseUrl/market/instruments-info',
        queryParameters: {'category': 'spot'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['retCode'] == 0 && data['result'] != null) {
          final List<dynamic> instruments = data['result']['list'] ?? [];
          
          return instruments
              .map((item) => IntegratedInstrument.fromBybit(item))
              .toList();
        } else {
          throw Exception('Bybit API 오류: ${data['retMsg']}');
        }
      } else {
        throw Exception('Bybit API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Bybit API 호출 중 네트워크 오류: ${e.message}');
      }
      throw Exception('Bybit 데이터 조회 중 오류 발생: $e');
    }
  }

  /// Bithumb 마켓 정보 조회
  Future<List<IntegratedInstrument>> fetchBithumbInstruments() async {
    try {
      final response = await _dio.get(
        '$_bithumbBaseUrl/market/all',
        queryParameters: {'isDetails': 'true'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        
        // 경고 정보도 함께 조회
        final warningData = await _fetchBithumbWarnings();
        
        return data.map((item) {
          final instrument = IntegratedInstrument.fromBithumb(item);
          
          // 경고 정보가 있다면 추가
          final warning = warningData[instrument.symbol];
          if (warning != null) {
            return IntegratedInstrument(
              symbol: instrument.symbol,
              baseCoin: instrument.baseCoin,
              quoteCoin: instrument.quoteCoin,
              exchange: instrument.exchange,
              status: instrument.status,
              koreanName: instrument.koreanName,
              englishName: instrument.englishName,
              marketWarning: warning,
              lastUpdated: instrument.lastUpdated,
            );
          }
          
          return instrument;
        }).toList();
      } else {
        throw Exception('Bithumb API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Bithumb API 호출 중 네트워크 오류: ${e.message}');
      }
      throw Exception('Bithumb 데이터 조회 중 오류 발생: $e');
    }
  }

  /// Bithumb 경고 정보 조회
  Future<Map<String, String>> _fetchBithumbWarnings() async {
    try {
      final response = await _dio.get(
        '$_bithumbBaseUrl/market/virtual_asset_warning',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final Map<String, String> warnings = {};
        
        for (final item in data) {
          final market = item['market'];
          final warningType = item['warning_type'];
          if (market != null && warningType != null) {
            warnings[market] = warningType;
          }
        }
        
        return warnings;
      }
      
      return {};
    } catch (e) {
      // 경고 정보 조회 실패는 무시하고 빈 맵 반환
      return {};
    }
  }

  /// 모든 거래소의 통합 심볼 정보 조회
  Future<List<IntegratedInstrument>> fetchAllInstruments() async {
    try {
      final futures = await Future.wait([
        fetchBybitInstruments(),
        fetchBithumbInstruments(),
      ]);

      final List<IntegratedInstrument> allInstruments = [];
      
      for (final instruments in futures) {
        allInstruments.addAll(instruments);
      }

      return allInstruments;
    } catch (e) {
      throw Exception('통합 심볼 정보 조회 중 오류 발생: $e');
    }
  }
}
