import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/dtos/responses/resource_archive_response_dto.dart';

part 'resource_diff_response_dto.freezed.dart';
part 'resource_diff_response_dto.g.dart';

@freezed
abstract class ResourceDiffResponseDto with _$ResourceDiffResponseDto {
  factory ResourceDiffResponseDto({
    required int currentResourceVersion,
    required int targetResourceVersion,
    int? downloadTotalSize,
    String? jsonFileKeyName,
    required List<String> keyNames,
    //ResourceUpdateMode wire value. Defaults to legacy so a pre-archive backend parses
    @Default(1) int mode,
    @Default(<ResourceArchiveResponseDto>[]) List<ResourceArchiveResponseDto> archives,
  }) = _ResourceDiffResponseDto;

  factory ResourceDiffResponseDto.fromJson(Map<String, dynamic> json) => _$ResourceDiffResponseDtoFromJson(json);
}
