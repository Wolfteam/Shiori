import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/models/dtos/responses/resource_archive_response_dto.dart';

part 'resource_diff_response_dto.g.dart';

@JsonSerializable()
class ResourceDiffResponseDto {
  final int currentResourceVersion;

  final int targetResourceVersion;

  final int? downloadTotalSize;

  final String? jsonFileKeyName;

  final List<String> keyNames;

  /// ResourceUpdateMode wire value. Defaults to legacy so a pre-archive backend parses.
  final int mode;

  final List<ResourceArchiveResponseDto> archives;

  ResourceDiffResponseDto({
    required this.currentResourceVersion,
    required this.targetResourceVersion,
    this.downloadTotalSize,
    this.jsonFileKeyName,
    required this.keyNames,
    this.mode = 1,
    this.archives = const <ResourceArchiveResponseDto>[],
  });

  factory ResourceDiffResponseDto.fromJson(Map<String, dynamic> json) => _$ResourceDiffResponseDtoFromJson(json);
}
