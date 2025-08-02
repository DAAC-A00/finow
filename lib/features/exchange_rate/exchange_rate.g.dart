// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExchangeRateAdapter extends TypeAdapter<ExchangeRate> {
  @override
  final int typeId = 1;

  @override
  ExchangeRate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExchangeRate(
      lastUpdated: fields[0] as String,
      baseCode: fields[1] as String,
      rates: (fields[2] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExchangeRate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lastUpdated)
      ..writeByte(1)
      ..write(obj.baseCode)
      ..writeByte(2)
      ..write(obj.rates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeRateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeRate _$ExchangeRateFromJson(Map<String, dynamic> json) => ExchangeRate(
      lastUpdated: json['time_last_update_utc'] as String,
      baseCode: json['base_code'] as String,
      rates: (json['conversion_rates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$ExchangeRateToJson(ExchangeRate instance) =>
    <String, dynamic>{
      'time_last_update_utc': instance.lastUpdated,
      'base_code': instance.baseCode,
      'conversion_rates': instance.rates,
    };
