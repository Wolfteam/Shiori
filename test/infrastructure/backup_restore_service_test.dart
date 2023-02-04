import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
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

  const calAscMatData = [
    BackupCalculatorAscMaterialsSessionModel(
      name: 'Keqing Pro',
      position: 0,
      items: [
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
    SettingsService? settingsService,
    NotificationService? notificationService,
    String appVersion = '1.6.8',
  }) {
    final settings = settingsService ?? MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    when(settings.resourceVersion).thenReturn(1);
    when(settings.appSettings).thenReturn(appSettings);
    final deviceInfo = MockDeviceInfoService();
    when(deviceInfo.version).thenReturn(appVersion);
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

  void checkSettings(AppSettings got, AppSettings expected) {
    expect(got.appTheme, expected.appTheme);
    expect(got.useDarkAmoled, expected.useDarkAmoled);
    expect(got.accentColor, expected.accentColor);
    expect(got.appLanguage, expected.appLanguage);
    expect(got.showCharacterDetails, expected.showCharacterDetails);
    expect(got.showWeaponDetails, expected.showWeaponDetails);
    expect(got.isFirstInstall, expected.isFirstInstall);
    expect(got.serverResetTime, expected.serverResetTime);
    expect(got.doubleBackToClose, expected.doubleBackToClose);
    expect(got.useOfficialMap, expected.useOfficialMap);
    expect(got.useTwentyFourHoursFormat, expected.useTwentyFourHoursFormat);
    expect(got.resourceVersion, expected.resourceVersion);
  }

  void checkInventory(BackupInventoryModel got, BackupInventoryModel expected) {
    expect(got.itemKey, expected.itemKey);
    expect(got.quantity, expected.quantity);
    expect(got.type, expected.type);
  }

  void checkCalAscMatSessionItemSkill(
    BackupCalculatorAscMaterialsSessionCharSkillItemModel got,
    BackupCalculatorAscMaterialsSessionCharSkillItemModel expected,
  ) {
    expect(got.skillKey, expected.skillKey);
    expect(got.currentLevel, expected.currentLevel);
    expect(got.desiredLevel, expected.desiredLevel);
    expect(got.position, expected.position);
  }

  void checkCalAscMatSessionItem(BackupCalculatorAscMaterialsSessionItemModel got, BackupCalculatorAscMaterialsSessionItemModel expected) {
    expect(got.itemKey, expected.itemKey);
    expect(got.position, expected.position);
    expect(got.currentLevel, expected.currentLevel);
    expect(got.desiredLevel, expected.desiredLevel);
    expect(got.currentAscensionLevel, expected.currentAscensionLevel);
    expect(got.desiredAscensionLevel, expected.desiredAscensionLevel);
    expect(got.isCharacter, expected.isCharacter);
    expect(got.isWeapon, expected.isWeapon);
    expect(got.isActive, expected.isActive);
    expect(got.useMaterialsFromInventory, expected.useMaterialsFromInventory);
    expect(got.characterSkills.length, expected.characterSkills.length);
    for (var i = 0; i < expected.characterSkills.length; i++) {
      checkCalAscMatSessionItemSkill(got.characterSkills[i], expected.characterSkills[i]);
    }
  }

  void checkCalAscMatSession(BackupCalculatorAscMaterialsSessionModel got, BackupCalculatorAscMaterialsSessionModel expected) {
    expect(got.name, expected.name);
    expect(got.position, expected.position);
    expect(got.items.length, expected.items.length);
    for (var i = 0; i < expected.items.length; i++) {
      checkCalAscMatSessionItem(got.items[i], expected.items[i]);
    }
  }

  void checkTierList(BackupTierListModel got, BackupTierListModel expected) {
    expect(got.text, expected.text);
    expect(got.color, expected.color);
    expect(got.position, expected.position);
    expect(got.charKeys, expected.charKeys);
  }

  void checkCustomBuildNote(BackupCustomBuildNoteModel got, BackupCustomBuildNoteModel expected) {
    expect(got.index, expected.index);
    expect(got.note, expected.note);
  }

  void checkCustomBuildWeapon(BackupCustomBuildWeaponModel got, BackupCustomBuildWeaponModel expected) {
    expect(got.weaponKey, expected.weaponKey);
    expect(got.index, expected.index);
    expect(got.refinement, expected.refinement);
    expect(got.level, expected.level);
    expect(got.isAnAscension, expected.isAnAscension);
  }

  void checkCustomBuildArtifact(BackupCustomBuildArtifactModel got, BackupCustomBuildArtifactModel expected) {
    expect(got.itemKey, expected.itemKey);
    expect(got.type, expected.type);
    expect(got.statType, expected.statType);
    expect(got.subStats, expected.subStats);
  }

  void checkCustomBuildTeam(BackupCustomBuildTeamCharacterModel got, BackupCustomBuildTeamCharacterModel expected) {
    expect(got.index, expected.index);
    expect(got.characterKey, expected.characterKey);
    expect(got.roleType, expected.roleType);
    expect(got.subType, expected.subType);
  }

  void checkCustomBuild(BackupCustomBuildModel got, BackupCustomBuildModel expected) {
    expect(got.characterKey, expected.characterKey);
    expect(got.showOnCharacterDetail, expected.showOnCharacterDetail);
    expect(got.title, expected.title);
    expect(got.roleType, expected.roleType);
    expect(got.roleSubType, expected.roleSubType);
    expect(got.skillPriorities, expected.skillPriorities);
    expect(got.isRecommended, expected.isRecommended);
    expect(got.notes.length, expected.notes.length);
    for (var i = 0; i < expected.notes.length; i++) {
      checkCustomBuildNote(got.notes[i], expected.notes[i]);
    }
    expect(got.weapons.length, expected.weapons.length);
    for (var i = 0; i < expected.weapons.length; i++) {
      checkCustomBuildWeapon(got.weapons[i], expected.weapons[i]);
    }
    expect(got.artifacts.length, expected.artifacts.length);
    for (var i = 0; i < expected.artifacts.length; i++) {
      checkCustomBuildArtifact(got.artifacts[i], expected.artifacts[i]);
    }
    expect(got.team.length, expected.team.length);
    for (var i = 0; i < expected.team.length; i++) {
      checkCustomBuildTeam(got.team[i], expected.team[i]);
    }
  }

  void checkNotification(BaseBackupNotificationModel got, BaseBackupNotificationModel expected) {
    expect(got.itemKey, expected.itemKey);
    expect(got.completesAt, expected.completesAt);
    expect(got.note, expected.note);
    expect(got.showNotification, expected.showNotification);
    expect(got.title, expected.title);
    expect(got.body, expected.body);
    expect(got.type, expected.type);
  }

  void checkCustomNotification(BackupCustomNotificationModel got, BackupCustomNotificationModel expected) {
    checkNotification(got, expected);
    expect(got.notificationItemType, expected.notificationItemType);
  }

  void checkExpeditionNotification(BackupExpeditionNotificationModel got, BackupExpeditionNotificationModel expected) {
    checkNotification(got, expected);
    expect(got.expeditionTimeType, expected.expeditionTimeType);
    expect(got.withTimeReduction, expected.withTimeReduction);
  }

  void checkFarmingArtifactNotification(BackupFarmingArtifactNotificationModel got, BackupFarmingArtifactNotificationModel expected) {
    checkNotification(got, expected);
    expect(got.artifactFarmingTimeType, expected.artifactFarmingTimeType);
  }

  void checkFarmingMaterialNotification(BackupFarmingMaterialNotificationModel got, BackupFarmingMaterialNotificationModel expected) {
    checkNotification(got, expected);
  }

  void checkFurnitureNotification(BackupFurnitureNotificationModel got, BackupFurnitureNotificationModel expected) {
    checkNotification(got, expected);
    expect(got.furnitureCraftingTimeType, expected.furnitureCraftingTimeType);
  }

  void checkGadgetNotification(BackupGadgetNotificationModel got, BackupGadgetNotificationModel expected) {
    checkNotification(got, expected);
  }

  void checkRealmCurrencyNotification(BackupRealmCurrencyNotificationModel got, BackupRealmCurrencyNotificationModel expected) {
    checkNotification(got, expected);
    expect(got.realmTrustRank, expected.realmTrustRank);
    expect(got.realmRankType, expected.realmRankType);
    expect(got.realmCurrency, expected.realmCurrency);
  }

  void checkResinNotification(BackupResinNotificationModel got, BackupResinNotificationModel expected) {
    checkNotification(got, expected);
    expect(got.currentResinValue, expected.currentResinValue);
  }

  void checkWeeklyBossNotification(BackupWeeklyBossNotificationModel got, BackupWeeklyBossNotificationModel expected) {
    checkNotification(got, expected);
  }

  DataService getMockedDataService(List<AppBackupDataType> dataTypes) {
    final dataService = MockDataService();

    for (final type in dataTypes) {
      switch (type) {
        case AppBackupDataType.settings:
          break;
        case AppBackupDataType.inventory:
          final inventoryMock = MockInventoryDataService();
          when(inventoryMock.getDataForBackup()).thenReturn(inventoryData);
          when(dataService.inventory).thenReturn(inventoryMock);
          break;
        case AppBackupDataType.calculatorAscMaterials:
          final calAscMatMock = MockCalculatorDataService();
          when(calAscMatMock.getDataForBackup()).thenReturn(calAscMatData);
          when(dataService.calculator).thenReturn(calAscMatMock);
          break;
        case AppBackupDataType.tierList:
          final tierListMock = MockTierListDataService();
          when(tierListMock.getDataForBackup()).thenReturn(tierListData);
          when(dataService.tierList).thenReturn(tierListMock);
          break;
        case AppBackupDataType.customBuilds:
          final customBuildsMock = MockCustomBuildsDataService();
          when(customBuildsMock.getDataForBackup()).thenReturn(customBuildsData);
          when(dataService.customBuilds).thenReturn(customBuildsMock);
          break;
        case AppBackupDataType.notifications:
          final notificationsMock = MockNotificationsDataService();
          when(notificationsMock.getDataForBackup()).thenReturn(notificationsData);
          when(dataService.notifications).thenReturn(notificationsMock);
          break;
      }
    }
    return dataService;
  }

  group('Create backup', () {
    test('but no data types are provided', () {
      final service = getService(settings);
      expect(() => service.createBackup([]), throwsA(isA<Exception>()));
    });

    test('fails to be created due to exception', () async {
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

    test('gets successfully created', () async {
      final dataTypes = AppBackupDataType.values.toList();
      final dataService = getMockedDataService(dataTypes);
      final service = getService(settings, dataService: dataService);
      final result = await service.createBackup(dataTypes);
      expect(result.succeed, isTrue);
      expect(result.dataTypes, containsAll(dataTypes));
      expect(result.path, isNotEmpty);
    });
  });

  test('Read backups at least one exists', () async {
    const dataTypes = AppBackupDataType.values;
    final dataService = getMockedDataService(dataTypes);
    final service = getService(settings, dataService: dataService);
    final result = await service.createBackup(dataTypes);
    final bks = await service.readBackups();
    expect(bks.length, greaterThanOrEqualTo(1));
    expect(bks.any((bk) => bk.filePath == result.path), isTrue);
  });

  group('Read backup', () {
    test('file does not exist, returns null', () async {
      final service = getService(settings);
      final bk = await service.readBackup(join(backupDirPath, 'non_existent_file.bk'));
      expect(bk, isNull);
    });

    test('file exists, returns valid value', () async {
      const dataTypes = AppBackupDataType.values;
      final dataService = getMockedDataService(dataTypes);
      final service = getService(settings, dataService: dataService);
      final result = await service.createBackup(dataTypes);
      final bk = await service.readBackup(result.path);
      expect(bk, isNotNull);
      expect(bk!.settings, isNotNull);
      expect(bk.inventory, isNotNull);
      expect(bk.calculatorAscMaterials, isNotNull);
      expect(bk.tierList, isNotNull);
      expect(bk.customBuilds, isNotNull);
      expect(bk.notifications, isNotNull);

      checkSettings(bk.settings!, settings);

      expect(bk.inventory!.length, inventoryData.length);
      for (var i = 0; i < bk.inventory!.length; i++) {
        final item = bk.inventory![i];
        checkInventory(item, inventoryData[i]);
      }
      expect(bk.calculatorAscMaterials!.length, calAscMatData.length);
      for (var i = 0; i < bk.calculatorAscMaterials!.length; i++) {
        final item = bk.calculatorAscMaterials![i];
        checkCalAscMatSession(item, calAscMatData[i]);
      }
      expect(bk.tierList!.length, tierListData.length);
      for (var i = 0; i < bk.tierList!.length; i++) {
        final item = bk.tierList![i];
        checkTierList(item, tierListData[i]);
      }
      expect(bk.customBuilds!.length, customBuildsData.length);
      for (var i = 0; i < bk.customBuilds!.length; i++) {
        final item = bk.customBuilds![i];
        checkCustomBuild(item, customBuildsData[i]);
      }
      expect(bk.notifications, isNotNull);
      expect(bk.notifications!.custom.length, notificationsData.custom.length);
      for (var i = 0; i < bk.notifications!.custom.length; i++) {
        final item = bk.notifications!.custom[i];
        checkCustomNotification(item, notificationsData.custom[i]);
      }
      expect(bk.notifications!.expeditions.length, notificationsData.expeditions.length);
      for (var i = 0; i < bk.notifications!.expeditions.length; i++) {
        final item = bk.notifications!.expeditions[i];
        checkExpeditionNotification(item, notificationsData.expeditions[i]);
      }
      expect(bk.notifications!.farmingMaterial.length, notificationsData.farmingMaterial.length);
      for (var i = 0; i < bk.notifications!.farmingMaterial.length; i++) {
        final item = bk.notifications!.farmingMaterial[i];
        checkFarmingMaterialNotification(item, notificationsData.farmingMaterial[i]);
      }
      expect(bk.notifications!.farmingArtifact.length, notificationsData.farmingArtifact.length);
      for (var i = 0; i < bk.notifications!.farmingArtifact.length; i++) {
        final item = bk.notifications!.farmingArtifact[i];
        checkFarmingArtifactNotification(item, notificationsData.farmingArtifact[i]);
      }
      expect(bk.notifications!.furniture.length, notificationsData.furniture.length);
      for (var i = 0; i < bk.notifications!.furniture.length; i++) {
        final item = bk.notifications!.furniture[i];
        checkFurnitureNotification(item, notificationsData.furniture[i]);
      }
      expect(bk.notifications!.gadgets.length, notificationsData.gadgets.length);
      for (var i = 0; i < bk.notifications!.gadgets.length; i++) {
        final item = bk.notifications!.gadgets[i];
        checkGadgetNotification(item, notificationsData.gadgets[i]);
      }
      expect(bk.notifications!.realmCurrency.length, notificationsData.realmCurrency.length);
      for (var i = 0; i < bk.notifications!.realmCurrency.length; i++) {
        final item = bk.notifications!.realmCurrency[i];
        checkRealmCurrencyNotification(item, notificationsData.realmCurrency[i]);
      }
      expect(bk.notifications!.resin.length, notificationsData.resin.length);
      for (var i = 0; i < bk.notifications!.resin.length; i++) {
        final item = bk.notifications!.resin[i];
        checkResinNotification(item, notificationsData.resin[i]);
      }
      expect(bk.notifications!.weeklyBosses.length, notificationsData.weeklyBosses.length);
      for (var i = 0; i < bk.notifications!.weeklyBosses.length; i++) {
        final item = bk.notifications!.weeklyBosses[i];
        checkWeeklyBossNotification(item, notificationsData.weeklyBosses[i]);
      }
    });
  });

  group('Can backup be restored', () {
    test('it cannot', () {
      final service = getService(settings, appVersion: '1.6.9');
      final canBeRestored = service.canBackupBeRestored('1.7.0');
      expect(canBeRestored, isFalse);
    });

    test('it can', () {
      final service = getService(settings, appVersion: '1.6.9');
      final canBeRestored = service.canBackupBeRestored('1.6.8');
      expect(canBeRestored, isTrue);
    });
  });

  group('Restore backup', () {
    test('no data types were provided thus it throws exception', () {
      final service = getService(settings);
      final bk = BackupModel(
        appVersion: '1.6.8',
        resourceVersion: 1,
        createdAt: DateTime.now(),
        deviceInfo: {},
        dataTypes: [],
      );
      expect(() => service.restoreBackup(bk, []), throwsA(isA<Exception>()));
    });

    test("backup's data types is empty thus completing without restore", () async {
      final service = getService(settings);
      final bk = BackupModel(
        appVersion: '1.6.8',
        resourceVersion: 1,
        createdAt: DateTime.now(),
        deviceInfo: {},
        dataTypes: [],
      );
      final restored = await service.restoreBackup(bk, AppBackupDataType.values);
      expect(restored, isTrue);
    });

    test('process throws exception thus it cannot be restored', () async {
      final bk = BackupModel(
        appVersion: '1.6.8',
        resourceVersion: 1,
        createdAt: DateTime.now(),
        deviceInfo: {},
        dataTypes: AppBackupDataType.values,
        notifications: notificationsData,
        settings: settings,
        calculatorAscMaterials: calAscMatData,
        customBuilds: customBuildsData,
        inventory: inventoryData,
        tierList: tierListData,
      );
      final service = getService(settings);
      final restored = await service.restoreBackup(bk, AppBackupDataType.values);
      expect(restored, isFalse);
    });

    test('backup gets restored', () async {
      final bk = BackupModel(
        appVersion: '1.6.8',
        resourceVersion: 1,
        createdAt: DateTime.now(),
        deviceInfo: {},
        dataTypes: AppBackupDataType.values,
        notifications: notificationsData,
        settings: settings,
        calculatorAscMaterials: calAscMatData,
        customBuilds: customBuildsData,
        inventory: inventoryData,
        tierList: tierListData,
      );

      final settingsService = MockSettingsService();
      final dataServiceMock = MockDataService();
      final inventory = MockInventoryDataService();
      when(dataServiceMock.inventory).thenReturn(inventory);
      final calAscMat = MockCalculatorDataService();
      when(dataServiceMock.calculator).thenReturn(calAscMat);
      final tierList = MockTierListDataService();
      when(dataServiceMock.tierList).thenReturn(tierList);
      final customBuilds = MockCustomBuildsDataService();
      when(dataServiceMock.customBuilds).thenReturn(customBuilds);
      final notifications = MockNotificationsDataService();
      when(dataServiceMock.notifications).thenReturn(notifications);
      final notificationService = MockNotificationService();

      final service = getService(settings, dataService: dataServiceMock, settingsService: settingsService, notificationService: notificationService);
      final restored = await service.restoreBackup(bk, AppBackupDataType.values);
      expect(restored, isTrue);

      verify(settingsService.restoreFromBackup(bk.settings)).called(1);
      verify(inventory.restoreFromBackup(bk.inventory)).called(1);
      verify(calAscMat.restoreFromBackup(bk.calculatorAscMaterials)).called(1);
      verify(tierList.restoreFromBackup(bk.tierList)).called(1);
      verify(customBuilds.restoreFromBackup(bk.customBuilds)).called(1);
      verify(notificationService.cancelAllNotifications()).called(1);
      verify(notifications.restoreFromBackup(bk.notifications, settings.serverResetTime)).called(1);
    });
  });

  group('Delete backup', () {
    test('file does not exist, nothing gets deleted', () async {
      final service = getService(settings);
      final deleted = await service.deleteBackup(join(backupDirPath, 'non_existent_file.bk'));
      expect(deleted, isFalse);
    });

    test('file exists, so it gets deleted', () async {
      const dataTypes = AppBackupDataType.values;
      final dataService = getMockedDataService(dataTypes);
      final service = getService(settings, dataService: dataService);
      final result = await service.createBackup(dataTypes);
      final deleted = await service.deleteBackup(result.path);
      expect(deleted, isTrue);
    });
  });

  group('Copy imported file', () {
    test('file does not exist, nothing gets copied', () async {
      final service = getService(settings);
      final copied = await service.copyImportedFile(join(backupDirPath, 'non_existent_file.bk'));
      expect(copied, isFalse);
    });

    test('file exists, file gets copied', () async {
      const dataTypes = AppBackupDataType.values;
      final dataService = getMockedDataService(dataTypes);
      final service = getService(settings, dataService: dataService);
      final result = await service.createBackup(dataTypes);
      final file = File(result.path);
      final importedDir = await Directory.systemTemp.createTemp('imported');
      final importedPath = join(importedDir.path, 'imported.bk');
      await file.copy(importedPath);
      await file.delete();
      final copied = await service.copyImportedFile(importedPath);
      expect(copied, isTrue);
    });
  });
}
