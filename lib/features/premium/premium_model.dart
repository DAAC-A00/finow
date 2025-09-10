import 'package:flutter/foundation.dart';

@immutable
class Premium {
  const Premium({
    required this.symbol,
    required this.name,
    this.koreanName,
    this.bybitPrice,
    this.bybitQuoteCode,
    this.bithumbPrice,
    this.bithumbPriceKRW,
    this.bithumbQuoteCode,
    this.premium,
    this.turnover24h,
    this.volume24h,
  });

  final String symbol;
  final String name;
  final String? koreanName;
  final double? bybitPrice;
  final String? bybitQuoteCode;
  final double? bithumbPrice;
  final double? bithumbPriceKRW;
  final String? bithumbQuoteCode;
  final double? premium;
  final double? turnover24h;
  final double? volume24h;
}

enum PremiumSortOption {
  volume,
  turnover,
  premium,
  symbol,
  bithumbPrice,
  bybitPrice,
}

enum SortDirection {
  asc,
  desc,
}
