import 'package:json_annotation/json_annotation.dart';

part 'bithumb_ticker_model.g.dart';

@JsonSerializable()
class BithumbTicker {
  // fromJson에서 제외하고, 파싱 과정에서 수동으로 채워집니다.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? market;

  @JsonKey(name: 'opening_price')
  final String? openingPrice;

  @JsonKey(name: 'closing_price')
  final String? closingPrice;

  @JsonKey(name: 'min_price')
  final String? minPrice;

  @JsonKey(name: 'max_price')
  final String? maxPrice;

  @JsonKey(name: 'units_traded')
  final String? unitsTraded;

  @JsonKey(name: 'acc_trade_value')
  final String? accTradeValue;

  @JsonKey(name: 'prev_closing_price')
  final String? prevClosingPrice;

  @JsonKey(name: 'units_traded_24H')
  final String? unitsTraded24H;

  @JsonKey(name: 'acc_trade_value_24H')
  final String? accTradeValue24H;

  @JsonKey(name: 'fluctate_24H')
  final String? fluctuate24H;

  @JsonKey(name: 'fluctate_rate_24H')
  final String? fluctuateRate24H;

  BithumbTicker({
    // market은 더 이상 생성자에서 요구하지 않음
    this.openingPrice,
    this.closingPrice,
    this.minPrice,
    this.maxPrice,
    this.unitsTraded,
    this.accTradeValue,
    this.prevClosingPrice,
    this.unitsTraded24H,
    this.accTradeValue24H,
    this.fluctuate24H,
    this.fluctuateRate24H,
  });

  factory BithumbTicker.fromJson(Map<String, dynamic> json) =>
      _$BithumbTickerFromJson(json);

  Map<String, dynamic> toJson() => _$BithumbTickerToJson(this);
}