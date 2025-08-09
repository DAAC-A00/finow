// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integrated_instrument.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntegratedInstrumentAdapter extends TypeAdapter<IntegratedInstrument> {
  @override
  final int typeId = 2;

  @override
  IntegratedInstrument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntegratedInstrument(
      integratedSymbol: fields[0] as String,
      baseCoin: fields[1] as String,
      quoteCoin: fields[2] as String,
      exchanges: (fields[3] as Map).cast<String, ExchangeInstrumentData>(),
      koreanName: fields[4] as String?,
      englishName: fields[5] as String?,
      lastUpdated: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, IntegratedInstrument obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.integratedSymbol)
      ..writeByte(1)
      ..write(obj.baseCoin)
      ..writeByte(2)
      ..write(obj.quoteCoin)
      ..writeByte(3)
      ..write(obj.exchanges)
      ..writeByte(4)
      ..write(obj.koreanName)
      ..writeByte(5)
      ..write(obj.englishName)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntegratedInstrumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExchangeInstrumentDataAdapter
    extends TypeAdapter<ExchangeInstrumentData> {
  @override
  final int typeId = 5;

  @override
  ExchangeInstrumentData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExchangeInstrumentData(
      originalSymbol: fields[0] as String,
      status: fields[1] as String,
      koreanName: fields[2] as String?,
      englishName: fields[3] as String?,
      marketWarning: fields[4] as String?,
      priceFilter: fields[5] as InstrumentPriceFilter?,
      lotSizeFilter: fields[6] as InstrumentLotSizeFilter?,
      lastUpdated: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExchangeInstrumentData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.originalSymbol)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.koreanName)
      ..writeByte(3)
      ..write(obj.englishName)
      ..writeByte(4)
      ..write(obj.marketWarning)
      ..writeByte(5)
      ..write(obj.priceFilter)
      ..writeByte(6)
      ..write(obj.lotSizeFilter)
      ..writeByte(7)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeInstrumentDataAdapter &&
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
