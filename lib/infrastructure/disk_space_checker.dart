import 'package:disk_space_info/disk_space_info.dart';
import 'package:shiori/domain/services/disk_space_checker.dart';

/// Queries free space via dart:ffi — statvfs on Darwin/Linux/Android, GetDiskFreeSpaceExW on Windows.
///
/// The package already answers null for an unreadable path, an unsupported platform or an OS-level
/// failure, which is the "unknown, carry on" case the updater expects, so nothing is mapped here.
class DiskSpaceInfoChecker implements DiskSpaceChecker {
  const DiskSpaceInfoChecker();

  @override
  Future<int?> freeBytesFor(String path) async {
    final info = await DiskSpaceInfo.query(path);
    return info?.freeBytes;
  }
}
