// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiKeyStatusAdapter extends TypeAdapter<ApiKeyStatus> {
  @override
  final int typeId = 6;

  @override
  ApiKeyStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ApiKeyStatus.valid;
      case 1:
        return ApiKeyStatus.invalidKey;
      case 2:
        return ApiKeyStatus.inactiveAccount;
      case 3:
        return ApiKeyStatus.quotaReached;
      case 4:
        return ApiKeyStatus.unsupportedCode;
      case 5:
        return ApiKeyStatus.malformedRequest;
      case 6:
        return ApiKeyStatus.unknown;
      case 7:
        return ApiKeyStatus.validating;
      default:
        return ApiKeyStatus.valid;
    }
  }

  @override
  void write(BinaryWriter writer, ApiKeyStatus obj) {
    switch (obj) {
      case ApiKeyStatus.valid:
        writer.writeByte(0);
        break;
      case ApiKeyStatus.invalidKey:
        writer.writeByte(1);
        break;
      case ApiKeyStatus.inactiveAccount:
        writer.writeByte(2);
        break;
      case ApiKeyStatus.quotaReached:
        writer.writeByte(3);
        break;
      case ApiKeyStatus.unsupportedCode:
        writer.writeByte(4);
        break;
      case ApiKeyStatus.malformedRequest:
        writer.writeByte(5);
        break;
      case ApiKeyStatus.unknown:
        writer.writeByte(6);
        break;
      case ApiKeyStatus.validating:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiKeyStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
