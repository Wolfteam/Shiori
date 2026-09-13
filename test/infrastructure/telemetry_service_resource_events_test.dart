import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../mocks.mocks.dart';

void main() {
  late MockDeviceInfoService deviceInfoService;
  late MockDataService dataService;
  late MockTelemetryDataService telemetryDataService;
  late TelemetryServiceImpl service;

  setUp(() {
    deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.deviceInfo).thenReturn(<String, String>{});
    when(deviceInfoService.appInfo).thenReturn(<String, String>{});
    //Telemetry is dropped entirely unless the install is trusted
    when(deviceInfoService.installedFromValidSource).thenReturn(true);

    telemetryDataService = MockTelemetryDataService();
    when(telemetryDataService.saveTelemetry(any)).thenAnswer((_) async {});
    dataService = MockDataService();
    when(dataService.telemetry).thenReturn(telemetryDataService);

    final settingsService = MockSettingsService();
    when(settingsService.resourceVersion).thenReturn(122);

    service = TelemetryServiceImpl(deviceInfoService);
    service.init(settingsService, dataService);
  });

  /// trackEventAsync lowercases every property key, so assertions use the lowercased names.
  Map<String, dynamic> capturedEvent() {
    final captured = verify(telemetryDataService.saveTelemetry(captureAny)).captured;
    return captured.single as Map<String, dynamic>;
  }

  test('the check event carries the contract, mode and archive count', () async {
    await service.trackCheckForResourceUpdates(
      AppResourceUpdateResultType.updatesAvailable,
      requestedContractVersion: ResourceContractVersion.v2,
      mode: ResourceUpdateMode.delta,
      archiveCount: 3,
    );

    final event = capturedEvent();
    expect(event['event'], 'Resource_Updates_Check');
    final data = event['data'] as Map<String, dynamic>;
    expect(data['contractversion'], 2);
    expect(data['mode'], 'delta');
    expect(data['archivecount'], 3);
  });

  test('the check event still works without any archive details', () async {
    await service.trackCheckForResourceUpdates(AppResourceUpdateResultType.noUpdatesAvailable);

    final data = capturedEvent()['data'] as Map<String, dynamic>;
    //Absent rather than a misleading zero-ish default, so legacy checks stay distinguishable
    expect(data.containsKey('contractversion'), isFalse);
    expect(data.containsKey('mode'), isFalse);
    expect(data['archivecount'], 0);
  });

  test('the download event carries the mode, archive count and total bytes', () async {
    await service.trackResourceUpdateDownload(
      122,
      mode: ResourceUpdateMode.full,
      archiveCount: 1,
      totalBytes: 152526964,
    );

    final event = capturedEvent();
    expect(event['event'], 'Resource_Updates_Download');
    final data = event['data'] as Map<String, dynamic>;
    expect(data['targetresourceversion'], 122);
    expect(data['contractversion'], appResourceContractVersion.value);
    expect(data['mode'], 'full');
    expect(data['archivecount'], 1);
    expect(data['totalbytes'], 152526964);
  });

  test('the completed event carries the failure type and duration', () async {
    await service.trackResourceUpdateCompleted(
      false,
      122,
      mode: ResourceUpdateMode.full,
      durationMs: 4321,
      bytesDownloaded: 999,
      failureType: AppResourceUpdateFailureType.checksumMismatch,
    );

    final data = capturedEvent()['data'] as Map<String, dynamic>;
    expect(data['applied'], isFalse);
    expect(data['failuretype'], 'checksumMismatch');
    expect(data['durationms'], 4321);
    expect(data['bytesdownloaded'], 999);
    expect(data['mode'], 'full');
  });

  test('a legacy completed event is comparable with an archive one', () async {
    await service.trackResourceUpdateCompleted(true, 122);

    final data = capturedEvent()['data'] as Map<String, dynamic>;
    //The same keys must be present on both paths or the two cannot be compared in the dashboard
    expect(data['mode'], 'legacy');
    expect(data['failuretype'], 'none');
    expect(data['contractversion'], appResourceContractVersion.value);
  });
}
