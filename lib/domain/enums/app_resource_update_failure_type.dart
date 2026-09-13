/// Which stage of an update failed. Reported via telemetry so a regression can be attributed to a
/// stage instead of just "the update failed".
enum AppResourceUpdateFailureType {
  none,
  downloadFailed,
  checksumMismatch,
  extractFailed,
  manifestMismatch,
  insufficientDiskSpace,
  unknown,
}
