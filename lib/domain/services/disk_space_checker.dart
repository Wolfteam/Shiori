/// Free-space queries for the resource updater.
///
/// Returning null means the free space could not be determined; callers must treat that as
/// "carry on" rather than as a failure, because the OS write error is the authoritative check.
abstract class DiskSpaceChecker {
  Future<int?> freeBytesFor(String path);
}
