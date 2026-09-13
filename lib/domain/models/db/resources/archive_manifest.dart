import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'archive_manifest.freezed.dart';
part 'archive_manifest.g.dart';

@freezed
abstract class ArchiveManifestFile with _$ArchiveManifestFile {
  factory ArchiveManifestFile({
    required String path,
    required int size,
    required String sha256,
  }) = _ArchiveManifestFile;

  factory ArchiveManifestFile.fromJson(Map<String, dynamic> json) => _$ArchiveManifestFileFromJson(json);
}

@freezed
abstract class ArchiveManifest with _$ArchiveManifest {
  factory ArchiveManifest({
    required int contractVersion,
    required int version,
    required String appVersion,
    required int mode,
    required List<ArchiveManifestFile> files,
    @Default(<String>[]) List<String> deleted,
  }) = _ArchiveManifest;

  ArchiveManifest._();

  /// An archive written by a newer CLI must be rejected rather than half-applied.
  bool get isSupported => contractVersion <= appResourceContractVersion.value;

  factory ArchiveManifest.fromJson(Map<String, dynamic> json) => _$ArchiveManifestFromJson(json);
}
