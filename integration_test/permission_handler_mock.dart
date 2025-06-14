import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionHandler extends Mock with MockPlatformInterfaceMixin implements PermissionHandlerPlatform {
  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.granted;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) {
    final map = Map.fromEntries(permissions.map((p) => MapEntry(p, PermissionStatus.granted)));
    return Future.value(map);
  }
}
