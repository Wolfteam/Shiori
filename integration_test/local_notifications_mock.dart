import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Intercepts the `flutter_local_notifications` platform channel so the integration tests never hit
/// the real OS. Creating a scheduled notification otherwise calls `requestExactAlarmsPermission()`,
/// which on Android 14+ launches the system Settings screen — pushing the app out of the Flutter tree
/// and breaking the notification tests. Unlike `permission_handler`/Firebase this plugin has no
/// swappable platform-interface instance, so we mock its method channel directly.
///
/// Permission/capability queries return granted; scheduling/query calls are harmless no-ops. The app's
/// notification tiles come from its own persisted data, not the plugin, so nothing on screen is lost.
void setupLocalNotificationsMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('dexterous.com/flutter/local_notifications');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall call) async {
      switch (call.method) {
        case 'requestExactAlarmsPermission':
        case 'requestNotificationsPermission':
        case 'requestFullScreenIntentPermission':
        case 'requestPermissions':
        case 'canScheduleExactNotifications':
        case 'areNotificationsEnabled':
        case 'initialize':
          return true;
        case 'pendingNotificationRequests':
        case 'getActiveNotifications':
          return <dynamic>[];
        default:
          return null;
      }
    },
  );
}
