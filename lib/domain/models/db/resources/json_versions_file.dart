import 'package:json_annotation/json_annotation.dart';

part 'json_versions_file.g.dart';

@JsonSerializable()
class JsonVersionsFile {
  @JsonKey(name: 'AppVersion')
  final String appVersion;

  @JsonKey(name: 'Version')
  final int version;

  @JsonKey(name: 'KeyNames')
  final List<String> keyNames;

  JsonVersionsFile({
    required this.appVersion,
    required this.version,
    required this.keyNames,
  });

  factory JsonVersionsFile.fromJson(Map<String, dynamic> json) => _$JsonVersionsFileFromJson(json);
}
