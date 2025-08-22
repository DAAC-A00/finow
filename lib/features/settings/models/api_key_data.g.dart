// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiKeyDataAdapter extends TypeAdapter<ApiKeyData> {
  @override
  final int typeId = 5;

  @override
  ApiKeyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiKeyData(
      key: fields[0] as String,
      status: fields[1] as ApiKeyStatus,
      lastValidated: fields[2] as int?,
      planQuota: fields[3] as int?,
      requestsRemaining: fields[4] as int?,
      refreshDayOfMonth: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ApiKeyData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.lastValidated)
      ..writeByte(3)
      ..write(obj.planQuota)
      ..writeByte(4)
      ..write(obj.requestsRemaining)
      ..writeByte(5)
      ..write(obj.refreshDayOfMonth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiKeyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiKeyData _$ApiKeyDataFromJson(Map<String, dynamic> json) => ApiKeyData(
      key: json['key'] as String,
      status: $enumDecode(_$ApiKeyStatusEnumMap, json['status']),
      lastValidated: (json['lastValidated'] as num?)?.toInt(),
      planQuota: (json['planQuota'] as num?)?.toInt(),
      requestsRemaining: (json['requestsRemaining'] as num?)?.toInt(),
      refreshDayOfMonth: (json['refreshDayOfMonth'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ApiKeyDataToJson(ApiKeyData instance) =>
    <String, dynamic>{
      'key': instance.key,
      'status': _$ApiKeyStatusEnumMap[instance.status]!,
      'lastValidated': instance.lastValidated,
      'planQuota': instance.planQuota,
      'requestsRemaining': instance.requestsRemaining,
      'refreshDayOfMonth': instance.refreshDayOfMonth,
    };

const _$ApiKeyStatusEnumMap = {
  ApiKeyStatus.valid: 'valid',
  ApiKeyStatus.invalidKey: 'invalidKey',
  ApiKeyStatus.inactiveAccount: 'inactiveAccount',
  ApiKeyStatus.quotaReached: 'quotaReached',
  ApiKeyStatus.unsupportedCode: 'unsupportedCode',
  ApiKeyStatus.malformedRequest: 'malformedRequest',
  ApiKeyStatus.unknown: 'unknown',
  ApiKeyStatus.validating: 'validating',
};
