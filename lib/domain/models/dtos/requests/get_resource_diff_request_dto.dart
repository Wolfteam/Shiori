import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/models/dtos/requests/base_request_dto.dart';

part 'get_resource_diff_request_dto.g.dart';

@JsonSerializable()
class GetResourceDiffRequestDto extends BaseRequestDto {
  final int? targetVersion;

  /// The response contract this build understands. Defaults to 1 so an older caller keeps getting
  /// the per-file response.
  final int contractVersion;

  const GetResourceDiffRequestDto({
    required super.appVersion,
    required super.currentVersion,
    this.targetVersion,
    this.contractVersion = 1,
  });

  @override
  Map<String, dynamic> toJson() => _$GetResourceDiffRequestDtoToJson(this);
}
