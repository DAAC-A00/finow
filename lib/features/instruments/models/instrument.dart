import 'package:hive/hive.dart';

part 'instrument.g.dart';

/// 통합 거래소 심볼 정보 모델
@HiveType(typeId: 2)
class Instrument {
  @HiveField(0)
  final String symbol;
  
  @HiveField(1)
  final String baseCode;
  
  @HiveField(2)
  final String quoteCode;
  
  @HiveField(3)
  final String exchange; // 'bybit' 또는 'bithumb'
  
  @HiveField(4)
  final String status;
  
  @HiveField(5)
  final String? koreanName;
  
  @HiveField(6)
  final String? englishName;
  
  @HiveField(7)
  final String? marketWarning;
  
  @HiveField(8)
  final InstrumentPriceFilter? priceFilter;
  
  @HiveField(9)
  final InstrumentLotSizeFilter? lotSizeFilter;
  
  @HiveField(10)
  final DateTime lastUpdated;

  @HiveField(11)
  final String? category; // 'spot', 'linear', 'inverse'

  @HiveField(12)
  final String? contractType; // 'LinearPerpetual', 'LinearFutures', 'InversePerpetual', etc.

  @HiveField(13)
  final String? launchTime;

  @HiveField(14)
  final String? deliveryTime;

  @HiveField(15)
  final String? deliveryFeeRate;

  @HiveField(16)
  final String? priceScale;

  @HiveField(17)
  final InstrumentLeverageFilter? leverageFilter;

  @HiveField(18)
  final bool? unifiedMarginTrade;

  @HiveField(19)
  final int? fundingInterval;

  @HiveField(20)
  final String? settleCoin;

  @HiveField(21)
  final String? copyTrading;

  @HiveField(22)
  final String? upperFundingRate;

  @HiveField(23)
  final String? lowerFundingRate;

  @HiveField(24)
  final bool? isPreListing;

  @HiveField(25)
  final Map<String, dynamic>? preListingInfo;

  @HiveField(26)
  final InstrumentRiskParameters? riskParameters;

  @HiveField(27)
  final String? displayName;

  const Instrument({
    required this.symbol,
    required this.baseCode,
    required this.quoteCode,
    required this.exchange,
    required this.status,
    this.koreanName,
    this.englishName,
    this.marketWarning,
    this.priceFilter,
    this.lotSizeFilter,
    required this.lastUpdated,
    this.category,
    this.contractType,
    this.launchTime,
    this.deliveryTime,
    this.deliveryFeeRate,
    this.priceScale,
    this.leverageFilter,
    this.unifiedMarginTrade,
    this.fundingInterval,
    this.settleCoin,
    this.copyTrading,
    this.upperFundingRate,
    this.lowerFundingRate,
    this.isPreListing,
    this.preListingInfo,
    this.riskParameters,
    this.displayName,
  });

  factory Instrument.fromBybit(Map<String, dynamic> json, {String category = 'spot'}) {
    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: json['baseCode'] ?? '',
      quoteCode: json['quoteCode'] ?? '',
      exchange: 'bybit',
      status: json['status'] ?? '',
      category: category,
      contractType: json['contractType'],
      launchTime: json['launchTime']?.toString(),
      deliveryTime: json['deliveryTime']?.toString(),
      deliveryFeeRate: json['deliveryFeeRate']?.toString(),
      priceScale: json['priceScale']?.toString(),
      leverageFilter: json['leverageFilter'] != null
          ? InstrumentLeverageFilter.fromJson(json['leverageFilter'])
          : null,
      priceFilter: json['priceFilter'] != null 
          ? InstrumentPriceFilter.fromJson(json['priceFilter'])
          : null,
      lotSizeFilter: json['lotSizeFilter'] != null
          ? InstrumentLotSizeFilter.fromJson(json['lotSizeFilter'])
          : null,
      unifiedMarginTrade: json['unifiedMarginTrade'],
      fundingInterval: json['fundingInterval'],
      settleCoin: json['settleCoin'],
      copyTrading: json['copyTrading'],
      upperFundingRate: json['upperFundingRate']?.toString(),
      lowerFundingRate: json['lowerFundingRate']?.toString(),
      isPreListing: json['isPreListing'],
      preListingInfo: json['preListingInfo'],
      riskParameters: json['riskParameters'] != null
          ? InstrumentRiskParameters.fromJson(json['riskParameters'])
          : null,
      displayName: json['displayName'],
      lastUpdated: DateTime.now(),
    );
  }

  factory Instrument.fromBithumb(Map<String, dynamic> json) {
    final market = json['market'] ?? '';
    final parts = market.split('-');
    
    return Instrument(
      symbol: market,
      baseCode: parts.length > 1 ? parts[1] : '',
      quoteCode: parts.isNotEmpty ? parts[0] : '',
      exchange: 'bithumb',
      status: 'Trading',
      category: 'spot', // Bithumb은 spot만 지원
      koreanName: json['korean_name'],
      englishName: json['english_name'],
      marketWarning: json['market_warning'],
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseCode': baseCode,
      'quoteCode': quoteCode,
      'exchange': exchange,
      'status': status,
      'category': category,
      'contractType': contractType,
      'launchTime': launchTime,
      'deliveryTime': deliveryTime,
      'deliveryFeeRate': deliveryFeeRate,
      'priceScale': priceScale,
      'leverageFilter': leverageFilter?.toJson(),
      'unifiedMarginTrade': unifiedMarginTrade,
      'fundingInterval': fundingInterval,
      'settleCoin': settleCoin,
      'copyTrading': copyTrading,
      'upperFundingRate': upperFundingRate,
      'lowerFundingRate': lowerFundingRate,
      'isPreListing': isPreListing,
      'preListingInfo': preListingInfo,
      'riskParameters': riskParameters?.toJson(),
      'displayName': displayName,
      'koreanName': koreanName,
      'englishName': englishName,
      'marketWarning': marketWarning,
      'priceFilter': priceFilter?.toJson(),
      'lotSizeFilter': lotSizeFilter?.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: json['baseCode'] ?? '',
      quoteCode: json['quoteCode'] ?? '',
      exchange: json['exchange'] ?? '',
      status: json['status'] ?? '',
      category: json['category'],
      contractType: json['contractType'],
      launchTime: json['launchTime'],
      deliveryTime: json['deliveryTime'],
      deliveryFeeRate: json['deliveryFeeRate'],
      priceScale: json['priceScale'],
      leverageFilter: json['leverageFilter'] != null
          ? InstrumentLeverageFilter.fromJson(json['leverageFilter'])
          : null,
      unifiedMarginTrade: json['unifiedMarginTrade'],
      fundingInterval: json['fundingInterval'],
      settleCoin: json['settleCoin'],
      copyTrading: json['copyTrading'],
      upperFundingRate: json['upperFundingRate'],
      lowerFundingRate: json['lowerFundingRate'],
      isPreListing: json['isPreListing'],
      preListingInfo: json['preListingInfo'],
      riskParameters: json['riskParameters'] != null
          ? InstrumentRiskParameters.fromJson(json['riskParameters'])
          : null,
      displayName: json['displayName'],
      koreanName: json['koreanName'],
      englishName: json['englishName'],
      marketWarning: json['marketWarning'],
      priceFilter: json['priceFilter'] != null
          ? InstrumentPriceFilter.fromJson(json['priceFilter'])
          : null,
      lotSizeFilter: json['lotSizeFilter'] != null
          ? InstrumentLotSizeFilter.fromJson(json['lotSizeFilter'])
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'Instrument(symbol: $symbol, exchange: $exchange, status: $status)';
  }
}

/// 가격 필터 정보
@HiveType(typeId: 3)
class InstrumentPriceFilter {
  @HiveField(0)
  final String tickSize;

  @HiveField(1)
  final String? minPrice;

  @HiveField(2)
  final String? maxPrice;

  const InstrumentPriceFilter({
    required this.tickSize,
    this.minPrice,
    this.maxPrice,
  });

  factory InstrumentPriceFilter.fromJson(Map<String, dynamic> json) {
    return InstrumentPriceFilter(
      tickSize: json['tickSize'] ?? '0',
      minPrice: json['minPrice'],
      maxPrice: json['maxPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tickSize': tickSize,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
    };
  }
}

/// 로트 사이즈 필터 정보
@HiveType(typeId: 4)
class InstrumentLotSizeFilter {
  @HiveField(0)
  final String maxOrderQty;
  
  @HiveField(1)
  final String minOrderQty;
  
  @HiveField(2)
  final String qtyStep;
  
  @HiveField(3)
  final String? postOnlyMaxOrderQty;
  
  @HiveField(4)
  final String? maxMktOrderQty;
  
  @HiveField(5)
  final String? minNotionalValue;

  @HiveField(6)
  final String? basePrecision; // for Bithumb

  @HiveField(7)
  final String? quotePrecision; // for Bithumb
  
  @HiveField(8)
  final String? minOrderAmt; // for Bithumb
  
  @HiveField(9)
  final String? maxOrderAmt; // for Bithumb

  const InstrumentLotSizeFilter({
    required this.maxOrderQty,
    required this.minOrderQty,
    required this.qtyStep,
    this.postOnlyMaxOrderQty,
    this.maxMktOrderQty,
    this.minNotionalValue,
    this.basePrecision,
    this.quotePrecision,
    this.minOrderAmt,
    this.maxOrderAmt,
  });

  factory InstrumentLotSizeFilter.fromJson(Map<String, dynamic> json) {
    return InstrumentLotSizeFilter(
      maxOrderQty: json['maxOrderQty'] ?? '0',
      minOrderQty: json['minOrderQty'] ?? '0',
      qtyStep: json['qtyStep'] ?? '0',
      postOnlyMaxOrderQty: json['postOnlyMaxOrderQty'],
      maxMktOrderQty: json['maxMktOrderQty'],
      minNotionalValue: json['minNotionalValue'],
      basePrecision: json['basePrecision'],
      quotePrecision: json['quotePrecision'],
      minOrderAmt: json['minOrderAmt'],
      maxOrderAmt: json['maxOrderAmt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxOrderQty': maxOrderQty,
      'minOrderQty': minOrderQty,
      'qtyStep': qtyStep,
      'postOnlyMaxOrderQty': postOnlyMaxOrderQty,
      'maxMktOrderQty': maxMktOrderQty,
      'minNotionalValue': minNotionalValue,
      'basePrecision': basePrecision,
      'quotePrecision': quotePrecision,
      'minOrderAmt': minOrderAmt,
      'maxOrderAmt': maxOrderAmt,
    };
  }
}

/// 레버리지 필터 정보
@HiveType(typeId: 7)
class InstrumentLeverageFilter {
  @HiveField(0)
  final String minLeverage;
  
  @HiveField(1)
  final String maxLeverage;
  
  @HiveField(2)
  final String leverageStep;

  const InstrumentLeverageFilter({
    required this.minLeverage,
    required this.maxLeverage,
    required this.leverageStep,
  });

  factory InstrumentLeverageFilter.fromJson(Map<String, dynamic> json) {
    return InstrumentLeverageFilter(
      minLeverage: json['minLeverage'] ?? '1',
      maxLeverage: json['maxLeverage'] ?? '1',
      leverageStep: json['leverageStep'] ?? '0.01',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minLeverage': minLeverage,
      'maxLeverage': maxLeverage,
      'leverageStep': leverageStep,
    };
  }
}

/// 리스크 파라미터 정보
@HiveType(typeId: 8)
class InstrumentRiskParameters {
  @HiveField(0)
  final String? priceLimitRatioX;
  
  @HiveField(1)
  final String? priceLimitRatioY;

  const InstrumentRiskParameters({
    this.priceLimitRatioX,
    this.priceLimitRatioY,
  });

  factory InstrumentRiskParameters.fromJson(Map<String, dynamic> json) {
    return InstrumentRiskParameters(
      priceLimitRatioX: json['priceLimitRatioX'],
      priceLimitRatioY: json['priceLimitRatioY'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priceLimitRatioX': priceLimitRatioX,
      'priceLimitRatioY': priceLimitRatioY,
    };
  }
}
