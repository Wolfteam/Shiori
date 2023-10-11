import 'package:json_annotation/json_annotation.dart';

part 'base_request_dto.g.dart';

@JsonSerializable()
class BaseRequestDto {
  final String appVersion;

  final int? currentVersion;

  const BaseRequestDto({
    required this.appVersion,
    required this.currentVersion,
  });

  Map<String, dynamic> toJson() => _$BaseRequestDtoToJson(this);
}
