import 'package:hive/hive.dart';

part 'integrated_instrument.g.dart';

/// 통합 거래소 심볼 정보 모델
@HiveType(typeId: 2)
class IntegratedInstrument {
  @HiveField(0)
  final String symbol;
  
  @HiveField(1)
  final String baseCoin;
  
  @HiveField(2)
  final String quoteCoin;
  
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

  const IntegratedInstrument({
    required this.symbol,
    required this.baseCoin,
    required this.quoteCoin,
    required this.exchange,
    required this.status,
    this.koreanName,
    this.englishName,
    this.marketWarning,
    this.priceFilter,
    this.lotSizeFilter,
    required this.lastUpdated,
  });

  factory IntegratedInstrument.fromBybit(Map<String, dynamic> json) {
    return IntegratedInstrument(
      symbol: json['symbol'] ?? '',
      baseCoin: json['baseCoin'] ?? '',
      quoteCoin: json['quoteCoin'] ?? '',
      exchange: 'bybit',
      status: json['status'] ?? '',
      priceFilter: json['priceFilter'] != null 
          ? InstrumentPriceFilter.fromJson(json['priceFilter'])
          : null,
      lotSizeFilter: json['lotSizeFilter'] != null
          ? InstrumentLotSizeFilter.fromJson(json['lotSizeFilter'])
          : null,
      lastUpdated: DateTime.now(),
    );
  }

  factory IntegratedInstrument.fromBithumb(Map<String, dynamic> json) {
    final market = json['market'] ?? '';
    final parts = market.split('-');
    
    return IntegratedInstrument(
      symbol: market,
      baseCoin: parts.length > 1 ? parts[1] : '',
      quoteCoin: parts.isNotEmpty ? parts[0] : '',
      exchange: 'bithumb',
      status: 'Trading',
      koreanName: json['korean_name'],
      englishName: json['english_name'],
      marketWarning: json['market_warning'],
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseCoin': baseCoin,
      'quoteCoin': quoteCoin,
      'exchange': exchange,
      'status': status,
      'koreanName': koreanName,
      'englishName': englishName,
      'marketWarning': marketWarning,
      'priceFilter': priceFilter?.toJson(),
      'lotSizeFilter': lotSizeFilter?.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory IntegratedInstrument.fromJson(Map<String, dynamic> json) {
    return IntegratedInstrument(
      symbol: json['symbol'] ?? '',
      baseCoin: json['baseCoin'] ?? '',
      quoteCoin: json['quoteCoin'] ?? '',
      exchange: json['exchange'] ?? '',
      status: json['status'] ?? '',
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
    return 'IntegratedInstrument(symbol: $symbol, exchange: $exchange, status: $status)';
  }
}

/// 가격 필터 정보
@HiveType(typeId: 3)
class InstrumentPriceFilter {
  @HiveField(0)
  final String tickSize;

  const InstrumentPriceFilter({
    required this.tickSize,
  });

  factory InstrumentPriceFilter.fromJson(Map<String, dynamic> json) {
    return InstrumentPriceFilter(
      tickSize: json['tickSize'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tickSize': tickSize,
    };
  }
}

/// 로트 사이즈 필터 정보
@HiveType(typeId: 4)
class InstrumentLotSizeFilter {
  @HiveField(0)
  final String basePrecision;
  
  @HiveField(1)
  final String quotePrecision;
  
  @HiveField(2)
  final String minOrderQty;
  
  @HiveField(3)
  final String maxOrderQty;
  
  @HiveField(4)
  final String minOrderAmt;
  
  @HiveField(5)
  final String maxOrderAmt;

  const InstrumentLotSizeFilter({
    required this.basePrecision,
    required this.quotePrecision,
    required this.minOrderQty,
    required this.maxOrderQty,
    required this.minOrderAmt,
    required this.maxOrderAmt,
  });

  factory InstrumentLotSizeFilter.fromJson(Map<String, dynamic> json) {
    return InstrumentLotSizeFilter(
      basePrecision: json['basePrecision'] ?? '0',
      quotePrecision: json['quotePrecision'] ?? '0',
      minOrderQty: json['minOrderQty'] ?? '0',
      maxOrderQty: json['maxOrderQty'] ?? '0',
      minOrderAmt: json['minOrderAmt'] ?? '0',
      maxOrderAmt: json['maxOrderAmt'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePrecision': basePrecision,
      'quotePrecision': quotePrecision,
      'minOrderQty': minOrderQty,
      'maxOrderQty': maxOrderQty,
      'minOrderAmt': minOrderAmt,
      'maxOrderAmt': maxOrderAmt,
    };
  }
}
