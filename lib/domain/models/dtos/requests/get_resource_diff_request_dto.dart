import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/models/dtos/requests/base_request_dto.dart';

part 'get_resource_diff_request_dto.g.dart';

@JsonSerializable()
class GetResourceDiffRequestDto extends BaseRequestDto {
  final int? targetVersion;

  const GetResourceDiffRequestDto({
    required super.appVersion,
    required super.currentVersion,
    this.targetVersion,
  });

  @override
  Map<String, dynamic> toJson() => _$GetResourceDiffRequestDtoToJson(this);
}
