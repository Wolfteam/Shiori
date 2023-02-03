import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

void main() {
  late final String backupDirPath;

  final settings = AppSettings(
    appTheme: AppThemeType.dark,
    useDarkAmoled: false,
    accentColor: AppAccentColorType.blue,
    appLanguage: AppLanguageType.english,
    showCharacterDetails: true,
    showWeaponDetails: true,
    isFirstInstall: true,
    serverResetTime: AppServerResetTimeType.northAmerica,
    doubleBackToClose: true,
    useOfficialMap: false,
    useTwentyFourHoursFormat: true,
    resourceVersion: 1,
  );

  final inventoryData = [
    BackupInventoryModel(type: ItemType.character.index, quantity: 1, itemKey: 'keqing'),
    BackupInventoryModel(type: ItemType.weapon.index, quantity: 1, itemKey: 'the-flute'),
    BackupInventoryModel(type: ItemType.material.index, quantity: 13, itemKey: 'crown-of-insight'),
  ];

  final calAscMatData = [
    BackupCalculatorAscMaterialsSessionModel(
      name: 'Keqing Pro',
      position: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      items: const [
        BackupCalculatorAscMaterialsSessionItemModel(
          itemKey: 'keqing',
          currentLevel: 1,
          desiredLevel: 80,
          position: 0,
          useMaterialsFromInventory: true,
          isWeapon: false,
          isCharacter: true,
          isActive: true,
          currentAscensionLevel: 1,
          desiredAscensionLevel: 5,
          characterSkills: [
            BackupCalculatorAscMaterialsSessionCharSkillItemModel(position: 0, currentLevel: 1, desiredLevel: 7, skillKey: 's1'),
          ],
        ),
        BackupCalculatorAscMaterialsSessionItemModel(
          itemKey: 'the-flute',
          currentLevel: 20,
          desiredLevel: 70,
          position: 1,
          useMaterialsFromInventory: true,
          isWeapon: true,
          isCharacter: false,
          isActive: true,
          currentAscensionLevel: 1,
          desiredAscensionLevel: 4,
        )
      ],
    ),
  ];

  const tierListData = [
    BackupTierListModel(
      position: 0,
      color: 12344,
      charKeys: ['keqing', 'ganyu'],
      text: 'SSS',
    ),
    BackupTierListModel(
      position: 0,
      color: 12344,
      charKeys: ['traveler-anemo', 'traveler-geo'],
      text: 'D',
    ),
  ];

  final customBuildsData = [
    BackupCustomBuildModel(
      title: 'Keqing DPS',
      roleType: CharacterRoleType.dps.index,
      roleSubType: CharacterRoleSubType.electro.index,
      characterKey: 'keqing',
      skillPriorities: [1, 2, 3],
      showOnCharacterDetail: true,
      isRecommended: true,
      notes: const [
        BackupCustomBuildNoteModel(note: 'Besto girl', index: 0),
      ],
      weapons: const [
        BackupCustomBuildWeaponModel(
          index: 0,
          refinement: 5,
          weaponKey: 'the-flute',
          level: 80,
          isAnAscension: true,
        ),
      ],
      artifacts: [
        BackupCustomBuildArtifactModel(
          itemKey: 'thundering-fury',
          type: ArtifactType.flower.index,
          statType: StatType.hp.index,
          subStats: [
            StatType.critDmgPercentage.index,
            StatType.critRatePercentage.index,
            StatType.atkPercentage.index,
          ],
        ),
        BackupCustomBuildArtifactModel(
          itemKey: 'thundering-fury',
          type: ArtifactType.plume.index,
          statType: StatType.atk.index,
          subStats: [
            StatType.critDmgPercentage.index,
            StatType.critRatePercentage.index,
            StatType.elementalMastery.index,
          ],
        ),
        BackupCustomBuildArtifactModel(
          itemKey: 'thundering-fury',
          type: ArtifactType.clock.index,
          statType: StatType.atkPercentage.index,
          subStats: [
            StatType.critDmgPercentage.index,
            StatType.critRatePercentage.index,
            StatType.elementalMastery.index,
          ],
        ),
        BackupCustomBuildArtifactModel(
          itemKey: 'thundering-fury',
          type: ArtifactType.goblet.index,
          statType: StatType.electroDmgBonusPercentage.index,
          subStats: [
            StatType.critDmgPercentage.index,
            StatType.critRatePercentage.index,
            StatType.atkPercentage.index,
          ],
        ),
        BackupCustomBuildArtifactModel(
          itemKey: 'thundering-fury',
          type: ArtifactType.crown.index,
          statType: StatType.critRatePercentage.index,
          subStats: [
            StatType.critDmgPercentage.index,
            StatType.critRatePercentage.index,
            StatType.atkPercentage.index,
          ],
        ),
      ],
      team: [
        BackupCustomBuildTeamCharacterModel(
          index: 0,
          characterKey: 'fischl',
          roleType: CharacterRoleType.subDps.index,
          subType: CharacterRoleSubType.electro.index,
        ),
        BackupCustomBuildTeamCharacterModel(
          index: 1,
          characterKey: 'nahida',
          roleType: CharacterRoleType.support.index,
          subType: CharacterRoleSubType.dendro.index,
        ),
        BackupCustomBuildTeamCharacterModel(
          index: 2,
          characterKey: 'zhongli',
          roleType: CharacterRoleType.support.index,
          subType: CharacterRoleSubType.none.index,
        ),
      ],
    ),
  ];

  final notificationsData = BackupNotificationsModel(
    custom: [
      BackupCustomNotificationModel(
        title: 'custom',
        note: 'custom note',
        body: 'The custom body',
        type: AppNotificationType.custom.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 10)),
        notificationItemType: AppNotificationItemType.character.index,
        itemKey: 'keqing',
      ),
    ],
    expeditions: [
      BackupExpeditionNotificationModel(
        title: 'expedition',
        note: 'expedition note',
        body: 'The expedition body',
        type: AppNotificationType.expedition.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 9)),
        itemKey: 'mora',
        withTimeReduction: true,
        expeditionTimeType: ExpeditionTimeType.fourHours.index,
      ),
    ],
    farmingArtifact: [
      BackupFarmingArtifactNotificationModel(
        title: 'farming artifact',
        note: 'farming artifact note',
        body: 'The farming artifact body',
        type: AppNotificationType.farmingArtifacts.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 8)),
        itemKey: 'thundering-fury',
        artifactFarmingTimeType: ArtifactFarmingTimeType.twelveHours.index,
      ),
    ],
    farmingMaterial: [
      BackupFarmingMaterialNotificationModel(
        title: 'farming material',
        note: 'farming material note',
        body: 'The farming material body',
        type: AppNotificationType.farmingMaterials.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 7)),
        itemKey: 'valberry',
      ),
    ],
    furniture: [
      BackupFurnitureNotificationModel(
        title: 'furniture',
        note: 'furniture note',
        body: 'The furniture body',
        type: AppNotificationType.furniture.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 6)),
        itemKey: 'na',
        furnitureCraftingTimeType: FurnitureCraftingTimeType.sixteenHours.index,
      ),
    ],
    gadgets: [
      BackupGadgetNotificationModel(
        title: 'gadget',
        note: 'gadget note',
        body: 'The gadget body',
        type: AppNotificationType.gadget.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 5)),
        itemKey: 'parametric-transport',
      ),
    ],
    realmCurrency: [
      BackupRealmCurrencyNotificationModel(
        title: 'realm currency',
        note: 'realm currency note',
        body: 'The realm currency body',
        type: AppNotificationType.realmCurrency.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 4)),
        itemKey: 'realm-currency',
        realmTrustRank: 10,
        realmRankType: RealmRankType.luxury.index,
        realmCurrency: 110,
      ),
    ],
    resin: [
      BackupResinNotificationModel(
        title: 'resin',
        note: 'resin note',
        body: 'The resin body',
        type: AppNotificationType.resin.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 3)),
        itemKey: 'fragile-resin',
        currentResinValue: 19,
      ),
    ],
    weeklyBosses: [
      BackupWeeklyBossNotificationModel(
        title: 'weekly boss',
        note: 'weekly boss note',
        body: 'The weekly boss body',
        type: AppNotificationType.weeklyBoss.index,
        showNotification: true,
        completesAt: DateTime.now().add(const Duration(days: 2)),
        itemKey: 'raiden-shogun',
      ),
    ],
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      final appDir = await Directory.systemTemp.createTemp('backups');
      final dir = Directory(appDir.path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      await dir.create();
      backupDirPath = appDir.path;
    });
  });

  tearDownAll(() {
    return Future(() async {
      await deleteDbFolder(backupDirPath);
    });
  });

  BackupRestoreService getService(
    AppSettings appSettings, {
    DataService? dataService,
    NotificationService? notificationService,
  }) {
    final settings = MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    when(settings.resourceVersion).thenReturn(1);
    when(settings.appSettings).thenReturn(appSettings);
    final deviceInfo = MockDeviceInfoService();
    when(deviceInfo.version).thenReturn('1.6.8');
    when(deviceInfo.deviceInfo).thenReturn({'Model': 'Test', 'AppVersion': '1.6.8+37'});
    return BackupRestoreServiceImpl.forTesting(
      MockLoggingService(),
      settings,
      deviceInfo,
      dataService ?? MockDataService(),
      notificationService ?? MockNotificationService(),
      backupDirPath,
    );
  }

  group('Create', () {
    test('backup but no data types are provided', () {
      final service = getService(settings);
      expect(() => service.createBackup([]), throwsA(isA<Exception>()));
    });

    test('backup fails to be created due to exception', () async {
      final dataService = MockDataService();
      final inventory = MockInventoryDataService();
      when(inventory.getDataForBackup()).thenThrow(Exception('Error'));
      when(dataService.inventory).thenThrow(inventory);

      final service = getService(settings, dataService: dataService);
      final dataTypes = [AppBackupDataType.inventory];
      final result = await service.createBackup(dataTypes);
      expect(result.succeed, isFalse);
      expect(result.dataTypes, containsAll(dataTypes));
      expect(result.path, isNotEmpty);
    });

    test('backup gets successfully created', () async {
      final dataService = MockDataService();
      final inventoryMock = MockInventoryDataService();
      when(inventoryMock.getDataForBackup()).thenReturn(inventoryData);
      when(dataService.inventory).thenReturn(inventoryMock);

      final calAscMatMock = MockCalculatorDataService();
      when(calAscMatMock.getDataForBackup()).thenReturn(calAscMatData);
      when(dataService.calculator).thenReturn(calAscMatMock);

      final tierListMock = MockTierListDataService();
      when(tierListMock.getDataForBackup()).thenReturn(tierListData);
      when(dataService.tierList).thenReturn(tierListMock);

      final customBuildsMock = MockCustomBuildsDataService();
      when(customBuildsMock.getDataForBackup()).thenReturn(customBuildsData);
      when(dataService.customBuilds).thenReturn(customBuildsMock);

      final notificationsMock = MockNotificationsDataService();
      when(notificationsMock.getDataForBackup()).thenReturn(notificationsData);
      when(dataService.notifications).thenReturn(notificationsMock);

      final service = getService(settings, dataService: dataService);
      final dataTypes = AppBackupDataType.values.toList();
      final result = await service.createBackup(dataTypes);
      expect(result.succeed, isTrue);
      expect(result.dataTypes, containsAll(dataTypes));
      expect(result.path, isNotEmpty);
      final bk = await service.readBackup(result.path);
      expect(bk, isNotNull);
    });
  });
}
