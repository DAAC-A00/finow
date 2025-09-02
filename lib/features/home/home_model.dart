import 'package:flutter/foundation.dart';

@immutable
class CryptoPremium {
  const CryptoPremium({
    required this.symbol,
    required this.name,
    this.bybitPrice,
    this.bithumbPrice,
    this.premium,
  });

  final String symbol;
  final String name;
  final double? bybitPrice;
  final double? bithumbPrice;
  final double? premium;
}
