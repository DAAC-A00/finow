import '../models/ticker_price_data.dart';
import '../services/ticker_api_service.dart';
import '../../instruments/services/instruments_local_storage_service.dart';

/// 실시간 Ticker 데이터 레포지토리 (API + Instrument 데이터 통합)
/// ticker 데이터는 로컬 저장하지 않고 실시간으로만 사용
class TickerRepository {
  final TickerApiService _apiService;
  final InstrumentsLocalStorageService _instrumentsStorageService;

  TickerRepository({
    TickerApiService? apiService,
    InstrumentsLocalStorageService? instrumentsStorageService,
  })  : _apiService = apiService ?? TickerApiService(),
        _instrumentsStorageService = instrumentsStorageService ?? InstrumentsLocalStorageService();

  /// 실시간 ticker 데이터를 API에서 가져옴 (로컬 저장 없음)
  Future<List<TickerPriceData>> fetchLiveTickers() async {
    try {
      return await _apiService.getAllTickers();
    } catch (e) {
      throw Exception('실시간 Ticker 데이터 가져오기 중 오류: $e');
    }
  }

  /// 특정 카테고리의 실시간 ticker 데이터를 가져옴
  Future<List<TickerPriceData>> fetchLiveTickersByCategory(String category) async {
    try {
      return await _apiService.getTickersByCategory(category);
    } catch (e) {
      throw Exception('카테고리별 실시간 Ticker 데이터 가져오기 중 오류: $e');
    }
  }

  /// 특정 심볼의 실시간 ticker 데이터를 가져옴
  Future<TickerPriceData?> fetchLiveTickerBySymbol(String symbol, String category) async {
    try {
      final tickers = await _apiService.getTickersByCategory(category, symbol: symbol);
      return tickers.isNotEmpty ? tickers.first : null;
    } catch (e) {
      throw Exception('심볼별 실시간 Ticker 데이터 가져오기 중 오류: $e');
    }
  }

  /// Instrument 데이터와 실시간 Ticker 데이터를 통합하여 반환
  Future<List<IntegratedTickerPriceData>> getIntegratedLiveTickers() async {
    try {
      // 로컬에서 instrument 데이터 가져오기
      final instruments = await _instrumentsStorageService.loadInstruments();
      
      // API에서 실시간 ticker 데이터 가져오기
      final tickers = await _apiService.getAllTickers();
      
      
      // 빠른 조회를 위한 Map 생성
      final tickerMap = <String, TickerPriceData>{
        for (final ticker in tickers) ticker.symbol: ticker,
      };
      
      final integratedTickers = <IntegratedTickerPriceData>[];
      
      // Instrument 데이터를 기준으로 통합 (ticker 데이터가 없어도 포함)
      for (final instrument in instruments) {
        final tickerData = tickerMap[instrument.symbol];
        
        integratedTickers.add(IntegratedTickerPriceData(
          symbol: instrument.symbol,
          category: instrument.category ?? 'unknown',
          baseCoin: instrument.baseCoin,
          quoteCoin: instrument.quoteCoin,
          status: instrument.status,
          exchange: instrument.exchange,
          koreanName: instrument.koreanName,
          englishName: instrument.englishName,
          marketWarning: instrument.marketWarning,
          displayName: instrument.displayName,
          contractType: instrument.contractType,
          launchTime: instrument.launchTime,
          deliveryTime: instrument.deliveryTime,
          deliveryFeeRate: instrument.deliveryFeeRate,
          priceScale: instrument.priceScale,
          unifiedMarginTrade: instrument.unifiedMarginTrade,
          fundingInterval: instrument.fundingInterval,
          settleCoin: instrument.settleCoin,
          copyTrading: instrument.copyTrading,
          upperFundingRate: instrument.upperFundingRate,
          lowerFundingRate: instrument.lowerFundingRate,
          isPreListing: instrument.isPreListing,
          preListingInfo: instrument.preListingInfo,
          priceFilter: instrument.priceFilter,
          lotSizeFilter: instrument.lotSizeFilter,
          leverageFilter: instrument.leverageFilter,
          riskParameters: instrument.riskParameters,
          marginTrading: null, // ticker API에서 제공되는 정보
          innovation: null, // ticker API에서 제공되는 정보
          priceData: tickerData,
          lastUpdated: DateTime.now(),
        ));
      }
      
      return integratedTickers;
    } catch (e) {
      throw Exception('통합 실시간 Ticker 데이터 가져오기 중 오류: $e');
    }
  }

  /// 특정 카테고리의 통합 실시간 ticker 데이터를 가져옴
  Future<List<IntegratedTickerPriceData>> getIntegratedLiveTickersByCategory(String category) async {
    try {
      final allIntegratedTickers = await getIntegratedLiveTickers();
      return allIntegratedTickers
          .where((ticker) => ticker.category.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      throw Exception('카테고리별 통합 실시간 Ticker 데이터 가져오기 중 오류: $e');
    }
  }

  /// 특정 심볼의 통합 실시간 ticker 데이터를 가져옴
  Future<IntegratedTickerPriceData?> getIntegratedLiveTickerBySymbol(String symbol) async {
    try {
      final allIntegratedTickers = await getIntegratedLiveTickers();
      return allIntegratedTickers
          .where((ticker) => ticker.symbol == symbol)
          .firstOrNull;
    } catch (e) {
      throw Exception('심볼별 통합 실시간 Ticker 데이터 가져오기 중 오류: $e');
    }
  }

  /// 통합 실시간 ticker 데이터를 검색 조건에 따라 필터링
  Future<List<IntegratedTickerPriceData>> searchIntegratedLiveTickers({
    String? query,
    String? category,
    String? status,
  }) async {
    try {
      List<IntegratedTickerPriceData> tickers;
      
      if (category != null && category != 'all') {
        tickers = await getIntegratedLiveTickersByCategory(category);
      } else {
        tickers = await getIntegratedLiveTickers();
      }

      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        tickers = tickers.where((ticker) {
          return ticker.symbol.toLowerCase().contains(lowerQuery) ||
                 ticker.baseCoin.toLowerCase().contains(lowerQuery) ||
                 ticker.quoteCoin.toLowerCase().contains(lowerQuery) ||
                 (ticker.koreanName?.toLowerCase().contains(lowerQuery) ?? false) ||
                 (ticker.englishName?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }

      if (status != null && status != 'all') {
        tickers = tickers.where((ticker) => ticker.status == status).toList();
      }

      return tickers;
    } catch (e) {
      throw Exception('통합 실시간 Ticker 데이터 검색 중 오류: $e');
    }
  }
}
