import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'archive_apply_result.freezed.dart';

@freezed
abstract class ArchiveApplyResult with _$ArchiveApplyResult {
  const factory ArchiveApplyResult({
    required AppResourceUpdateFailureType failureType,
    required int bytesDownloaded,
  }) = _ArchiveApplyResult;

  const ArchiveApplyResult._();

  bool get succeed => failureType == AppResourceUpdateFailureType.none;
}
