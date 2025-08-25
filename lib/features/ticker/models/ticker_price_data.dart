import '../../instruments/models/instrument.dart';
import 'package:finow/features/ticker/data/models/bithumb_ticker_model.dart';

/// 실시간 Ticker 가격 정보 모델 (로컬 저장 없음)
class TickerPriceData {
  final String symbol;
  final String category; // 'spot', 'linear', 'inverse'
  
  // 공통 필드
  final String? lastPrice;
  final String? prevPrice24h;
  final String? price24hPcnt;
  final String? highPrice24h;
  final String? lowPrice24h;
  final String? turnover24h;
  final String? volume24h;
  
  // Spot 전용 필드
  final String? bid1Price;
  final String? bid1Size;
  final String? ask1Price;
  final String? ask1Size;
  
  // Linear/Inverse 전용 필드
  final String? indexPrice;
  final String? markPrice;
  final String? prevPrice1h;
  final String? openInterest;
  final String? openInterestValue;
  final String? fundingRate;
  final String? nextFundingTime;
  final String? predictedDeliveryPrice;
  final String? basisRate;
  final String? deliveryFeeRate;
  final String? deliveryTime;
  final String? basis;
  final String? preOpenPrice;
  final String? preQty;
  final String? curPreListingPhase;
  
  final DateTime lastUpdated;

  const TickerPriceData({
    required this.symbol,
    required this.category,
    this.lastPrice,
    this.prevPrice24h,
    this.price24hPcnt,
    this.highPrice24h,
    this.lowPrice24h,
    this.turnover24h,
    this.volume24h,
    this.bid1Price,
    this.bid1Size,
    this.ask1Price,
    this.ask1Size,
    this.indexPrice,
    this.markPrice,
    this.prevPrice1h,
    this.openInterest,
    this.openInterestValue,
    this.fundingRate,
    this.nextFundingTime,
    this.predictedDeliveryPrice,
    this.basisRate,
    this.deliveryFeeRate,
    this.deliveryTime,
    this.basis,
    this.preOpenPrice,
    this.preQty,
    this.curPreListingPhase,
    required this.lastUpdated,
  });

  /// Bybit API의 price24hPcnt 값을 조정하는 헬퍼 함수
  static String? _adjustBybitPriceChangePercent(String? price24hPcnt) {
    if (price24hPcnt == null || price24hPcnt.isEmpty) return null;
    try {
      final parsedValue = double.parse(price24hPcnt);
      return (parsedValue * 100).toStringAsFixed(2);
    } catch (e) {
      // 파싱 실패 시 원본 값 반환
      return price24hPcnt;
    }
  }

  /// Spot 카테고리용 팩토리 생성자
  factory TickerPriceData.fromSpot(Map<String, dynamic> json) {
    return TickerPriceData(
      symbol: json['symbol'] ?? '',
      category: 'spot',
      lastPrice: json['lastPrice'],
      prevPrice24h: json['prevPrice24h'],
      price24hPcnt: _adjustBybitPriceChangePercent(json['price24hPcnt']),
      highPrice24h: json['highPrice24h'],
      lowPrice24h: json['lowPrice24h'],
      turnover24h: json['turnover24h'],
      volume24h: json['volume24h'],
      bid1Price: json['bid1Price'],
      bid1Size: json['bid1Size'],
      ask1Price: json['ask1Price'],
      ask1Size: json['ask1Size'],
      lastUpdated: DateTime.now(),
    );
  }

  /// Linear 카테고리용 팩토리 생성자
  factory TickerPriceData.fromLinear(Map<String, dynamic> json) {
    return TickerPriceData(
      symbol: json['symbol'] ?? '',
      category: 'linear',
      lastPrice: json['lastPrice'],
      prevPrice24h: json['prevPrice24h'],
      price24hPcnt: _adjustBybitPriceChangePercent(json['price24hPcnt']),
      highPrice24h: json['highPrice24h'],
      lowPrice24h: json['lowPrice24h'],
      turnover24h: json['turnover24h'],
      volume24h: json['volume24h'],
      indexPrice: json['indexPrice'],
      markPrice: json['markPrice'],
      prevPrice1h: json['prevPrice1h'],
      openInterest: json['openInterest'],
      openInterestValue: json['openInterestValue'],
      fundingRate: json['fundingRate'],
      nextFundingTime: json['nextFundingTime'],
      predictedDeliveryPrice: json['predictedDeliveryPrice'],
      basisRate: json['basisRate'],
      deliveryFeeRate: json['deliveryFeeRate'],
      deliveryTime: json['deliveryTime'],
      ask1Size: json['ask1Size'],
      bid1Price: json['bid1Price'],
      ask1Price: json['ask1Price'],
      bid1Size: json['bid1Size'],
      basis: json['basis'],
      preOpenPrice: json['preOpenPrice'],
      preQty: json['preQty'],
      curPreListingPhase: json['curPreListingPhase'],
      lastUpdated: DateTime.now(),
    );
  }

  /// Inverse 카테고리용 팩토리 생성자
  factory TickerPriceData.fromInverse(Map<String, dynamic> json) {
    return TickerPriceData(
      symbol: json['symbol'] ?? '',
      category: 'inverse',
      lastPrice: json['lastPrice'],
      prevPrice24h: json['prevPrice24h'],
      price24hPcnt: _adjustBybitPriceChangePercent(json['price24hPcnt']),
      highPrice24h: json['highPrice24h'],
      lowPrice24h: json['lowPrice24h'],
      turnover24h: json['turnover24h'],
      volume24h: json['volume24h'],
      indexPrice: json['indexPrice'],
      markPrice: json['markPrice'],
      prevPrice1h: json['prevPrice1h'],
      openInterest: json['openInterest'],
      openInterestValue: json['openInterestValue'],
      fundingRate: json['fundingRate'],
      nextFundingTime: json['nextFundingTime'],
      predictedDeliveryPrice: json['predictedDeliveryPrice'],
      basisRate: json['basisRate'],
      deliveryFeeRate: json['deliveryFeeRate'],
      deliveryTime: json['deliveryTime'],
      ask1Size: json['ask1Size'],
      bid1Price: json['bid1Price'],
      ask1Price: json['ask1Price'],
      bid1Size: json['bid1Size'],
      basis: json['basis'],
      preOpenPrice: json['preOpenPrice'],
      preQty: json['preQty'],
      curPreListingPhase: json['curPreListingPhase'],
      lastUpdated: DateTime.now(),
    );
  }

  /// Bithumb API의 price24hPcnt 값을 조정하는 헬퍼 함수
  static String? _formatBithumbPriceChangePercent(String? price24hPcnt) {
    if (price24hPcnt == null || price24hPcnt.isEmpty) return null;
    try {
      final parsedValue = double.parse(price24hPcnt);
      return parsedValue.toStringAsFixed(2);
    } catch (e) {
      // 파싱 실패 시 원본 값 반환
      return price24hPcnt;
    }
  }

  factory TickerPriceData.fromBithumbTicker(BithumbTicker ticker) {
    return TickerPriceData(
      symbol: ticker.market ?? '',
      category: 'spot',
      lastPrice: ticker.closingPrice,
      prevPrice24h: ticker.prevClosingPrice,
      price24hPcnt: _formatBithumbPriceChangePercent(ticker.fluctuateRate24H),
      highPrice24h: ticker.maxPrice,
      lowPrice24h: ticker.minPrice,
      turnover24h: ticker.accTradeValue24H,
      volume24h: ticker.unitsTraded24H,
      lastUpdated: DateTime.now(),
    );
  }

  /// 가격 변화율을 double로 반환 (퍼센트)
  double? get priceChangePercent {
    if (price24hPcnt == null) return null;
    return double.tryParse(price24hPcnt!) ?? 0.0;
  }

  /// 가격 변화 방향 (상승/하락/보합)
  PriceDirection get priceDirection {
    final changePercent = priceChangePercent;
    if (changePercent == null) return PriceDirection.neutral;
    if (changePercent > 0) return PriceDirection.up;
    if (changePercent < 0) return PriceDirection.down;
    return PriceDirection.neutral;
  }

  /// 24시간 거래량을 double로 반환
  double? get volume24hDouble {
    if (volume24h == null) return null;
    return double.tryParse(volume24h!) ?? 0.0;
  }

  /// 24시간 거래대금을 double로 반환
  double? get turnover24hDouble {
    if (turnover24h == null) return null;
    return double.tryParse(turnover24h!) ?? 0.0;
  }

  /// 현재 가격을 double로 반환
  double? get lastPriceDouble {
    if (lastPrice == null) return null;
    return double.tryParse(lastPrice!) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'category': category,
      'lastPrice': lastPrice,
      'prevPrice24h': prevPrice24h,
      'price24hPcnt': price24hPcnt,
      'highPrice24h': highPrice24h,
      'lowPrice24h': lowPrice24h,
      'turnover24h': turnover24h,
      'volume24h': volume24h,
      'bid1Price': bid1Price,
      'bid1Size': bid1Size,
      'ask1Price': ask1Price,
      'ask1Size': ask1Size,
      'indexPrice': indexPrice,
      'markPrice': markPrice,
      'prevPrice1h': prevPrice1h,
      'openInterest': openInterest,
      'openInterestValue': openInterestValue,
      'fundingRate': fundingRate,
      'nextFundingTime': nextFundingTime,
      'predictedDeliveryPrice': predictedDeliveryPrice,
      'basisRate': basisRate,
      'deliveryFeeRate': deliveryFeeRate,
      'deliveryTime': deliveryTime,
      'basis': basis,
      'preOpenPrice': preOpenPrice,
      'preQty': preQty,
      'curPreListingPhase': curPreListingPhase,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TickerPriceData(symbol: $symbol, category: $category, lastPrice: $lastPrice, price24hPcnt: $price24hPcnt)';
  }
}

/// 가격 변화 방향
enum PriceDirection {
  up,    // 상승
  down,  // 하락
  neutral, // 보합
}

/// 통합 Ticker 데이터 (instrument + ticker 가격 정보)
class IntegratedTickerPriceData {
  final String symbol;
  final String integratedSymbol;
  final String category;
  final String baseCode;
  final String quoteCode;
  final double? quantity;
  final String status;
  final String exchange;
  
  // Instrument 기본 정보
  final String? koreanName;
  final String? englishName;
  final String? marketWarning;
  
  // 계약 정보
  final String? endDate;
  final String? launchTime;
  final String? settleCoin;
  
  // Ticker 가격 정보
  final TickerPriceData? priceData;
  
  final DateTime lastUpdated;

  const IntegratedTickerPriceData({
    required this.symbol,
    required this.integratedSymbol,
    required this.category,
    required this.baseCode,
    required this.quoteCode,
    this.quantity,
    required this.status,
    required this.exchange,
    this.koreanName,
    this.englishName,
    this.marketWarning,
    this.endDate,
    this.launchTime,
    this.settleCoin,
    this.priceData,
    required this.lastUpdated,
  });

  /// 가격 정보가 있는지 확인
  bool get hasPriceData => priceData != null;

  /// 가격 변화율 반환
  double? get priceChangePercent => priceData?.priceChangePercent;

  /// 가격 변화 방향 반환
  PriceDirection get priceDirection => priceData?.priceDirection ?? PriceDirection.neutral;

  /// 현재 가격 반환
  String? get currentPrice => priceData?.lastPrice;

  /// 24시간 거래량 반환
  String? get volume24h => priceData?.volume24h;

  /// 24시간 거래대금 반환
  String? get turnover24h => priceData?.turnover24h;
}