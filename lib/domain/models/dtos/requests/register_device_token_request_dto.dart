import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos/requests/base_request_dto.dart';

part 'register_device_token_request_dto.g.dart';

@JsonSerializable()
class RegisterDeviceTokenRequestDto extends BaseRequestDto {
  final String token;

  @JsonKey(name: 'language', includeToJson: true)
  final int languageIndex;

  @JsonKey(includeToJson: false)
  final AppLanguageType language;

  RegisterDeviceTokenRequestDto({
    required super.appVersion,
    required super.currentVersion,
    required this.token,
    required this.language,
  }) : languageIndex = language.index;

  @override
  Map<String, dynamic> toJson() => _$RegisterDeviceTokenRequestDtoToJson(this);
}
