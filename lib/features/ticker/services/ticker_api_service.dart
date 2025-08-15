import 'package:dio/dio.dart';
import '../models/ticker_price_data.dart';

/// 실시간 Ticker 가격 API 서비스 클래스
/// Bybit의 Ticker API를 호출하여 실시간 시세 정보를 가져옵니다.
class TickerApiService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.bybit.com/v5';

  TickerApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Spot 카테고리의 실시간 Ticker 데이터를 가져옵니다.
  /// 
  /// [symbol]: 특정 심볼만 조회할 경우 (선택사항)
  Future<List<TickerPriceData>> getSpotTickers({String? symbol}) async {
    try {
      final queryParams = <String, dynamic>{
        'category': 'spot',
      };

      if (symbol != null && symbol.isNotEmpty) {
        queryParams['symbol'] = symbol;
      }

      final response = await _dio.get(
        '/market/tickers',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['retCode'] == 0 && data['result'] != null) {
          final List<dynamic> tickerList = data['result']['list'] ?? [];
          return tickerList
              .map((json) => TickerPriceData.fromSpot(json))
              .toList();
        } else {
          throw Exception('API Error: ${data['retMsg'] ?? 'Unknown error'}');
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch spot tickers: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'getSpotTickers');
    } catch (e) {
      throw Exception('Unexpected error in getSpotTickers: $e');
    }
  }

  /// Linear 카테고리의 실시간 Ticker 데이터를 가져옵니다.
  /// 
  /// [symbol]: 특정 심볼만 조회할 경우 (선택사항)
  Future<List<TickerPriceData>> getLinearTickers({String? symbol}) async {
    try {
      final queryParams = <String, dynamic>{
        'category': 'linear',
      };

      if (symbol != null && symbol.isNotEmpty) {
        queryParams['symbol'] = symbol;
      }

      final response = await _dio.get(
        '/market/tickers',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['retCode'] == 0 && data['result'] != null) {
          final List<dynamic> tickerList = data['result']['list'] ?? [];
          return tickerList
              .map((json) => TickerPriceData.fromLinear(json))
              .toList();
        } else {
          throw Exception('API Error: ${data['retMsg'] ?? 'Unknown error'}');
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch linear tickers: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'getLinearTickers');
    } catch (e) {
      throw Exception('Unexpected error in getLinearTickers: $e');
    }
  }

  /// Inverse 카테고리의 실시간 Ticker 데이터를 가져옵니다.
  /// 
  /// [symbol]: 특정 심볼만 조회할 경우 (선택사항)
  Future<List<TickerPriceData>> getInverseTickers({String? symbol}) async {
    try {
      final queryParams = <String, dynamic>{
        'category': 'inverse',
      };

      if (symbol != null && symbol.isNotEmpty) {
        queryParams['symbol'] = symbol;
      }

      final response = await _dio.get(
        '/market/tickers',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['retCode'] == 0 && data['result'] != null) {
          final List<dynamic> tickerList = data['result']['list'] ?? [];
          return tickerList
              .map((json) => TickerPriceData.fromInverse(json))
              .toList();
        } else {
          throw Exception('API Error: ${data['retMsg'] ?? 'Unknown error'}');
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch inverse tickers: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'getInverseTickers');
    } catch (e) {
      throw Exception('Unexpected error in getInverseTickers: $e');
    }
  }

  /// 모든 카테고리의 실시간 Ticker 데이터를 가져옵니다.
  /// 
  /// [symbols]: 특정 심볼들만 조회할 경우 (선택사항)
  Future<List<TickerPriceData>> getAllTickers({List<String>? symbols}) async {
    try {
      final futures = <Future<List<TickerPriceData>>>[
        getSpotTickers(symbol: symbols?.join(',')),
        getLinearTickers(symbol: symbols?.join(',')),
        getInverseTickers(symbol: symbols?.join(',')),
      ];

      final responses = await Future.wait(futures);
      final allTickers = <TickerPriceData>[];

      for (final tickerList in responses) {
        allTickers.addAll(tickerList);
      }

      return allTickers;
    } catch (e) {
      throw Exception('Failed to fetch all tickers: $e');
    }
  }

  /// 특정 카테고리의 실시간 Ticker 데이터를 가져옵니다.
  /// 
  /// [category]: 카테고리 ('spot', 'linear', 'inverse')
  /// [symbol]: 특정 심볼만 조회할 경우
  Future<List<TickerPriceData>> getTickersByCategory(
    String category, {
    String? symbol,
  }) async {
    switch (category.toLowerCase()) {
      case 'spot':
        return getSpotTickers(symbol: symbol);
      case 'linear':
        return getLinearTickers(symbol: symbol);
      case 'inverse':
        return getInverseTickers(symbol: symbol);
      default:
        throw ArgumentError('Invalid category: $category');
    }
  }

  /// DioException을 처리하고 적절한 에러 메시지를 생성합니다.
  Exception _handleDioException(DioException e, String methodName) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('$methodName: Connection timeout');
      case DioExceptionType.sendTimeout:
        return Exception('$methodName: Send timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('$methodName: Receive timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['retMsg'] ?? 'Unknown error';
        return Exception('$methodName: HTTP $statusCode - $message');
      case DioExceptionType.cancel:
        return Exception('$methodName: Request cancelled');
      case DioExceptionType.connectionError:
        return Exception('$methodName: Connection error - ${e.message}');
      default:
        return Exception('$methodName: ${e.message}');
    }
  }
}
