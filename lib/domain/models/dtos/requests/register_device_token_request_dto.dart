import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/models/dtos/requests/base_request_dto.dart';

part 'register_device_token_request_dto.g.dart';

@JsonSerializable()
class RegisterDeviceTokenRequestDto extends BaseRequestDto {
  final String token;

  const RegisterDeviceTokenRequestDto({
    required super.appVersion,
    required super.currentVersion,
    required this.token,
  });

  @override
  Map<String, dynamic> toJson() => _$RegisterDeviceTokenRequestDtoToJson(this);
}
