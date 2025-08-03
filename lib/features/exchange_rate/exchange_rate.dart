import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exchange_rate.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class ExchangeRate extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'time_last_update_unix')
  final int lastUpdatedUnix;

  @HiveField(1)
  @JsonKey(name: 'base_code')
  final String baseCode;

  @HiveField(2)
  @JsonKey(name: 'conversion_rates')
  final Map<String, double> rates;

  ExchangeRate({
    required this.lastUpdatedUnix,
    required this.baseCode,
    required this.rates,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeRateToJson(this);
}
