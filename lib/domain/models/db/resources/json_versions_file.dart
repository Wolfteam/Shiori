import 'package:json_annotation/json_annotation.dart';

part 'json_versions_file.g.dart';

@JsonSerializable()
class JsonVersionsFile {
  final String appVersion;

  final int version;

  final List<String> keyNames;

  JsonVersionsFile({
    required this.appVersion,
    required this.version,
    required this.keyNames,
  });

  factory JsonVersionsFile.fromJson(Map<String, dynamic> json) => _$JsonVersionsFileFromJson(json);
}
