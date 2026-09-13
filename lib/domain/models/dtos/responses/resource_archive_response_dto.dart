import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource_archive_response_dto.freezed.dart';
part 'resource_archive_response_dto.g.dart';

@freezed
abstract class ResourceArchiveResponseDto with _$ResourceArchiveResponseDto {
  factory ResourceArchiveResponseDto({
    required int version,
    required String keyName,
    required int sizeInBytes,
    required String sha256,
    //Left as an int so an archive written by a newer CLI deserializes instead of throwing
    required int contractVersion,
  }) = _ResourceArchiveResponseDto;

  factory ResourceArchiveResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ResourceArchiveResponseDtoFromJson(json);
}
