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
  final int quantity;

  @HiveField(4)
  @JsonKey(name: 'rate')
  final double rate;

  ExchangeRate({
    required this.lastUpdatedUnix,
    required this.baseCode,
    required this.quoteCode,
    this.quantity = 1,
    required this.rate,
  });

  ExchangeRate copyWith({
    int? lastUpdatedUnix,
    String? baseCode,
    String? quoteCode,
    int? quantity,
    double? rate,
  }) {
    return ExchangeRate(
      lastUpdatedUnix: lastUpdatedUnix ?? this.lastUpdatedUnix,
      baseCode: baseCode ?? this.baseCode,
      quoteCode: quoteCode ?? this.quoteCode,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
    );
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeRateToJson(this);
}
