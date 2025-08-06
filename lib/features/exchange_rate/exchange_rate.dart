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
  @JsonKey(name: 'quote_code')
  final String quoteCode;

  @HiveField(3)
  @JsonKey(name: 'rate')
  final double rate;

  ExchangeRate({
    required this.lastUpdatedUnix,
    required this.baseCode,
    required this.quoteCode,
    required this.rate,
  });

  ExchangeRate copyWith({
    int? lastUpdatedUnix,
    String? baseCode,
    String? quoteCode,
    double? rate,
  }) {
    return ExchangeRate(
      lastUpdatedUnix: lastUpdatedUnix ?? this.lastUpdatedUnix,
      baseCode: baseCode ?? this.baseCode,
      quoteCode: quoteCode ?? this.quoteCode,
      rate: rate ?? this.rate,
    );
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeRateToJson(this);
}
