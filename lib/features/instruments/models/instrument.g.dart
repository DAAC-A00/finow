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
      category: fields[11] as String?,
      contractType: fields[12] as String?,
      launchTime: fields[13] as String?,
      deliveryTime: fields[14] as String?,
      deliveryFeeRate: fields[15] as String?,
      priceScale: fields[16] as String?,
      leverageFilter: fields[17] as InstrumentLeverageFilter?,
      unifiedMarginTrade: fields[18] as bool?,
      fundingInterval: fields[19] as int?,
      settleCoin: fields[20] as String?,
      copyTrading: fields[21] as String?,
      upperFundingRate: fields[22] as String?,
      lowerFundingRate: fields[23] as String?,
      isPreListing: fields[24] as bool?,
      preListingInfo: (fields[25] as Map?)?.cast<String, dynamic>(),
      riskParameters: fields[26] as InstrumentRiskParameters?,
      displayName: fields[27] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Instrument obj) {
    writer
      ..writeByte(28)
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
      ..write(obj.lastUpdated)
      ..writeByte(11)
      ..write(obj.category)
      ..writeByte(12)
      ..write(obj.contractType)
      ..writeByte(13)
      ..write(obj.launchTime)
      ..writeByte(14)
      ..write(obj.deliveryTime)
      ..writeByte(15)
      ..write(obj.deliveryFeeRate)
      ..writeByte(16)
      ..write(obj.priceScale)
      ..writeByte(17)
      ..write(obj.leverageFilter)
      ..writeByte(18)
      ..write(obj.unifiedMarginTrade)
      ..writeByte(19)
      ..write(obj.fundingInterval)
      ..writeByte(20)
      ..write(obj.settleCoin)
      ..writeByte(21)
      ..write(obj.copyTrading)
      ..writeByte(22)
      ..write(obj.upperFundingRate)
      ..writeByte(23)
      ..write(obj.lowerFundingRate)
      ..writeByte(24)
      ..write(obj.isPreListing)
      ..writeByte(25)
      ..write(obj.preListingInfo)
      ..writeByte(26)
      ..write(obj.riskParameters)
      ..writeByte(27)
      ..write(obj.displayName);
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
      minPrice: fields[1] as String?,
      maxPrice: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InstrumentPriceFilter obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tickSize)
      ..writeByte(1)
      ..write(obj.minPrice)
      ..writeByte(2)
      ..write(obj.maxPrice);
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
      maxOrderQty: fields[0] as String,
      minOrderQty: fields[1] as String,
      qtyStep: fields[2] as String,
      postOnlyMaxOrderQty: fields[3] as String?,
      maxMktOrderQty: fields[4] as String?,
      minNotionalValue: fields[5] as String?,
      basePrecision: fields[6] as String?,
      quotePrecision: fields[7] as String?,
      minOrderAmt: fields[8] as String?,
      maxOrderAmt: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InstrumentLotSizeFilter obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.maxOrderQty)
      ..writeByte(1)
      ..write(obj.minOrderQty)
      ..writeByte(2)
      ..write(obj.qtyStep)
      ..writeByte(3)
      ..write(obj.postOnlyMaxOrderQty)
      ..writeByte(4)
      ..write(obj.maxMktOrderQty)
      ..writeByte(5)
      ..write(obj.minNotionalValue)
      ..writeByte(6)
      ..write(obj.basePrecision)
      ..writeByte(7)
      ..write(obj.quotePrecision)
      ..writeByte(8)
      ..write(obj.minOrderAmt)
      ..writeByte(9)
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

class InstrumentLeverageFilterAdapter
    extends TypeAdapter<InstrumentLeverageFilter> {
  @override
  final int typeId = 7;

  @override
  InstrumentLeverageFilter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstrumentLeverageFilter(
      minLeverage: fields[0] as String,
      maxLeverage: fields[1] as String,
      leverageStep: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InstrumentLeverageFilter obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.minLeverage)
      ..writeByte(1)
      ..write(obj.maxLeverage)
      ..writeByte(2)
      ..write(obj.leverageStep);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstrumentLeverageFilterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InstrumentRiskParametersAdapter
    extends TypeAdapter<InstrumentRiskParameters> {
  @override
  final int typeId = 8;

  @override
  InstrumentRiskParameters read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstrumentRiskParameters(
      priceLimitRatioX: fields[0] as String?,
      priceLimitRatioY: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InstrumentRiskParameters obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.priceLimitRatioX)
      ..writeByte(1)
      ..write(obj.priceLimitRatioY);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstrumentRiskParametersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
