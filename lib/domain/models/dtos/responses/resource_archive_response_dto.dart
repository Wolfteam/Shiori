import 'package:json_annotation/json_annotation.dart';

part 'resource_archive_response_dto.g.dart';

@JsonSerializable()
class ResourceArchiveResponseDto {
  final int version;

  final String keyName;

  final int sizeInBytes;

  final String sha256;

  /// Left as an int so an archive written by a newer CLI deserializes instead of throwing.
  final int contractVersion;

  ResourceArchiveResponseDto({
    required this.version,
    required this.keyName,
    required this.sizeInBytes,
    required this.sha256,
    required this.contractVersion,
  });

  factory ResourceArchiveResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ResourceArchiveResponseDtoFromJson(json);
}
