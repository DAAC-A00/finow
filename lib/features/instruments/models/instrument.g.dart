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
      baseCoin: fields[1] as String,
      quoteCoin: fields[2] as String,
      exchange: fields[3] as String,
      status: fields[4] as String,
      koreanName: fields[5] as String?,
      englishName: fields[6] as String?,
      marketWarning: fields[7] as String?,
      priceFilter: fields[8] as InstrumentPriceFilter?,
      lotSizeFilter: fields[9] as InstrumentLotSizeFilter?,
      lastUpdated: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Instrument obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.baseCoin)
      ..writeByte(2)
      ..write(obj.quoteCoin)
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
      ..write(obj.priceFilter)
      ..writeByte(9)
      ..write(obj.lotSizeFilter)
      ..writeByte(10)
      ..write(obj.lastUpdated);
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

class InstrumentPriceFilterAdapter extends TypeAdapter<InstrumentPriceFilter> {
  @override
  final int typeId = 3;

  @override
  InstrumentPriceFilter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstrumentPriceFilter(
      tickSize: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InstrumentPriceFilter obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.tickSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstrumentPriceFilterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InstrumentLotSizeFilterAdapter
    extends TypeAdapter<InstrumentLotSizeFilter> {
  @override
  final int typeId = 4;

  @override
  InstrumentLotSizeFilter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstrumentLotSizeFilter(
      basePrecision: fields[0] as String,
      quotePrecision: fields[1] as String,
      minOrderQty: fields[2] as String,
      maxOrderQty: fields[3] as String,
      minOrderAmt: fields[4] as String,
      maxOrderAmt: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InstrumentLotSizeFilter obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.basePrecision)
      ..writeByte(1)
      ..write(obj.quotePrecision)
      ..writeByte(2)
      ..write(obj.minOrderQty)
      ..writeByte(3)
      ..write(obj.maxOrderQty)
      ..writeByte(4)
      ..write(obj.minOrderAmt)
      ..writeByte(5)
      ..write(obj.maxOrderAmt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstrumentLotSizeFilterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
