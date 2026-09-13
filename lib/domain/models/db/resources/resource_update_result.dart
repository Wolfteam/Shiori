import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'resource_update_result.freezed.dart';

/// The outcome of applying a resource update. Carries the failing stage so telemetry can attribute
/// a regression instead of only recording that something went wrong.
@freezed
abstract class ResourceUpdateResult with _$ResourceUpdateResult {
  const factory ResourceUpdateResult({
    required bool applied,
    required AppResourceUpdateFailureType failureType,
    required int bytesDownloaded,
  }) = _ResourceUpdateResult;

  const ResourceUpdateResult._();

  factory ResourceUpdateResult.success(int bytes) => ResourceUpdateResult(
    applied: true,
    failureType: AppResourceUpdateFailureType.none,
    bytesDownloaded: bytes,
  );

  factory ResourceUpdateResult.failure(AppResourceUpdateFailureType type, [int bytes = 0]) =>
      ResourceUpdateResult(applied: false, failureType: type, bytesDownloaded: bytes);
}
