import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Taken from
// https://github.com/firebase/flutterfire/blob/e00fafcb626225901ae02abb3fe90775c86274fb/packages/firebase_messaging/firebase_messaging/test/mock.dart

typedef Callback = Function(MethodCall call);

const String kTestString = 'Hello World';

final MockFirebaseMessaging kMockMessagingPlatform = MockFirebaseMessaging();

Future<T> neverEndingFuture<T>() async {
  // ignore: literal_only_boolean_expressions
  while (true) {
    await Future.delayed(const Duration(minutes: 5));
  }
}

void setupFirebaseMessagingMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  // Mock Platform Interface Methods
  // ignore: invalid_use_of_protected_member
  when(kMockMessagingPlatform.delegateFor(app: anyNamed('app'))).thenReturn(kMockMessagingPlatform);
  // ignore: invalid_use_of_protected_member
  when(
    kMockMessagingPlatform.setInitialValues(
      isAutoInitEnabled: anyNamed('isAutoInitEnabled'),
    ),
  ).thenReturn(kMockMessagingPlatform);
}

// Platform Interface Mock Classes

// FirebaseMessagingPlatform Mock
class MockFirebaseMessaging extends Mock with MockPlatformInterfaceMixin implements FirebaseMessagingPlatform {
  MockFirebaseMessaging() {
    TestFirebaseMessagingPlatform();
  }

  @override
  bool get isAutoInitEnabled {
    return super.noSuchMethod(Invocation.getter(#isAutoInitEnabled), returnValue: true, returnValueForMissingStub: true) as bool;
  }

  @override
  Future<bool> isSupported() {
    return Future.value(false);
  }

  @override
  FirebaseMessagingPlatform delegateFor({FirebaseApp? app}) {
    return super.noSuchMethod(
          Invocation.method(#delegateFor, [], {#app: app}),
          returnValue: TestFirebaseMessagingPlatform(),
          returnValueForMissingStub: TestFirebaseMessagingPlatform(),
        )
        as FirebaseMessagingPlatform;
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) {
    return super.noSuchMethod(
          Invocation.method(#setInitialValues, [], {#isAutoInitEnabled: isAutoInitEnabled}),
          returnValue: TestFirebaseMessagingPlatform(),
          returnValueForMissingStub: TestFirebaseMessagingPlatform(),
        )
        as FirebaseMessagingPlatform;
  }

  @override
  Future<RemoteMessage?> getInitialMessage() {
    return super.noSuchMethod(
          Invocation.method(#getInitialMessage, []),
          returnValue: neverEndingFuture<RemoteMessage>(),
          returnValueForMissingStub: neverEndingFuture<RemoteMessage>(),
        )
        as Future<RemoteMessage?>;
  }

  @override
  Future<void> deleteToken() {
    return super.noSuchMethod(
          Invocation.method(#deleteToken, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value(),
        )
        as Future<void>;
  }

  @override
  Future<String?> getAPNSToken() {
    return super.noSuchMethod(
          Invocation.method(#getAPNSToken, []),
          returnValue: Future<String>.value(''),
          returnValueForMissingStub: Future<String>.value(''),
        )
        as Future<String?>;
  }

  @override
  Future<String> getToken({String? vapidKey}) {
    return super.noSuchMethod(
          Invocation.method(#getToken, [], {#vapidKey: vapidKey}),
          returnValue: Future<String>.value(''),
          returnValueForMissingStub: Future<String>.value(''),
        )
        as Future<String>;
  }

  @override
  Future<void> setAutoInitEnabled(bool? enabled) {
    return super.noSuchMethod(
          Invocation.method(#setAutoInitEnabled, [enabled]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value(),
        )
        as Future<void>;
  }

  @override
  Stream<String> get onTokenRefresh {
    return super.noSuchMethod(
          Invocation.getter(#onTokenRefresh),
          returnValue: const Stream<String>.empty(),
          returnValueForMissingStub: const Stream<String>.empty(),
        )
        as Stream<String>;
  }

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) {
    return super.noSuchMethod(
          Invocation.method(#requestPermission, [], {
            #alert: alert,
            #announcement: announcement,
            #badge: badge,
            #carPlay: carPlay,
            #criticalAlert: criticalAlert,
            #provisional: provisional,
            #sound: sound,
            #providesAppNotificationSettings: providesAppNotificationSettings,
          }),
          returnValue: neverEndingFuture<NotificationSettings>(),
          returnValueForMissingStub: neverEndingFuture<NotificationSettings>(),
        )
        as Future<NotificationSettings>;
  }

  @override
  Future<void> subscribeToTopic(String? topic) {
    return super.noSuchMethod(
          Invocation.method(#subscribeToTopic, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value(),
        )
        as Future<void>;
  }

  @override
  Future<void> unsubscribeFromTopic(String? topic) {
    return super.noSuchMethod(
          Invocation.method(#unsubscribeFromTopic, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value(),
        )
        as Future<void>;
  }
}

class TestFirebaseMessagingPlatform extends FirebaseMessagingPlatform {
  TestFirebaseMessagingPlatform() : super();
}
