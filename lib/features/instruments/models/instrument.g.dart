// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InstrumentAdapter extends TypeAdapter<Instrument> {
  @override
  final int typeId = 2;

  @override
  Instrument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Instrument(
      symbol: fields[0] as String,
      baseCode: fields[1] as String,
      quoteCode: fields[2] as String,
      exchange: fields[3] as String,
      status: fields[4] as String,
      koreanName: fields[5] as String?,
      englishName: fields[6] as String?,
      marketWarning: fields[7] as String?,
      lastUpdated: fields[8] as DateTime,
      category: fields[9] as String?,
      endDate: fields[10] as String?,
      launchTime: fields[11] as String?,
      settleCoin: fields[12] as String?,
      quantity: fields[13] as double?,
      integratedSymbol: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Instrument obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.baseCode)
      ..writeByte(2)
      ..write(obj.quoteCode)
      ..writeByte(3)
      ..write(obj.exchange)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.koreanName)
      ..writeByte(6)
      ..write(obj.englishName)
      ..writeByte(7)
      ..write(obj.marketWarning)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.endDate)
      ..writeByte(11)
      ..write(obj.launchTime)
      ..writeByte(12)
      ..write(obj.settleCoin)
      ..writeByte(13)
      ..write(obj.quantity)
      ..writeByte(14)
      ..write(obj.integratedSymbol);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstrumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
