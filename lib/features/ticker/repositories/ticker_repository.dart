
import 'package:finow/features/ticker/data/models/bithumb_ticker_model.dart';
import '../models/ticker_price_data.dart';
import '../services/ticker_api_service.dart';
import '../../instruments/services/instruments_local_storage_service.dart';

/// 실시간 Ticker 데이터 레포지토리 (API + Instrument 데이터 통합)
class TickerRepository {
  final TickerApiService _apiService;
  final InstrumentsLocalStorageService _instrumentsStorageService;

  TickerRepository({
    TickerApiService? apiService,
    InstrumentsLocalStorageService? instrumentsStorageService,
  })  : _apiService = apiService ?? TickerApiService(),
        _instrumentsStorageService =
            instrumentsStorageService ?? InstrumentsLocalStorageService();

  /// Instrument 데이터와 실시간 Ticker 데이터를 통합하여 반환
  Future<List<IntegratedTickerPriceData>> getIntegratedLiveTickers() async {
    try {
      // 로컬에서 모든 instrument 데이터 가져오기
      final instruments = await _instrumentsStorageService.loadInstruments();
      final instrumentMap = {for (var inst in instruments) inst.symbol: inst};

      // API에서 Bybit과 Bithumb ticker 데이터 병렬로 가져오기
      final results = await Future.wait([
        _apiService.getAllTickers(), // Bybit tickers
        _apiService.fetchBithumbTickers(), // Bithumb tickers
      ]);

      final bybitTickers = results[0] as List<TickerPriceData>;
      final bithumbTickers = results[1] as List<BithumbTicker>;

      // Bybit Ticker를 Map으로 변환
      final bybitTickerMap = <String, TickerPriceData>{
        for (final ticker in bybitTickers) ticker.symbol: ticker,
      };

      // Bithumb Ticker를 IntegratedTickerPriceData로 변환
      final List<IntegratedTickerPriceData> bithumbIntegrated = bithumbTickers
          .map((bithumbTicker) {
            final instrument = instrumentMap[bithumbTicker.market];
            final priceData = TickerPriceData(
              symbol: bithumbTicker.market ?? '',
              category: 'spot',
              lastPrice: bithumbTicker.closingPrice,
              prevPrice24h: bithumbTicker.prevClosingPrice,
              price24hPcnt: bithumbTicker.fluctuateRate24H,
              highPrice24h: bithumbTicker.maxPrice,
              lowPrice24h: bithumbTicker.minPrice,
              turnover24h: bithumbTicker.accTradeValue24H,
              volume24h: bithumbTicker.unitsTraded24H,
              lastUpdated: DateTime.now(),
            );

            return IntegratedTickerPriceData(
              symbol: bithumbTicker.market ?? '',
              category: 'spot',
              baseCode: instrument?.baseCode ??
                  bithumbTicker.market?.split('-').last ??
                  '',
                                quoteCode: instrument?.quoteCode ?? '',
              status: instrument?.status ?? 'Trading',
              exchange: 'bithumb',
              koreanName: instrument?.koreanName,
              englishName: instrument?.englishName,
              priceData: priceData,
              lastUpdated: DateTime.now(),
            );
          })
          .toList();

      final integratedTickers = <IntegratedTickerPriceData>[];

      // Bybit Instrument 데이터를 기준으로 통합
      for (final instrument in instruments) {
        if (instrument.exchange != 'bithumb') {
          final tickerData = bybitTickerMap[instrument.symbol];
          final parsedCoin = _parseBaseCode(instrument.baseCode);

          integratedTickers.add(IntegratedTickerPriceData(
            symbol: instrument.symbol,
            category: instrument.category ?? 'unknown',
            baseCode: parsedCoin['baseCode']!,
            quoteCode: instrument.quoteCode,
            quantity: parsedCoin['quantity']!,
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
            marginTrading: null,
            innovation: null,
            priceData: tickerData,
            lastUpdated: DateTime.now(),
          ));
        }
      }

      // 두 리스트를 합침
      integratedTickers.addAll(bithumbIntegrated);

      return integratedTickers;
    } catch (e) {
      throw Exception('통합 실시간 Ticker 데이터 가져오기 중 오류: $e');
    }
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
}
