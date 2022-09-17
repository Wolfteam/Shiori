import 'package:json_annotation/json_annotation.dart';

part 'resource_diff_response_dto.g.dart';

@JsonSerializable()
class ResourceDiffResponseDto {
  final int currentResourceVersion;

  final int targetResourceVersion;

  final String? jsonFileKeyName;

  final List<String> keyNames;

  ResourceDiffResponseDto({
    required this.currentResourceVersion,
    required this.targetResourceVersion,
    this.jsonFileKeyName,
    required this.keyNames,
  });

  factory ResourceDiffResponseDto.fromJson(Map<String, dynamic> json) => _$ResourceDiffResponseDtoFromJson(json);
}
