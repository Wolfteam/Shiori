import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/models.dart';

import '../common.dart';
import '../mocks.mocks.dart';

void main() {
  ResourceArchiveResponseDto archive() => ResourceArchiveResponseDto(
    version: 122,
    keyName: 'versions/v122/delta.zip',
    sizeInBytes: 30,
    sha256: 'aaa',
    contractVersion: 2,
  );

  MockSettingsService settingsServiceAt(int version, {bool noResourcesHasBeenDownloaded = false}) {
    final settingsService = MockSettingsService();
    when(settingsService.resourceVersion).thenReturn(version);
    when(settingsService.noResourcesHasBeenDownloaded).thenReturn(noResourcesHasBeenDownloaded);
    when(settingsService.lastResourcesCheckedDate).thenReturn(null);
    return settingsService;
  }

  MockResourceArchiveService archiveServiceReturning(ArchiveApplyResult result) {
    final archiveService = MockResourceArchiveService();
    when(
      archiveService.downloadAndApply(
        any,
        any,
        any,
        replaceAssetsFolder: anyNamed('replaceAssetsFolder'),
        onProgress: anyNamed('onProgress'),
      ),
    ).thenAnswer((_) async => result);
    return archiveService;
  }

  test('delta mode delegates to the archive service and overlays the assets folder', () async {
    final settingsService = settingsServiceAt(120);
    final archiveService = archiveServiceReturning(
      const ArchiveApplyResult(failureType: AppResourceUpdateFailureType.none, bytesDownloaded: 30),
    );
    final service = getResourceServiceWithArchives(settingsService, archiveService);

    final applied = await service.downloadAndApplyUpdates(
      122,
      null,
      archives: [archive()],
      mode: ResourceUpdateMode.delta,
    );

    expect(applied.applied, isTrue);
    expect(applied.failureType, AppResourceUpdateFailureType.none);
    expect(applied.bytesDownloaded, 30);
    verify(
      archiveService.downloadAndApply(any, any, any, replaceAssetsFolder: false, onProgress: anyNamed('onProgress')),
    ).called(1);
    //Both settings move together, through the shared helper
    verify(settingsService.markResourcesAsUpdated(122)).called(1);
  });

  test('full mode replaces the assets folder', () async {
    final settingsService = settingsServiceAt(0, noResourcesHasBeenDownloaded: true);
    final archiveService = archiveServiceReturning(
      const ArchiveApplyResult(failureType: AppResourceUpdateFailureType.none, bytesDownloaded: 999),
    );
    final service = getResourceServiceWithArchives(settingsService, archiveService);

    final applied = await service.downloadAndApplyUpdates(
      122,
      null,
      archives: [archive()],
      mode: ResourceUpdateMode.full,
    );

    expect(applied.applied, isTrue);
    verify(
      archiveService.downloadAndApply(any, any, any, replaceAssetsFolder: true, onProgress: anyNamed('onProgress')),
    ).called(1);
  });

  test('a failed archive apply does not bump the resource version', () async {
    final settingsService = settingsServiceAt(120);
    final archiveService = archiveServiceReturning(
      const ArchiveApplyResult(failureType: AppResourceUpdateFailureType.checksumMismatch, bytesDownloaded: 30),
    );
    final service = getResourceServiceWithArchives(settingsService, archiveService);

    final applied = await service.downloadAndApplyUpdates(
      122,
      null,
      archives: [archive()],
      mode: ResourceUpdateMode.delta,
    );

    //The failing stage must survive all the way out, that is the whole point of the result object
    expect(applied.applied, isFalse);
    expect(applied.failureType, AppResourceUpdateFailureType.checksumMismatch);
    expect(applied.bytesDownloaded, 30);
    verifyNever(settingsService.markResourcesAsUpdated(any));
  });

  test('a legacy call with no archives never touches the archive service', () async {
    final settingsService = settingsServiceAt(120);
    final archiveService = archiveServiceReturning(
      const ArchiveApplyResult(failureType: AppResourceUpdateFailureType.none, bytesDownloaded: 0),
    );
    //Offline so the legacy path bails at its own guard instead of attempting real downloads;
    //what this asserts is which path was taken, not how far it got
    final service = getResourceServiceWithArchives(settingsService, archiveService, isInternetAvailable: false);

    final applied = await service.downloadAndApplyUpdates(122, null, keyNames: const ['characters/keqing.webp']);

    expect(applied.applied, isFalse);

    verifyNever(
      archiveService.downloadAndApply(
        any,
        any,
        any,
        replaceAssetsFolder: anyNamed('replaceAssetsFolder'),
        onProgress: anyNamed('onProgress'),
      ),
    );
  });

  test('archives alone satisfy the "something to download" guard', () async {
    final settingsService = settingsServiceAt(120);
    final archiveService = archiveServiceReturning(
      const ArchiveApplyResult(failureType: AppResourceUpdateFailureType.none, bytesDownloaded: 30),
    );
    final service = getResourceServiceWithArchives(settingsService, archiveService);

    //Neither a jsonFileKeyName nor keyNames are provided, which used to throw
    final applied = await service.downloadAndApplyUpdates(
      122,
      null,
      archives: [archive()],
      mode: ResourceUpdateMode.delta,
    );

    expect(applied.applied, isTrue);
  });
}
