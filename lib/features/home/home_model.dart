import 'package:flutter/foundation.dart';

@immutable
class CryptoPremium {
  const CryptoPremium({
    required this.symbol,
    required this.name,
    this.koreanName,
    this.bybitPrice,
    this.bybitQuoteCode,
    this.bithumbPrice,
    this.bithumbPriceKRW,
    this.premium,
  });

  final String symbol;
  final String name;
  final String? koreanName;
  final double? bybitPrice;
  final String? bybitQuoteCode;
  final double? bithumbPrice;
  final double? bithumbPriceKRW;
  final double? premium;
}

enum PremiumSortOption {
  symbol,
  bybitPrice,
  bithumbPrice,
  premium,
}

enum SortDirection {
  asc,
  desc,
}
