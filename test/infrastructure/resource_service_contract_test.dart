import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';

import '../common.dart';
import '../mocks.mocks.dart';

void main() {
  ResourceDiffResponseDto deltaResponse() => ResourceDiffResponseDto(
    currentResourceVersion: 120,
    targetResourceVersion: 122,
    downloadTotalSize: 30,
    keyNames: const <String>[],
    mode: ResourceUpdateMode.delta.value,
    archives: [
      ResourceArchiveResponseDto(
        version: 122,
        keyName: 'versions/v122/delta.zip',
        sizeInBytes: 30,
        sha256: 'aaa',
        contractVersion: 2,
      ),
    ],
  );

  MockSettingsService settingsServiceAt(int version) {
    final settingsService = MockSettingsService();
    when(settingsService.resourceVersion).thenReturn(version);
    when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
    when(settingsService.lastResourcesCheckedDate).thenReturn(null);
    return settingsService;
  }

  MockApiService apiServiceReturning(ResourceDiffResponseDto response) {
    final apiService = MockApiService();
    when(apiService.checkForUpdates(any, any)).thenAnswer(
      (_) async => ApiResponseDto<ResourceDiffResponseDto?>(succeed: true, result: response),
    );
    return apiService;
  }

  MockNetworkService onlineNetworkService() {
    final networkService = MockNetworkService();
    when(networkService.isInternetAvailable()).thenAnswer((_) async => true);
    return networkService;
  }

  test('an archive-only response yields updatesAvailable with the archives attached', () async {
    final service = getResourceServiceWith(
      settingsServiceAt(120),
      onlineNetworkService(),
      apiServiceReturning(deltaResponse()),
    );

    final result = await service.checkForUpdates('1.8.0', 120);

    expect(result.type, AppResourceUpdateResultType.updatesAvailable);
    expect(result.mode, ResourceUpdateMode.delta);
    expect(result.archives.single.keyName, 'versions/v122/delta.zip');
    expect(result.resourceVersion, 122);
  });

  test('a legacy per-file response still reports legacy mode and no archives', () async {
    final response = ResourceDiffResponseDto(
      currentResourceVersion: 120,
      targetResourceVersion: 122,
      downloadTotalSize: 500,
      keyNames: const ['versions/v122/db/characters.1.json'],
    );

    final service = getResourceServiceWith(
      settingsServiceAt(120),
      onlineNetworkService(),
      apiServiceReturning(response),
    );

    final result = await service.checkForUpdates('1.8.0', 120);

    expect(result.type, AppResourceUpdateResultType.updatesAvailable);
    expect(result.mode, ResourceUpdateMode.legacy);
    expect(result.archives, isEmpty);
    expect(result.keyNames.single, 'versions/v122/db/characters.1.json');
  });

  test('an unknown mode from a newer backend degrades to legacy', () async {
    final response = ResourceDiffResponseDto(
      currentResourceVersion: 120,
      targetResourceVersion: 122,
      downloadTotalSize: 30,
      keyNames: const <String>[],
      mode: 99,
      archives: [
        ResourceArchiveResponseDto(
          version: 122,
          keyName: 'versions/v122/delta.zip',
          sizeInBytes: 30,
          sha256: 'aaa',
          contractVersion: 2,
        ),
      ],
    );

    final service = getResourceServiceWith(
      settingsServiceAt(120),
      onlineNetworkService(),
      apiServiceReturning(response),
    );

    final result = await service.checkForUpdates('1.8.0', 120);

    //Falling back rather than throwing is what lets an old build survive a backend that moved on
    expect(result.mode, ResourceUpdateMode.legacy);
  });

  test('a response with neither files nor archives reports no updates', () async {
    final response = ResourceDiffResponseDto(
      currentResourceVersion: 120,
      targetResourceVersion: 122,
      keyNames: const <String>[],
    );

    final service = getResourceServiceWith(
      settingsServiceAt(120),
      onlineNetworkService(),
      apiServiceReturning(response),
    );

    final result = await service.checkForUpdates('1.8.0', 120);

    expect(result.type, AppResourceUpdateResultType.noUpdatesAvailable);
    expect(result.resourceVersion, 120);
  });
}
