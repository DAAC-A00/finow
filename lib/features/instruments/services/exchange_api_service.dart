import 'package:dio/dio.dart';
import '../models/instrument.dart';

import 'package:finow/features/settings/api_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 거래소 API 서비스 프로바이더
final exchangeApiServiceProvider = Provider<ExchangeApiService>((ref) {
  return ExchangeApiService();
});

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

  /// 재시도 로직이 포함된 API 호출 헬퍼
  Future<T> _retryApiCall<T>(
    Future<T> Function() apiCall,
    String exchangeName, {
    int maxRetries = 2,
    Duration delayBetweenRetries = const Duration(seconds: 2),
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final result = await apiCall();
        if (attempt > 0) {
          
        }
        return result;
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          
          rethrow;
        }
        
        
        await Future.delayed(delayBetweenRetries);
      }
    }
    
    throw Exception('$exchangeName API 호출 실패');
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
    return await _retryApiCall(
      () async {
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

                String integratedSymbol = '';
                String baseSymbol;
                if (parsedCoin['quantity'] != null && parsedCoin['quantity'] != 1.0) {
                  baseSymbol = '${parsedCoin['quantity']}${parsedCoin['baseCode']}/${instrument.quoteCode}';
                } else {
                  baseSymbol = '${parsedCoin['baseCode']}/${instrument.quoteCode}';
                }

                if (instrument.endDate != null && RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(instrument.endDate!)) {
                  integratedSymbol = '$baseSymbol-${instrument.endDate!.substring(2)}';
                } else {
                  integratedSymbol = baseSymbol;
                }

                return instrument.copyWith(
                  baseCode: parsedCoin['baseCode']!,
                  quantity: parsedCoin['quantity']!,
                  integratedSymbol: integratedSymbol,
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
      },
      'Bybit $category',
      maxRetries: 3, // Bybit은 페이지네이션이 있어서 조금 더 여유있게
    );
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
    return await _retryApiCall(
      () async {
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
            
            String integratedSymbol = '';
            String baseSymbol = '${instrument.baseCode}/${instrument.quoteCode}';

            // Bithumb은 perpetual이 없으므로 deliveryTime 체크는 필요 없음
            integratedSymbol = baseSymbol;

            // 경고 정보가 있다면 추가
            final warning = warningData[instrument.symbol];
            if (warning != null) {
              return instrument.copyWith(
                marketWarning: warning,
                integratedSymbol: integratedSymbol,
              );
            }
            
            return instrument.copyWith(integratedSymbol: integratedSymbol);
          }).toList();
        } else {
          throw Exception('Bithumb API 호출 실패: ${response.statusCode}');
        }
      },
      'Bithumb',
    );
  }

  /// Binance Spot 심볼 정보 조회 및 파싱
  Future<List<Instrument>> fetchBinanceSpotInstruments() async {
    return await _retryApiCall(
      () async {
        final response = await _dio.get('https://api.binance.com/api/v3/exchangeInfo');
        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> symbols = data['symbols'] ?? [];
          return symbols.map((item) => Instrument.fromBinanceSpot(item)).toList();
        } else {
          throw Exception('Binance Spot API 호출 실패: ${response.statusCode}');
        }
      },
      'Binance Spot',
    );
  }

  /// Binance USDⓈ-M 선물 심볼 정보 조회 및 파싱
  Future<List<Instrument>> fetchBinanceUmInstruments() async {
    return await _retryApiCall(
      () async {
        final response = await _dio.get('https://fapi.binance.com/fapi/v1/exchangeInfo');
        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> symbols = data['symbols'] ?? [];
          return symbols.map((item) => Instrument.fromBinanceUm(item)).toList();
        } else {
          throw Exception('Binance UM API 호출 실패: ${response.statusCode}');
        }
      },
      'Binance USDⓈ-M',
    );
  }

  /// Binance COIN-M 선물 심볼 정보 조회 및 파싱
  Future<List<Instrument>> fetchBinanceCmInstruments() async {
    return await _retryApiCall(
      () async {
        final response = await _dio.get('https://dapi.binance.com/dapi/v1/exchangeInfo');
        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> symbols = data['symbols'] ?? [];
          return symbols.map((item) => Instrument.fromBinanceCm(item)).toList();
        } else {
          throw Exception('Binance CM API 호출 실패: ${response.statusCode}');
        }
      },
      'Binance COIN-M',
    );
  }

  /// Bitget Spot 심볼 정보 조회 및 파싱
  Future<List<Instrument>> fetchBitgetSpotInstruments() async {
    return await _retryApiCall(
      () async {
        final response = await _dio.get('https://api.bitget.com/api/v3/market/instruments?category=SPOT');
        if (response.statusCode == 200) {
          final data = response.data;
          if (data['code'] == '00000') {
            final List<dynamic> symbols = data['data'] ?? [];
            return symbols.map((item) => Instrument.fromBitgetSpot(item)).toList();
          } else {
            throw Exception('Bitget Spot API 오류: ${data['msg']}');
          }
        } else {
          throw Exception('Bitget Spot API 호출 실패: ${response.statusCode}');
        }
      },
      'Bitget Spot',
    );
  }

  /// Bitget USDT-FUTURES 심볼 정보 조회 및 파싱
  Future<List<Instrument>> fetchBitgetUmInstruments() async {
    return await _retryApiCall(
      () async {
        final response = await _dio.get('https://api.bitget.com/api/v3/market/instruments?category=USDT-FUTURES');
        if (response.statusCode == 200) {
          final data = response.data;
          if (data['code'] == '00000') {
            final List<dynamic> symbols = data['data'] ?? [];
            return symbols.map((item) => Instrument.fromBitgetUm(item)).toList();
          } else {
            throw Exception('Bitget UM API 오류: ${data['msg']}');
          }
        } else {
          throw Exception('Bitget UM API 호출 실패: ${response.statusCode}');
        }
      },
      'Bitget USDT-FUTURES',
    );
  }

  /// Coinbase International Exchange 심볼 정보 조회 및 파싱
  Future<List<Instrument>> fetchCoinbaseInstruments() async {
    return await _retryApiCall(
      () async {
        final response = await _dio.get('https://api.international.coinbase.com/api/v1/instruments');
        if (response.statusCode == 200) {
          final List<dynamic> symbols = response.data ?? [];
          return symbols.map((item) => Instrument.fromCoinbase(item)).toList();
        } else {
          throw Exception('Coinbase API 호출 실패: ${response.statusCode}');
        }
      },
      'Coinbase',
    );
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

  /// 모든 거래소의 통합 심볼 정보 조회 (오류 허용)
  Future<List<Instrument>> fetchAllInstruments({Function(String, ApiStatus)? onStatusUpdate}) async {
    final List<Instrument> allInstruments = [];
    
    // 각 거래소별로 개별 처리하여 일부 실패해도 나머지는 계속 진행
    final exchangeOperations = [
      () async {
        try {
          final instruments = await fetchBybitInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Bybit Spot', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Bybit Spot', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBybitLinearInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Bybit Linear', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Bybit Linear', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBybitInverseInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Bybit Inverse', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Bybit Inverse', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBithumbInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Bithumb', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Bithumb', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBinanceSpotInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Binance Spot', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Binance Spot', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBinanceUmInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Binance USDⓈ-M', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Binance USDⓈ-M', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBinanceCmInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Binance COIN-M', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Binance COIN-M', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBitgetSpotInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Bitget Spot', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Bitget Spot', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchBitgetUmInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Bitget USDT-FUTURES', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Bitget USDT-FUTURES', ApiStatus.failure);
        }
      },
      () async {
        try {
          final instruments = await fetchCoinbaseInstruments();
          allInstruments.addAll(instruments);
          
          onStatusUpdate?.call('Coinbase', ApiStatus.success);
        } catch (e) {
          
          onStatusUpdate?.call('Coinbase', ApiStatus.failure);
        }
      },
    ];
    
    // 모든 작업을 병렬로 실행
    await Future.wait(exchangeOperations.map((operation) => operation()));
    
    
    return allInstruments;
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