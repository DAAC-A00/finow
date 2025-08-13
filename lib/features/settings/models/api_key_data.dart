import 'package:finow/features/settings/api_key_status.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_key_data.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class ApiKeyData extends HiveObject {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final ApiKeyStatus status;

  @HiveField(2)
  final DateTime? lastValidated;

  ApiKeyData({
    required this.key,
    required this.status,
    this.lastValidated,
  });

  ApiKeyData copyWith({
    String? key,
    ApiKeyStatus? status,
    DateTime? lastValidated,
  }) {
    return ApiKeyData(
      key: key ?? this.key,
      status: status ?? this.status,
      lastValidated: lastValidated ?? this.lastValidated,
    );
  }

  /// API 키 사용 우선순위를 반환합니다.
  /// 낮은 숫자가 높은 우선순위입니다.
  int get priority {
    switch (status) {
      case ApiKeyStatus.valid:
        return 1;
      case ApiKeyStatus.quotaReached:
        return 2;
      case ApiKeyStatus.inactiveAccount:
        return 3;
      case ApiKeyStatus.invalidKey:
        return 4;
      case ApiKeyStatus.unsupportedCode:
        return 5;
      case ApiKeyStatus.malformedRequest:
        return 6;
      case ApiKeyStatus.unknown:
      case ApiKeyStatus.validating:
      default:
        return 7; // 미지정 상태는 가장 낮은 우선순위
    }
  }

  factory ApiKeyData.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyDataFromJson(json);

  Map<String, dynamic> toJson() => _$ApiKeyDataToJson(this);
}