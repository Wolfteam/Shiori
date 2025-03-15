import 'package:json_annotation/json_annotation.dart';

part 'save_app_logs_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SaveAppLogsRequestDto {
  final List<SaveAppLogRequestDto> logs;

  const SaveAppLogsRequestDto({
    required this.logs,
  });

  Map<String, dynamic> toJson() => _$SaveAppLogsRequestDtoToJson(this);

  factory SaveAppLogsRequestDto.fromJson(Map<String, dynamic> json) => _$SaveAppLogsRequestDtoFromJson(json);
}

@JsonSerializable()
class SaveAppLogRequestDto {
  final int timestamp;

  final String message;

  const SaveAppLogRequestDto({
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toJson() => _$SaveAppLogRequestDtoToJson(this);

  factory SaveAppLogRequestDto.fromJson(Map<String, dynamic> json) => _$SaveAppLogRequestDtoFromJson(json);
}
