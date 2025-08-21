// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bithumb_ticker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BithumbTicker _$BithumbTickerFromJson(Map<String, dynamic> json) =>
    BithumbTicker(
      openingPrice: json['opening_price'] as String?,
      closingPrice: json['closing_price'] as String?,
      minPrice: json['min_price'] as String?,
      maxPrice: json['max_price'] as String?,
      unitsTraded: json['units_traded'] as String?,
      accTradeValue: json['acc_trade_value'] as String?,
      prevClosingPrice: json['prev_closing_price'] as String?,
      unitsTraded24H: json['units_traded_24H'] as String?,
      accTradeValue24H: json['acc_trade_value_24H'] as String?,
      fluctuate24H: json['fluctate_24H'] as String?,
      fluctuateRate24H: json['fluctate_rate_24H'] as String?,
    );

Map<String, dynamic> _$BithumbTickerToJson(BithumbTicker instance) =>
    <String, dynamic>{
      'opening_price': instance.openingPrice,
      'closing_price': instance.closingPrice,
      'min_price': instance.minPrice,
      'max_price': instance.maxPrice,
      'units_traded': instance.unitsTraded,
      'acc_trade_value': instance.accTradeValue,
      'prev_closing_price': instance.prevClosingPrice,
      'units_traded_24H': instance.unitsTraded24H,
      'acc_trade_value_24H': instance.accTradeValue24H,
      'fluctate_24H': instance.fluctuate24H,
      'fluctate_rate_24H': instance.fluctuateRate24H,
    };
