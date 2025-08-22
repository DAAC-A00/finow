import 'package:dio/dio.dart';
import '../models/instrument.dart';

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

  Map<String, dynamic> _parseBaseCode(String baseCodeStr) {
    // Try parsing as $quantity$baseCode (e.g., "1000BTC")
    RegExp quantityPrefixRegExp = RegExp(r'^(\d+)(.*)$');
    Match? match = quantityPrefixRegExp.firstMatch(baseCodeStr);

    if (match != null) {
      String quantityStr = match.group(1)!;
      String coin = match.group(2)!;
      final quantity = int.tryParse(quantityStr);
      if (quantity != null && quantity % 1000 == 0) {
        return {
          'quantity': quantity.toDouble(),
          'baseCode': coin,
        };
      }
    }

    // If not \$quantity\$baseCode or quantity not a multiple of 1000,
    // try parsing as $baseCode$quantity (e.g., "BTC1000")
    RegExp quantitySuffixRegExp = RegExp(r'^(.*?)(\d+)$');
    match = quantitySuffixRegExp.firstMatch(baseCodeStr);

    if (match != null) {
      String coin = match.group(1)!;
      String quantityStr = match.group(2)!;
      final quantity = int.tryParse(quantityStr);
      if (quantity != null && quantity % 1000 == 0) {
        return {
          'quantity': quantity.toDouble(),
          'baseCode': coin,
        };
      }
    }

    // Default case if no specific quantity pattern is found or valid
    return {
      'quantity': 1.0,
      'baseCode': baseCodeStr,
    };
  }

  /// Bybit 특정 카테고리 거래 심볼 정보 조회 (모든 페이지)
  Future<List<Instrument>> fetchBybitInstrumentsByCategory(String category) async {
    try {
      final List<Instrument> allInstruments = [];
      String? nextCursor;
      
      do {
        final queryParams = {'category': category};
        if (nextCursor != null) {
          queryParams['cursor'] = nextCursor;
        }
        
        final response = await _dio.get(
          '$_bybitBaseUrl/market/instruments-info',
          queryParameters: queryParams,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          
          if (data['retCode'] == 0 && data['result'] != null) {
            final List<dynamic> instruments = data['result']['list'] ?? [];
            final resultCategory = data['result']['category'] ?? category; // API에서 반환하는 category 사용
            nextCursor = data['result']['nextPageCursor'];
            
            // 빈 커서면 null로 처리
            if (nextCursor != null && nextCursor.isEmpty) {
              nextCursor = null;
            }
            
            final mappedInstruments = instruments.map((item) {
              final instrument = Instrument.fromBybit(item, category: resultCategory);
              final parsedCoin = _parseBaseCode(instrument.baseCode);
              return instrument.copyWith(
                baseCode: parsedCoin['baseCode']!,
                quantity: parsedCoin['quantity']!,
              );
            }).toList();
                
            allInstruments.addAll(mappedInstruments);
          } else {
            throw Exception('Bybit API 오류: ${data['retMsg']}');
          }
        } else {
          throw Exception('Bybit API 호출 실패: ${response.statusCode}');
        }
      } while (nextCursor != null);
      
      
      return allInstruments;
    } catch (e) {
      if (e is DioException) {
        throw Exception('Bybit API 호출 중 네트워크 오류: ${e.message}');
      }
      throw Exception('Bybit 데이터 조회 중 오류 발생: $e');
    }
  }

  /// Bybit 스팟 거래 심볼 정보 조회 (하위 호환성)
  Future<List<Instrument>> fetchBybitInstruments() async {
    return await fetchBybitInstrumentsByCategory('spot');
  }

  /// Bybit 선물 거래 심볼 정보 조회 (Linear)
  Future<List<Instrument>> fetchBybitLinearInstruments() async {
    return await fetchBybitInstrumentsByCategory('linear');
  }

  /// Bybit 역선물 거래 심볼 정보 조회 (Inverse)
  Future<List<Instrument>> fetchBybitInverseInstruments() async {
    return await fetchBybitInstrumentsByCategory('inverse');
  }

  /// Bithumb 마켓 정보 조회
  Future<List<Instrument>> fetchBithumbInstruments() async {
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
          final instrument = Instrument.fromBithumb(item);
          
          // 경고 정보가 있다면 추가
          final warning = warningData[instrument.symbol];
          if (warning != null) {
            return instrument.copyWith(
              marketWarning: warning,
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
  Future<List<Instrument>> fetchAllInstruments() async {
    try {
      final futures = await Future.wait([
        fetchBybitInstruments(), // spot
        fetchBybitLinearInstruments(), // linear
        fetchBybitInverseInstruments(), // inverse
        fetchBithumbInstruments(),
      ]);

      final List<Instrument> allInstruments = [];
      
      for (final instruments in futures) {
        allInstruments.addAll(instruments);
      }

      return allInstruments;
    } catch (e) {
      throw Exception('통합 심볼 정보 조회 중 오류 발생: $e');
    }
  }

  /// 모든 Bybit category 심볼 정보 조회
  Future<List<Instrument>> fetchAllBybitInstruments() async {
    try {
      final futures = await Future.wait([
        fetchBybitInstruments(), // spot
        fetchBybitLinearInstruments(), // linear
        fetchBybitInverseInstruments(), // inverse
      ]);

      final List<Instrument> allInstruments = [];
      
      for (final instruments in futures) {
        allInstruments.addAll(instruments);
      }

      return allInstruments;
    } catch (e) {
      throw Exception('Bybit 통합 심볼 정보 조회 중 오류 발생: $e');
    }
  }
}