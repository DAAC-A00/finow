import 'package:dio/dio.dart';
import 'package:finow/features/instruments/services/exchange_api_service.dart';
import 'package:finow/features/instruments/services/instruments_local_storage_service.dart';
import 'package:flutter/foundation.dart';
import '../data/models/bithumb_ticker_model.dart';
import '../models/ticker_price_data.dart';

/// 실시간 Ticker 가격 API 서비스 클래스
/// Bybit과 Bithumb의 Ticker API를 호출하여 실시간 시세 정보를 가져옵니다.
class TickerApiService {
  final Dio _dio;
  final InstrumentsLocalStorageService _localStorageService;
  final ExchangeApiService _exchangeApiService;

  static const String _bybitBaseUrl = 'https://api.bybit.com/v5';
  // Bithumb Public API는 CORS 문제가 없으므로 프록시 제거
  static const String _bithumbBaseUrl = 'https://api.bithumb.com';

  TickerApiService({
    Dio? dio,
    InstrumentsLocalStorageService? localStorageService,
    ExchangeApiService? exchangeApiService,
  })  : _dio = dio ?? Dio(),
        _localStorageService =
            localStorageService ?? InstrumentsLocalStorageService(),
        _exchangeApiService = exchangeApiService ?? ExchangeApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Bithumb의 실시간 Ticker 데이터를 가져옵니다. (ALL_KRW, ALL_BTC 통합)
  Future<List<BithumbTicker>> fetchBithumbTickers() async {
    try {

      // KRW와 BTC 마켓 동시 호출
      final responses = await Future.wait([
        _dio.get('$_bithumbBaseUrl/public/ticker/ALL_KRW'),
        _dio.get('$_bithumbBaseUrl/public/ticker/ALL_BTC'),
      ]);

      final List<BithumbTicker> allTickers = [];

      // KRW 마켓 데이터 파싱
      if (responses[0].statusCode == 200) {
        allTickers.addAll(_parseBithumbTickerResponse(responses[0].data, 'KRW'));
      }

      // BTC 마켓 데이터 파싱
      if (responses[1].statusCode == 200) {
        allTickers.addAll(_parseBithumbTickerResponse(responses[1].data, 'BTC'));
      }

      return allTickers;
    } on DioException catch (e) {
      debugPrint('[BithumbTicker] DioException: ${e.toString()}');
      throw Exception(
          'Network error while fetching Bithumb tickers: ${e.message}');
    } catch (e) {
      debugPrint('[BithumbTicker] Unexpected error: ${e.toString()}');
      throw Exception('Unexpected error in fetchBithumbTickers: $e');
    }
  }

  List<BithumbTicker> _parseBithumbTickerResponse(
      dynamic responseData, String quoteCurrency) {
    if (responseData['status'] != '0000') {
      return [];
    }

    final data = responseData['data'] as Map<String, dynamic>;
    final List<BithumbTicker> tickers = [];

    data.forEach((key, value) {
      if (key == 'date') return; // 날짜 정보는 제외

      final tickerData = value as Map<String, dynamic>;
      // BithumbTicker 모델의 fromJson이 market 필드를 요구하지 않으므로, market 필드를 수동으로 채워줍니다.
      final ticker = BithumbTicker.fromJson(tickerData);
      ticker.market = '$quoteCurrency-$key'; // 마켓 심볼 수동 설정 (예: KRW-BTC)
      tickers.add(ticker);
    });
    return tickers;
  }

  /// Spot 카테고리의 실시간 Ticker 데이터를 가져옵니다.
  Future<List<TickerPriceData>> getSpotTickers({String? symbol}) async {
    try {
      final queryParams = <String, dynamic>{
        'category': 'spot',
      };

      if (symbol != null && symbol.isNotEmpty) {
        queryParams['symbol'] = symbol;
      }

      final response = await _dio.get(
        '$_bybitBaseUrl/market/tickers',
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
  Future<List<TickerPriceData>> getLinearTickers({String? symbol}) async {
    try {
      final queryParams = <String, dynamic>{
        'category': 'linear',
      };

      if (symbol != null && symbol.isNotEmpty) {
        queryParams['symbol'] = symbol;
      }

      final response = await _dio.get(
        '$_bybitBaseUrl/market/tickers',
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
  Future<List<TickerPriceData>> getInverseTickers({String? symbol}) async {
    try {
      final queryParams = <String, dynamic>{
        'category': 'inverse',
      };

      if (symbol != null && symbol.isNotEmpty) {
        queryParams['symbol'] = symbol;
      }

      final response = await _dio.get(
        '$_bybitBaseUrl/market/tickers',
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
