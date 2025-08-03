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
      lastUpdatedUnix: fields[0] as int,
      baseCode: fields[1] as String,
      quoteCode: fields[2] as String,
      quantity: fields[3] as int,
      rate: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExchangeRate obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.lastUpdatedUnix)
      ..writeByte(1)
      ..write(obj.baseCode)
      ..writeByte(2)
      ..write(obj.quoteCode)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.rate);
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
      lastUpdatedUnix: (json['time_last_update_unix'] as num).toInt(),
      baseCode: json['base_code'] as String,
      quoteCode: json['quote_code'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      rate: (json['rate'] as num).toDouble(),
    );

Map<String, dynamic> _$ExchangeRateToJson(ExchangeRate instance) =>
    <String, dynamic>{
      'time_last_update_unix': instance.lastUpdatedUnix,
      'base_code': instance.baseCode,
      'quote_code': instance.quoteCode,
      'quantity': instance.quantity,
      'rate': instance.rate,
    };
