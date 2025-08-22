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
  final DateTime lastUpdated;

  @HiveField(9)
  final String? category; // 'spot', 'linear', 'inverse'

  @HiveField(10)
  final String? contractType; // 'LinearPerpetual', 'LinearFutures', 'InversePerpetual', etc.

  @HiveField(11)
  final String? launchTime;

  @HiveField(12)
  final String? settleCoin;

  @HiveField(13)
  final double? quantity;

  @HiveField(14)
  final String integratedSymbol;

  const Instrument({
    required this.symbol,
    required this.baseCode,
    required this.quoteCode,
    required this.exchange,
    required this.status,
    this.koreanName,
    this.englishName,
    this.marketWarning,
    required this.lastUpdated,
    this.category,
    this.contractType,
    this.launchTime,
    this.settleCoin,
    this.quantity,
    required this.integratedSymbol,
  });

  Instrument copyWith({
    String? symbol,
    String? baseCode,
    String? quoteCode,
    String? exchange,
    String? status,
    String? koreanName,
    String? englishName,
    String? marketWarning,
    DateTime? lastUpdated,
    String? category,
    String? contractType,
    String? launchTime,
    String? settleCoin,
    double? quantity,
    String? integratedSymbol,
  }) {
    return Instrument(
      symbol: symbol ?? this.symbol,
      baseCode: baseCode ?? this.baseCode,
      quoteCode: quoteCode ?? this.quoteCode,
      exchange: exchange ?? this.exchange,
      status: status ?? this.status,
      koreanName: koreanName ?? this.koreanName,
      englishName: englishName ?? this.englishName,
      marketWarning: marketWarning ?? this.marketWarning,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
      contractType: contractType ?? this.contractType,
      launchTime: launchTime ?? this.launchTime,
      settleCoin: settleCoin ?? this.settleCoin,
      quantity: quantity ?? this.quantity,
      integratedSymbol: integratedSymbol ?? this.integratedSymbol,
    );
  }

  factory Instrument.fromBybit(Map<String, dynamic> json, {String category = 'spot'}) {
    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: json['baseCoin'] ?? '',
      quoteCode: json['quoteCoin'] ?? '',
      exchange: 'bybit',
      status: json['status'] ?? '',
      category: category,
      contractType: json['contractType'],
      launchTime: json['launchTime']?.toString(),
      settleCoin: json['settleCoin'],
      lastUpdated: DateTime.now(),
      integratedSymbol: '', // Will be set in ExchangeApiService
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
      integratedSymbol: '', // Will be set in ExchangeApiService
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
      'settleCoin': settleCoin,
      'koreanName': koreanName,
      'englishName': englishName,
      'marketWarning': marketWarning,
      'lastUpdated': lastUpdated.toIso8601String(),
      'quantity': quantity,
      'integratedSymbol': integratedSymbol,
    };
  }

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: json['baseCoin'] ?? '',
      quoteCode: json['quoteCoin'] ?? '',
      exchange: json['exchange'] ?? '',
      status: json['status'] ?? '',
      category: json['category'],
      contractType: json['contractType'],
      launchTime: json['launchTime'],
      settleCoin: json['settleCoin'],
      koreanName: json['koreanName'],
      englishName: json['englishName'],
      marketWarning: json['marketWarning'],
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      quantity: json['quantity'] as double?,
      integratedSymbol: json['integratedSymbol'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Instrument(symbol: $symbol, exchange: $exchange, status: $status)';
  }
}