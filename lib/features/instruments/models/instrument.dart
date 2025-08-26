import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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
  final String? endDate;

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
    this.endDate,
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
    String? endDate,
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
      endDate: endDate ?? this.endDate,
      launchTime: launchTime ?? this.launchTime,
      settleCoin: settleCoin ?? this.settleCoin,
      quantity: quantity ?? this.quantity,
      integratedSymbol: integratedSymbol ?? this.integratedSymbol,
    );
  }

  factory Instrument.fromBybit(Map<String, dynamic> json, {String category = 'spot'}) {
    final contractType = json['contractType'] as String?;
    final symbol = json['symbol'] as String? ?? '';
    String? endDate;
    String mappedCategory = category;
    if (category == 'linear') mappedCategory = 'um';
    if (category == 'inverse') mappedCategory = 'cm';

    if (contractType != null) {
      if (contractType.contains('Perpetual')) {
        endDate = 'perpetual';
      } else if (contractType.contains('Futures')) {
        final parts = symbol.split('-');
        if (parts.length > 1) {
          endDate = _formatBybitFuturesDate(parts.last);
        }
      }
    }

    return Instrument(
      symbol: symbol,
      baseCode: json['baseCoin'] ?? '',
      quoteCode: json['quoteCoin'] ?? '',
      exchange: 'bybit',
      status: json['status'] ?? '',
      category: mappedCategory,
      endDate: endDate,
      launchTime: json['launchTime']?.toString(),
      settleCoin: json['settleCoin'],
      lastUpdated: DateTime.now(),
      integratedSymbol: '', // Will be set in ExchangeApiService
    );
  }

  static String _formatBybitFuturesDate(String dateStr) {
    // ex. 26DEC25, 05SEP25
    if (dateStr.length == 7) {
      final day = dateStr.substring(0, 2);
      final monthStr = dateStr.substring(2, 5);
      final year = dateStr.substring(5, 7);

      const monthMap = {
        'JAN': '01', 'FEB': '02', 'MAR': '03', 'APR': '04', 'MAY': '05', 'JUN': '06',
        'JUL': '07', 'AUG': '08', 'SEP': '09', 'OCT': '10', 'NOV': '11', 'DEC': '12'
      };
      final month = monthMap[monthStr];

      if (month != null) {
        return '20$year.$month.$day';
      }
    }
    return dateStr;
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

  factory Instrument.fromBinanceSpot(Map<String, dynamic> json) {
    // symbols의 각 item
    final baseAsset = json['baseAsset'] ?? '';
    final quoteAsset = json['quoteAsset'] ?? '';
    String baseCode = baseAsset;
    double? quantity;

    // Parse quantity and baseCode from baseAsset (e.g., '1000000MOG' -> quantity: 1000000, baseCode: 'MOG')
    final regex = RegExp(r'^(\d+)([A-Z]+)$');
    final match = regex.firstMatch(baseAsset);
    if (match != null) {
      quantity = double.tryParse(match.group(1)!);
      baseCode = match.group(2)!;
    }

    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: baseCode,
      quoteCode: quoteAsset,
      exchange: 'binance',
      status: json['status'] ?? '',
      lastUpdated: DateTime.now(),
      category: 'spot',
      quantity: quantity,
      integratedSymbol: '${json['baseAsset'] ?? ''}/${json['quoteAsset'] ?? ''}',
    );
  }

  factory Instrument.fromBinanceUm(Map<String, dynamic> json) {
    // USDⓈ-M 선물
    String endDate = '';
    final contractType = json['contractType'] as String?;
    final deliveryDate = json['deliveryDate'] as int?;

    if (contractType == 'PERPETUAL' || (deliveryDate != null && deliveryDate == 4133404800000)) {
      endDate = 'perpetual';
    } else if (deliveryDate != null && deliveryDate != 4133404800000) {
      // deliveryDate를 실제 날짜로 변환
      final date = DateTime.fromMillisecondsSinceEpoch(deliveryDate);
      endDate = DateFormat('yyyy.MM.dd').format(date);
    }

    final baseAsset = json['baseAsset'] ?? '';
    final quoteAsset = json['quoteAsset'] ?? '';
    String baseCode = baseAsset;
    double? quantity;

    // Parse quantity and baseCode from baseAsset (e.g., '1000000MOG' -> quantity: 1000000, baseCode: 'MOG')
    final regex = RegExp(r'^(\d+)([A-Z]+)$');
    final match = regex.firstMatch(baseAsset);
    if (match != null) {
      quantity = double.tryParse(match.group(1)!);
      baseCode = match.group(2)!;
    }

    String integratedSymbol = '$baseAsset/$quoteAsset';

    // endDate가 실제 날짜 포맷이면 추가
    if (endDate.isNotEmpty && endDate != 'perpetual' && RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(endDate)) {
      integratedSymbol = '$integratedSymbol-${endDate.substring(2)}'; // yyyy.MM.dd -> yy.MM.dd
    }

    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: baseCode,
      quoteCode: quoteAsset,
      exchange: 'binance',
      status: json['status'] ?? '',
      lastUpdated: DateTime.now(),
      category: 'um',
      endDate: endDate,
      quantity: quantity,
      integratedSymbol: integratedSymbol,
    );
  }

  factory Instrument.fromBinanceCm(Map<String, dynamic> json) {
    // COIN-M 선물
    String endDate = '';
    final contractType = json['contractType'] as String?;
    final deliveryDate = json['deliveryDate'] as int?;

    if (contractType == 'PERPETUAL' || (deliveryDate != null && deliveryDate == 4133404800000)) {
      endDate = 'perpetual';
    } else if (deliveryDate != null && deliveryDate != 4133404800000) {
      // deliveryDate를 실제 날짜로 변환
      final date = DateTime.fromMillisecondsSinceEpoch(deliveryDate);
      endDate = DateFormat('yyyy.MM.dd').format(date);
    }

    final baseAsset = json['baseAsset'] ?? '';
    final quoteAsset = json['quoteAsset'] ?? '';
    final contractSize = json['contractSize'] as int?;
    String baseCode = baseAsset;
    double? quantity;

    // contractSize 필드가 있으면 우선적으로 사용
    if (contractSize != null) {
      quantity = contractSize.toDouble();
    }

    // 정규식을 사용하여 baseAsset에서 숫자 부분을 분리 (예: 'BTC100' -> 'BTC', 100)
    // contractSize가 없는 경우를 위한 대비책
    if (quantity == null) {
      final regex = RegExp(r'^([A-Z]+)(\d+)$');
      final match = regex.firstMatch(baseAsset);
      if (match != null) {
        baseCode = match.group(1)!;
        final quantityString = match.group(2);
        if (quantityString != null && quantityString.isNotEmpty) {
          quantity = double.tryParse(quantityString);
        }
      }
    }
    
    String integratedSymbol = '$baseAsset/$quoteAsset';

    // endDate가 실제 날짜 포맷이면 추가
    if (endDate.isNotEmpty && endDate != 'perpetual' && RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(endDate)) {
      integratedSymbol = '$integratedSymbol-${endDate.substring(2)}'; // yyyy.MM.dd -> yy.MM.dd
    }

    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: baseCode,
      quoteCode: quoteAsset,
      exchange: 'binance',
      status: json['contractStatus'] ?? json['status'] ?? '',
      lastUpdated: DateTime.now(),
      category: 'cm',
      endDate: endDate,
      quantity: quantity,
      integratedSymbol: integratedSymbol,
    );
  }

  factory Instrument.fromBitgetSpot(Map<String, dynamic> json) {
    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: json['baseCoin'] ?? '',
      quoteCode: json['quoteCoin'] ?? '',
      exchange: 'bitget',
      status: json['status'] ?? '',
      lastUpdated: DateTime.now(),
      category: 'spot',
      integratedSymbol: '${json['baseCoin'] ?? ''}/${json['quoteCoin'] ?? ''}',
    );
  }

  factory Instrument.fromBitgetUm(Map<String, dynamic> json) {
    String? endDate;
    if (json['type'] == 'perpetual') {
      endDate = 'perpetual';
    } else if (json['deliveryTime'] != null) {
      // deliveryTime is a timestamp in milliseconds
      final deliveryTime = int.tryParse(json['deliveryTime'].toString());
      if (deliveryTime != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(deliveryTime);
        endDate = DateFormat('yyyy.MM.dd').format(date);
      }
    }

    String integratedSymbol = '${json['baseCoin'] ?? ''}/${json['quoteCoin'] ?? ''}';
    if (endDate != null && endDate != 'perpetual' && RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(endDate)) {
      integratedSymbol = '$integratedSymbol-${endDate.substring(2)}'; // yyyy.MM.dd -> yy.MM.dd
    }

    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: json['baseCoin'] ?? '',
      quoteCode: json['quoteCoin'] ?? '',
      exchange: 'bitget',
      status: json['status'] ?? '',
      lastUpdated: DateTime.now(),
      category: 'um',
      endDate: endDate,
      launchTime: json['launchTime']?.toString(),
      integratedSymbol: integratedSymbol,
    );
  }

  factory Instrument.fromCoinbase(Map<String, dynamic> json) {
    String? endDate;
    if (json['type'] == 'PERP') {
      endDate = 'perpetual';
    }

    return Instrument(
      symbol: json['symbol'] ?? '',
      baseCode: json['base_asset_name'] ?? '',
      quoteCode: json['quote_asset_name'] ?? '',
      exchange: 'coinbase',
      status: json['trading_state'] ?? '',
      lastUpdated: DateTime.now(),
      category: json['type']?.toLowerCase(), // PERP -> perp
      endDate: endDate,
      integratedSymbol: '${json['base_asset_name'] ?? ''}/${json['quote_asset_name'] ?? ''}',
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
      'endDate': endDate,
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
      endDate: json['endDate'],
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
