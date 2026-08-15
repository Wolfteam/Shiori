import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/wish_banner_constants.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

void main() {
  late final String backupDirPath;

  const settings = BackupAppSettingsModel(
    appTheme: AppThemeType.dark,
    useDarkAmoled: false,
    accentColor: AppAccentColorType.blue,
    appLanguage: AppLanguageType.english,
    showCharacterDetails: true,
    showWeaponDetails: true,
    serverResetTime: AppServerResetTimeType.northAmerica,
    doubleBackToClose: true,
    useOfficialMap: false,
    useTwentyFourHoursFormat: true,
    checkForUpdatesOnStartup: true,
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
        ),
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

  final gameCodesData = [
    BackupGameCodeModel(
      code: 'xxxzzz',
      isExpired: true,
      expiredOn: DateTime.now().subtract(const Duration(days: 1)),
      region: AppServerResetTimeType.asia.index,
      discoveredOn: DateTime.now().subtract(const Duration(days: 3)),
      usedOn: DateTime.now().subtract(const Duration(days: 2)),
      rewards: const [
        BackupGameCodeRewardModel(itemKey: 'primogem', quantity: 20),
        BackupGameCodeRewardModel(itemKey: 'mora', quantity: 10000),
      ],
    ),
    BackupGameCodeModel(
      code: 'wwwqqqeee',
      isExpired: false,
      discoveredOn: DateTime.now().subtract(const Duration(days: 1)),
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

  final rarities = [
    for (int i = WishBannerConstants.minObtainableRarity; i < WishBannerConstants.maxObtainableRarity + 1; i++) i,
  ];
  final wishSimulatorRandom = Random();
  final wishSimulatorData = BackupWishSimulatorModel(
    pullHistory: BannerItemType.values
        .map(
          (e) => BackupWishSimulatorBannerPullHistory(
            type: e,
            currentXStarCount: {
              for (final rarity in rarities)
                rarity: rarity == WishBannerConstants.maxObtainableRarity
                    ? wishSimulatorRandom.nextInt(e == BannerItemType.character ? 90 : 80)
                    : rarity == WishBannerConstants.maxObtainableRarity - 1
                    ? wishSimulatorRandom.nextInt(10)
                    : 0,
            },
            fiftyFiftyXStarGuaranteed: {
              for (final rarity in rarities) rarity: wishSimulatorRandom.nextBool(),
            },
          ),
        )
        .toList(),
    itemPullHistory: Iterable.generate(1000, (val) => val)
        .map(
          (e) => BackupWishSimulatorBannerItemPullHistory(
            bannerType: BannerItemType.values[wishSimulatorRandom.nextInt(BannerItemType.values.length)],
            itemKey: '$e-item-key',
            itemType: wishSimulatorRandom.nextBool() ? ItemType.character : ItemType.weapon,
            pulledOn: DateTime.now().subtract(Duration(days: e)).toUtc(),
          ),
        )
        .toList(),
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
    BackupAppSettingsModel appSettings, {
    DataService? dataService,
    SettingsService? settingsService,
    NotificationService? notificationService,
    String appVersion = '1.6.8',
  }) {
    final settings = settingsService ?? MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    when(settings.resourceVersion).thenReturn(1);
    when(settings.getDataForBackup()).thenReturn(appSettings);
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

  void checkSettings(BackupAppSettingsModel got, BackupAppSettingsModel expected) {
    expect(got.appTheme, expected.appTheme, reason: 'Backup round-trip must preserve settings.appTheme');
    expect(got.useDarkAmoled, expected.useDarkAmoled, reason: 'Backup round-trip must preserve settings.useDarkAmoled');
    expect(got.accentColor, expected.accentColor, reason: 'Backup round-trip must preserve settings.accentColor');
    expect(got.appLanguage, expected.appLanguage, reason: 'Backup round-trip must preserve settings.appLanguage');
    expect(
      got.showCharacterDetails,
      expected.showCharacterDetails,
      reason: 'Backup round-trip must preserve settings.showCharacterDetails',
    );
    expect(got.showWeaponDetails, expected.showWeaponDetails, reason: 'Backup round-trip must preserve settings.showWeaponDetails');
    expect(got.serverResetTime, expected.serverResetTime, reason: 'Backup round-trip must preserve settings.serverResetTime');
    expect(got.doubleBackToClose, expected.doubleBackToClose, reason: 'Backup round-trip must preserve settings.doubleBackToClose');
    expect(got.useOfficialMap, expected.useOfficialMap, reason: 'Backup round-trip must preserve settings.useOfficialMap');
    expect(
      got.useTwentyFourHoursFormat,
      expected.useTwentyFourHoursFormat,
      reason: 'Backup round-trip must preserve settings.useTwentyFourHoursFormat',
    );
  }

  void checkInventory(BackupInventoryModel got, BackupInventoryModel expected) {
    expect(got.itemKey, expected.itemKey, reason: 'Backup round-trip must preserve inventory.itemKey (itemKey=${expected.itemKey})');
    expect(got.quantity, expected.quantity, reason: 'Backup round-trip must preserve inventory.quantity (itemKey=${expected.itemKey})');
    expect(got.type, expected.type, reason: 'Backup round-trip must preserve inventory.type (itemKey=${expected.itemKey})');
  }

  void checkCalAscMatSessionItemSkill(
    BackupCalculatorAscMaterialsSessionCharSkillItemModel got,
    BackupCalculatorAscMaterialsSessionCharSkillItemModel expected,
  ) {
    expect(got.skillKey, expected.skillKey, reason: 'Backup round-trip must preserve char skill skillKey (skillKey=${expected.skillKey})');
    expect(
      got.currentLevel,
      expected.currentLevel,
      reason: 'Backup round-trip must preserve char skill currentLevel (skillKey=${expected.skillKey})',
    );
    expect(
      got.desiredLevel,
      expected.desiredLevel,
      reason: 'Backup round-trip must preserve char skill desiredLevel (skillKey=${expected.skillKey})',
    );
    expect(got.position, expected.position, reason: 'Backup round-trip must preserve char skill position (skillKey=${expected.skillKey})');
  }

  void checkCalAscMatSessionItem(
    BackupCalculatorAscMaterialsSessionItemModel got,
    BackupCalculatorAscMaterialsSessionItemModel expected,
  ) {
    expect(got.itemKey, expected.itemKey, reason: 'Backup round-trip must preserve calc session item itemKey (itemKey=${expected.itemKey})');
    expect(got.position, expected.position, reason: 'Backup round-trip must preserve calc session item position (itemKey=${expected.itemKey})');
    expect(
      got.currentLevel,
      expected.currentLevel,
      reason: 'Backup round-trip must preserve calc session item currentLevel (itemKey=${expected.itemKey})',
    );
    expect(
      got.desiredLevel,
      expected.desiredLevel,
      reason: 'Backup round-trip must preserve calc session item desiredLevel (itemKey=${expected.itemKey})',
    );
    expect(
      got.currentAscensionLevel,
      expected.currentAscensionLevel,
      reason: 'Backup round-trip must preserve calc session item currentAscensionLevel (itemKey=${expected.itemKey})',
    );
    expect(
      got.desiredAscensionLevel,
      expected.desiredAscensionLevel,
      reason: 'Backup round-trip must preserve calc session item desiredAscensionLevel (itemKey=${expected.itemKey})',
    );
    expect(got.isCharacter, expected.isCharacter, reason: 'Backup round-trip must preserve calc session item isCharacter (itemKey=${expected.itemKey})');
    expect(got.isWeapon, expected.isWeapon, reason: 'Backup round-trip must preserve calc session item isWeapon (itemKey=${expected.itemKey})');
    expect(got.isActive, expected.isActive, reason: 'Backup round-trip must preserve calc session item isActive (itemKey=${expected.itemKey})');
    expect(
      got.useMaterialsFromInventory,
      expected.useMaterialsFromInventory,
      reason: 'Backup round-trip must preserve calc session item useMaterialsFromInventory (itemKey=${expected.itemKey})',
    );
    expect(
      got.characterSkills.length,
      expected.characterSkills.length,
      reason: 'Restored calc session item skill count must match backup (itemKey=${expected.itemKey})',
    );
    for (var i = 0; i < expected.characterSkills.length; i++) {
      checkCalAscMatSessionItemSkill(got.characterSkills[i], expected.characterSkills[i]);
    }
  }

  void checkCalAscMatSession(BackupCalculatorAscMaterialsSessionModel got, BackupCalculatorAscMaterialsSessionModel expected) {
    expect(got.name, expected.name, reason: 'Backup round-trip must preserve calc session name (name=${expected.name})');
    expect(got.position, expected.position, reason: 'Backup round-trip must preserve calc session position (name=${expected.name})');
    expect(got.items.length, expected.items.length, reason: 'Restored calc session item count must match backup (name=${expected.name})');
    for (var i = 0; i < expected.items.length; i++) {
      checkCalAscMatSessionItem(got.items[i], expected.items[i]);
    }
  }

  void checkTierList(BackupTierListModel got, BackupTierListModel expected) {
    expect(got.text, expected.text, reason: 'Backup round-trip must preserve tier list text (position=${expected.position})');
    expect(got.color, expected.color, reason: 'Backup round-trip must preserve tier list color (position=${expected.position})');
    expect(got.position, expected.position, reason: 'Backup round-trip must preserve tier list position (text=${expected.text})');
    expect(got.charKeys, expected.charKeys, reason: 'Backup round-trip must preserve tier list charKeys (position=${expected.position})');
  }

  void checkCustomBuildNote(BackupCustomBuildNoteModel got, BackupCustomBuildNoteModel expected) {
    expect(got.index, expected.index, reason: 'Backup round-trip must preserve custom build note index (index=${expected.index})');
    expect(got.note, expected.note, reason: 'Backup round-trip must preserve custom build note text (index=${expected.index})');
  }

  void checkCustomBuildWeapon(BackupCustomBuildWeaponModel got, BackupCustomBuildWeaponModel expected) {
    expect(got.weaponKey, expected.weaponKey, reason: 'Backup round-trip must preserve custom build weaponKey (weaponKey=${expected.weaponKey})');
    expect(got.index, expected.index, reason: 'Backup round-trip must preserve custom build weapon index (weaponKey=${expected.weaponKey})');
    expect(
      got.refinement,
      expected.refinement,
      reason: 'Backup round-trip must preserve custom build weapon refinement (weaponKey=${expected.weaponKey})',
    );
    expect(got.level, expected.level, reason: 'Backup round-trip must preserve custom build weapon level (weaponKey=${expected.weaponKey})');
    expect(
      got.isAnAscension,
      expected.isAnAscension,
      reason: 'Backup round-trip must preserve custom build weapon isAnAscension (weaponKey=${expected.weaponKey})',
    );
  }

  void checkCustomBuildArtifact(BackupCustomBuildArtifactModel got, BackupCustomBuildArtifactModel expected) {
    expect(got.itemKey, expected.itemKey, reason: 'Backup round-trip must preserve custom build artifact itemKey (itemKey=${expected.itemKey})');
    expect(got.type, expected.type, reason: 'Backup round-trip must preserve custom build artifact type (itemKey=${expected.itemKey})');
    expect(got.statType, expected.statType, reason: 'Backup round-trip must preserve custom build artifact statType (itemKey=${expected.itemKey})');
    expect(got.subStats, expected.subStats, reason: 'Backup round-trip must preserve custom build artifact subStats (itemKey=${expected.itemKey})');
  }

  void checkCustomBuildTeam(BackupCustomBuildTeamCharacterModel got, BackupCustomBuildTeamCharacterModel expected) {
    expect(got.index, expected.index, reason: 'Backup round-trip must preserve team member index (characterKey=${expected.characterKey})');
    expect(
      got.characterKey,
      expected.characterKey,
      reason: 'Backup round-trip must preserve team member characterKey (characterKey=${expected.characterKey})',
    );
    expect(got.roleType, expected.roleType, reason: 'Backup round-trip must preserve team member roleType (characterKey=${expected.characterKey})');
    expect(got.subType, expected.subType, reason: 'Backup round-trip must preserve team member subType (characterKey=${expected.characterKey})');
  }

  void checkCustomBuild(BackupCustomBuildModel got, BackupCustomBuildModel expected) {
    expect(
      got.characterKey,
      expected.characterKey,
      reason: 'Backup round-trip must preserve custom build characterKey (characterKey=${expected.characterKey})',
    );
    expect(
      got.showOnCharacterDetail,
      expected.showOnCharacterDetail,
      reason: 'Backup round-trip must preserve custom build showOnCharacterDetail (characterKey=${expected.characterKey})',
    );
    expect(got.title, expected.title, reason: 'Backup round-trip must preserve custom build title (characterKey=${expected.characterKey})');
    expect(got.roleType, expected.roleType, reason: 'Backup round-trip must preserve custom build roleType (characterKey=${expected.characterKey})');
    expect(
      got.roleSubType,
      expected.roleSubType,
      reason: 'Backup round-trip must preserve custom build roleSubType (characterKey=${expected.characterKey})',
    );
    expect(
      got.skillPriorities,
      expected.skillPriorities,
      reason: 'Backup round-trip must preserve custom build skillPriorities (characterKey=${expected.characterKey})',
    );
    expect(
      got.isRecommended,
      expected.isRecommended,
      reason: 'Backup round-trip must preserve custom build isRecommended (characterKey=${expected.characterKey})',
    );
    expect(
      got.notes.length,
      expected.notes.length,
      reason: 'Restored custom build note count must match backup (characterKey=${expected.characterKey})',
    );
    for (var i = 0; i < expected.notes.length; i++) {
      checkCustomBuildNote(got.notes[i], expected.notes[i]);
    }
    expect(
      got.weapons.length,
      expected.weapons.length,
      reason: 'Restored custom build weapon count must match backup (characterKey=${expected.characterKey})',
    );
    for (var i = 0; i < expected.weapons.length; i++) {
      checkCustomBuildWeapon(got.weapons[i], expected.weapons[i]);
    }
    expect(
      got.artifacts.length,
      expected.artifacts.length,
      reason: 'Restored custom build artifact count must match backup (characterKey=${expected.characterKey})',
    );
    for (var i = 0; i < expected.artifacts.length; i++) {
      checkCustomBuildArtifact(got.artifacts[i], expected.artifacts[i]);
    }
    expect(
      got.team.length,
      expected.team.length,
      reason: 'Restored custom build team count must match backup (characterKey=${expected.characterKey})',
    );
    for (var i = 0; i < expected.team.length; i++) {
      checkCustomBuildTeam(got.team[i], expected.team[i]);
    }
  }

  void checkGameCodeReward(BackupGameCodeRewardModel got, BackupGameCodeRewardModel expected) {
    expect(got.itemKey, expected.itemKey, reason: 'Backup round-trip must preserve game code reward itemKey (itemKey=${expected.itemKey})');
    expect(got.quantity, expected.quantity, reason: 'Backup round-trip must preserve game code reward quantity (itemKey=${expected.itemKey})');
  }

  void checkGameCode(BackupGameCodeModel got, BackupGameCodeModel expected) {
    expect(got.code, expected.code, reason: 'Backup round-trip must preserve game code (code=${expected.code})');
    expect(got.usedOn, expected.usedOn, reason: 'Backup round-trip must preserve game code usedOn (code=${expected.code})');
    expect(got.discoveredOn, expected.discoveredOn, reason: 'Backup round-trip must preserve game code discoveredOn (code=${expected.code})');
    expect(got.expiredOn, expected.expiredOn, reason: 'Backup round-trip must preserve game code expiredOn (code=${expected.code})');
    expect(got.isExpired, expected.isExpired, reason: 'Backup round-trip must preserve game code isExpired (code=${expected.code})');
    expect(got.region, expected.region, reason: 'Backup round-trip must preserve game code region (code=${expected.code})');
    expect(got.rewards.length, expected.rewards.length, reason: 'Restored game code reward count must match backup (code=${expected.code})');
    for (var i = 0; i < got.rewards.length; i++) {
      checkGameCodeReward(got.rewards[i], expected.rewards[i]);
    }
  }

  void checkNotification(BaseBackupNotificationModel got, BaseBackupNotificationModel expected) {
    expect(got.itemKey, expected.itemKey, reason: 'Backup round-trip must preserve notification itemKey (itemKey=${expected.itemKey})');
    expect(
      got.completesAt,
      expected.completesAt,
      reason: 'Backup round-trip must preserve notification completesAt (itemKey=${expected.itemKey})',
    );
    expect(got.note, expected.note, reason: 'Backup round-trip must preserve notification note (itemKey=${expected.itemKey})');
    expect(
      got.showNotification,
      expected.showNotification,
      reason: 'Backup round-trip must preserve notification showNotification (itemKey=${expected.itemKey})',
    );
    expect(got.title, expected.title, reason: 'Backup round-trip must preserve notification title (itemKey=${expected.itemKey})');
    expect(got.body, expected.body, reason: 'Backup round-trip must preserve notification body (itemKey=${expected.itemKey})');
    expect(got.type, expected.type, reason: 'Backup round-trip must preserve notification type (itemKey=${expected.itemKey})');
  }

  void checkCustomNotification(BackupCustomNotificationModel got, BackupCustomNotificationModel expected) {
    checkNotification(got, expected);
    expect(
      got.notificationItemType,
      expected.notificationItemType,
      reason: 'Backup round-trip must preserve custom notification notificationItemType (itemKey=${expected.itemKey})',
    );
  }

  void checkExpeditionNotification(BackupExpeditionNotificationModel got, BackupExpeditionNotificationModel expected) {
    checkNotification(got, expected);
    expect(
      got.expeditionTimeType,
      expected.expeditionTimeType,
      reason: 'Backup round-trip must preserve expedition notification expeditionTimeType (itemKey=${expected.itemKey})',
    );
    expect(
      got.withTimeReduction,
      expected.withTimeReduction,
      reason: 'Backup round-trip must preserve expedition notification withTimeReduction (itemKey=${expected.itemKey})',
    );
  }

  void checkFarmingArtifactNotification(
    BackupFarmingArtifactNotificationModel got,
    BackupFarmingArtifactNotificationModel expected,
  ) {
    checkNotification(got, expected);
    expect(
      got.artifactFarmingTimeType,
      expected.artifactFarmingTimeType,
      reason: 'Backup round-trip must preserve farming artifact notification artifactFarmingTimeType (itemKey=${expected.itemKey})',
    );
  }

  void checkFarmingMaterialNotification(
    BackupFarmingMaterialNotificationModel got,
    BackupFarmingMaterialNotificationModel expected,
  ) {
    checkNotification(got, expected);
  }

  void checkFurnitureNotification(BackupFurnitureNotificationModel got, BackupFurnitureNotificationModel expected) {
    checkNotification(got, expected);
    expect(
      got.furnitureCraftingTimeType,
      expected.furnitureCraftingTimeType,
      reason: 'Backup round-trip must preserve furniture notification furnitureCraftingTimeType (itemKey=${expected.itemKey})',
    );
  }

  void checkGadgetNotification(BackupGadgetNotificationModel got, BackupGadgetNotificationModel expected) {
    checkNotification(got, expected);
  }

  void checkRealmCurrencyNotification(BackupRealmCurrencyNotificationModel got, BackupRealmCurrencyNotificationModel expected) {
    checkNotification(got, expected);
    expect(
      got.realmTrustRank,
      expected.realmTrustRank,
      reason: 'Backup round-trip must preserve realm currency notification realmTrustRank (itemKey=${expected.itemKey})',
    );
    expect(
      got.realmRankType,
      expected.realmRankType,
      reason: 'Backup round-trip must preserve realm currency notification realmRankType (itemKey=${expected.itemKey})',
    );
    expect(
      got.realmCurrency,
      expected.realmCurrency,
      reason: 'Backup round-trip must preserve realm currency notification realmCurrency (itemKey=${expected.itemKey})',
    );
  }

  void checkResinNotification(BackupResinNotificationModel got, BackupResinNotificationModel expected) {
    checkNotification(got, expected);
    expect(
      got.currentResinValue,
      expected.currentResinValue,
      reason: 'Backup round-trip must preserve resin notification currentResinValue (itemKey=${expected.itemKey})',
    );
  }

  void checkWeeklyBossNotification(BackupWeeklyBossNotificationModel got, BackupWeeklyBossNotificationModel expected) {
    checkNotification(got, expected);
  }

  void checkWishSimulatorPullHistory(BackupWishSimulatorBannerPullHistory got, BackupWishSimulatorBannerPullHistory expected) {
    expect(got.type, expected.type, reason: 'Backup round-trip must preserve wish pull history bannerItemType (type=${expected.type})');
    expect(
      got.currentXStarCount,
      expected.currentXStarCount,
      reason: 'Backup round-trip must preserve wish pull history currentXStarCount (type=${expected.type})',
    );
    expect(
      got.fiftyFiftyXStarGuaranteed,
      expected.fiftyFiftyXStarGuaranteed,
      reason: 'Backup round-trip must preserve wish pull history fiftyFiftyXStarGuaranteed (type=${expected.type})',
    );
  }

  void checkWishSimualtorItemPullHistory(
    BackupWishSimulatorBannerItemPullHistory got,
    BackupWishSimulatorBannerItemPullHistory expected,
  ) {
    expect(
      got.bannerType,
      expected.bannerType,
      reason: 'Backup round-trip must preserve wish item pull bannerType (itemKey=${expected.itemKey})',
    );
    expect(got.itemKey, expected.itemKey, reason: 'Backup round-trip must preserve wish item pull itemKey (itemKey=${expected.itemKey})');
    expect(got.itemType, expected.itemType, reason: 'Backup round-trip must preserve wish item pull itemType (itemKey=${expected.itemKey})');
    expect(got.pulledOn, expected.pulledOn, reason: 'Backup round-trip must preserve wish item pull pulledOn (itemKey=${expected.itemKey})');
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
        case AppBackupDataType.calculatorAscMaterials:
          final calAscMatMock = MockCalculatorAscMaterialsDataService();
          when(calAscMatMock.getDataForBackup()).thenReturn(calAscMatData);
          when(dataService.calculator).thenReturn(calAscMatMock);
        case AppBackupDataType.tierList:
          final tierListMock = MockTierListDataService();
          when(tierListMock.getDataForBackup()).thenReturn(tierListData);
          when(dataService.tierList).thenReturn(tierListMock);
        case AppBackupDataType.customBuilds:
          final customBuildsMock = MockCustomBuildsDataService();
          when(customBuildsMock.getDataForBackup()).thenReturn(customBuildsData);
          when(dataService.customBuilds).thenReturn(customBuildsMock);
        case AppBackupDataType.gameCodes:
          final gameCodesMock = MockGameCodesDataService();
          when(gameCodesMock.getDataForBackup()).thenReturn(gameCodesData);
          when(dataService.gameCodes).thenReturn(gameCodesMock);
        case AppBackupDataType.notifications:
          final notificationsMock = MockNotificationsDataService();
          when(notificationsMock.getDataForBackup()).thenReturn(notificationsData);
          when(dataService.notifications).thenReturn(notificationsMock);
        case AppBackupDataType.wishSimulator:
          final wishSimulatorMock = MockWishSimulatorDataService();
          when(wishSimulatorMock.getDataForBackup()).thenAnswer((_) => Future.value(wishSimulatorData));
          when(dataService.wishSimulator).thenReturn(wishSimulatorMock);
      }
    }
    return dataService;
  }

  group('Create backup', () {
    test('but no data types are provided', () {
      final service = getService(settings);
      expect(
        () => service.createBackup([]),
        throwsA(isA<Exception>()),
        reason: 'createBackup with no data types must throw; an empty backup is not allowed',
      );
    });

    test('fails to be created due to exception', () async {
      final dataService = MockDataService();
      final inventory = MockInventoryDataService();
      when(inventory.getDataForBackup()).thenThrow(Exception('Error'));
      when(dataService.inventory).thenThrow(inventory);

      final service = getService(settings, dataService: dataService);
      final dataTypes = [AppBackupDataType.inventory];
      final result = await service.createBackup(dataTypes);
      expect(result.succeed, isFalse, reason: 'createBackup must report failure when a data service throws');
      expect(result.dataTypes, containsAll(dataTypes), reason: 'Failed backup result must still echo the requested data types');
      expect(result.path, isNotEmpty, reason: 'Backup result must expose the target file path even when it fails');
    });

    test('gets successfully created', () async {
      final dataTypes = AppBackupDataType.values.toList();
      final dataService = getMockedDataService(dataTypes);
      final service = getService(settings, dataService: dataService);
      final result = await service.createBackup(dataTypes);
      expect(result.succeed, isTrue, reason: 'createBackup must succeed when every requested data service returns data');
      expect(result.dataTypes, containsAll(dataTypes), reason: 'Successful backup result must list all requested data types');
      expect(result.path, isNotEmpty, reason: 'Successful backup must expose a non-empty file path');
    });
  });

  test('Read backups at least one exists', () async {
    const dataTypes = AppBackupDataType.values;
    final dataService = getMockedDataService(dataTypes);
    final service = getService(settings, dataService: dataService);
    final result = await service.createBackup(dataTypes);
    final bks = await service.readBackups();
    expect(bks.length, greaterThanOrEqualTo(1), reason: 'readBackups must return at least the backup just created');
    expect(
      bks.any((bk) => bk.filePath == result.path),
      isTrue,
      reason: 'readBackups must include the newly created backup file path',
    );
  });

  group('Read backup', () {
    test('file does not exist, returns null', () async {
      final service = getService(settings);
      final bk = await service.readBackup(join(backupDirPath, 'non_existent_file.bk'));
      expect(bk, isNull, reason: 'readBackup must return null when the backup file does not exist');
    });

    test('file exists, returns valid value', () async {
      const dataTypes = AppBackupDataType.values;
      final dataService = getMockedDataService(dataTypes);
      final service = getService(settings, dataService: dataService);
      final result = await service.createBackup(dataTypes);
      final bk = await service.readBackup(result.path);
      expect(bk, isNotNull, reason: 'readBackup must return a parsed backup for an existing file');
      expect(bk!.settings, isNotNull, reason: 'Restored backup must include the settings section');
      expect(bk.inventory, isNotNull, reason: 'Restored backup must include the inventory section');
      expect(bk.calculatorAscMaterials, isNotNull, reason: 'Restored backup must include the calculatorAscMaterials section');
      expect(bk.tierList, isNotNull, reason: 'Restored backup must include the tierList section');
      expect(bk.customBuilds, isNotNull, reason: 'Restored backup must include the customBuilds section');
      expect(bk.gameCodes, isNotNull, reason: 'Restored backup must include the gameCodes section');
      expect(bk.notifications, isNotNull, reason: 'Restored backup must include the notifications section');

      checkSettings(bk.settings!, settings);

      expect(bk.inventory!.length, inventoryData.length, reason: 'Restored inventory count must match the backed-up inventory');
      for (var i = 0; i < bk.inventory!.length; i++) {
        final item = bk.inventory![i];
        checkInventory(item, inventoryData[i]);
      }
      expect(
        bk.calculatorAscMaterials!.length,
        calAscMatData.length,
        reason: 'Restored calculatorAscMaterials count must match the backed-up sessions',
      );
      for (var i = 0; i < bk.calculatorAscMaterials!.length; i++) {
        final item = bk.calculatorAscMaterials![i];
        checkCalAscMatSession(item, calAscMatData[i]);
      }
      expect(bk.tierList!.length, tierListData.length, reason: 'Restored tierList count must match the backed-up tier lists');
      for (var i = 0; i < bk.tierList!.length; i++) {
        final item = bk.tierList![i];
        checkTierList(item, tierListData[i]);
      }
      expect(bk.customBuilds!.length, customBuildsData.length, reason: 'Restored customBuilds count must match the backed-up builds');
      for (var i = 0; i < bk.customBuilds!.length; i++) {
        final item = bk.customBuilds![i];
        checkCustomBuild(item, customBuildsData[i]);
      }
      expect(bk.gameCodes!.length, gameCodesData.length, reason: 'Restored gameCodes count must match the backed-up game codes');
      for (var i = 0; i < bk.gameCodes!.length; i++) {
        final item = bk.gameCodes![i];
        checkGameCode(item, gameCodesData[i]);
      }
      expect(bk.notifications, isNotNull, reason: 'Restored backup must include the notifications section');
      expect(
        bk.notifications!.custom.length,
        notificationsData.custom.length,
        reason: 'Restored custom notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.custom.length; i++) {
        final item = bk.notifications!.custom[i];
        checkCustomNotification(item, notificationsData.custom[i]);
      }
      expect(
        bk.notifications!.expeditions.length,
        notificationsData.expeditions.length,
        reason: 'Restored expedition notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.expeditions.length; i++) {
        final item = bk.notifications!.expeditions[i];
        checkExpeditionNotification(item, notificationsData.expeditions[i]);
      }
      expect(
        bk.notifications!.farmingMaterial.length,
        notificationsData.farmingMaterial.length,
        reason: 'Restored farmingMaterial notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.farmingMaterial.length; i++) {
        final item = bk.notifications!.farmingMaterial[i];
        checkFarmingMaterialNotification(item, notificationsData.farmingMaterial[i]);
      }
      expect(
        bk.notifications!.farmingArtifact.length,
        notificationsData.farmingArtifact.length,
        reason: 'Restored farmingArtifact notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.farmingArtifact.length; i++) {
        final item = bk.notifications!.farmingArtifact[i];
        checkFarmingArtifactNotification(item, notificationsData.farmingArtifact[i]);
      }
      expect(
        bk.notifications!.furniture.length,
        notificationsData.furniture.length,
        reason: 'Restored furniture notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.furniture.length; i++) {
        final item = bk.notifications!.furniture[i];
        checkFurnitureNotification(item, notificationsData.furniture[i]);
      }
      expect(
        bk.notifications!.gadgets.length,
        notificationsData.gadgets.length,
        reason: 'Restored gadget notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.gadgets.length; i++) {
        final item = bk.notifications!.gadgets[i];
        checkGadgetNotification(item, notificationsData.gadgets[i]);
      }
      expect(
        bk.notifications!.realmCurrency.length,
        notificationsData.realmCurrency.length,
        reason: 'Restored realmCurrency notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.realmCurrency.length; i++) {
        final item = bk.notifications!.realmCurrency[i];
        checkRealmCurrencyNotification(item, notificationsData.realmCurrency[i]);
      }
      expect(
        bk.notifications!.resin.length,
        notificationsData.resin.length,
        reason: 'Restored resin notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.resin.length; i++) {
        final item = bk.notifications!.resin[i];
        checkResinNotification(item, notificationsData.resin[i]);
      }
      expect(
        bk.notifications!.weeklyBosses.length,
        notificationsData.weeklyBosses.length,
        reason: 'Restored weeklyBoss notification count must match backup',
      );
      for (var i = 0; i < bk.notifications!.weeklyBosses.length; i++) {
        final item = bk.notifications!.weeklyBosses[i];
        checkWeeklyBossNotification(item, notificationsData.weeklyBosses[i]);
      }

      expect(
        bk.wishSimulator!.pullHistory.length,
        wishSimulatorData.pullHistory.length,
        reason: 'Restored wish simulator pullHistory count must match backup',
      );
      for (var i = 0; i < bk.wishSimulator!.pullHistory.length; i++) {
        final item = bk.wishSimulator!.pullHistory[i];
        checkWishSimulatorPullHistory(item, wishSimulatorData.pullHistory[i]);
      }

      expect(
        bk.wishSimulator!.itemPullHistory.length,
        wishSimulatorData.itemPullHistory.length,
        reason: 'Restored wish simulator itemPullHistory count must match backup',
      );
      for (var i = 0; i < bk.wishSimulator!.itemPullHistory.length; i++) {
        final item = bk.wishSimulator!.itemPullHistory[i];
        checkWishSimualtorItemPullHistory(item, wishSimulatorData.itemPullHistory[i]);
      }
    });
  });

  group('Can backup be restored', () {
    test('it cannot', () {
      final service = getService(settings, appVersion: '1.6.9');
      final canBeRestored = service.canBackupBeRestored('1.7.0');
      expect(canBeRestored, isFalse, reason: 'Backup from newer app version 1.7.0 must not be restorable on 1.6.9');
    });

    test('it can', () {
      final service = getService(settings, appVersion: '1.6.9');
      final canBeRestored = service.canBackupBeRestored('1.6.8');
      expect(canBeRestored, isTrue, reason: 'Backup from older app version 1.6.8 must be restorable on 1.6.9');
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
      expect(
        () => service.restoreBackup(bk, []),
        throwsA(isA<Exception>()),
        reason: 'restoreBackup with no data types to restore must throw',
      );
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
      expect(restored, isTrue, reason: 'Restoring a backup with empty dataTypes must complete as a no-op and report success');
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
      expect(restored, isFalse, reason: 'restoreBackup must report failure when a data service throws mid-restore');
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
        gameCodes: gameCodesData,
        wishSimulator: wishSimulatorData,
      );

      final settingsService = MockSettingsService();
      final dataServiceMock = MockDataService();
      final inventory = MockInventoryDataService();
      when(dataServiceMock.inventory).thenReturn(inventory);
      final calAscMat = MockCalculatorAscMaterialsDataService();
      when(dataServiceMock.calculator).thenReturn(calAscMat);
      final tierList = MockTierListDataService();
      when(dataServiceMock.tierList).thenReturn(tierList);
      final customBuilds = MockCustomBuildsDataService();
      when(dataServiceMock.customBuilds).thenReturn(customBuilds);
      final gameCodes = MockGameCodesDataService();
      when(dataServiceMock.gameCodes).thenReturn(gameCodes);
      final notifications = MockNotificationsDataService();
      when(dataServiceMock.notifications).thenReturn(notifications);
      final wishSimulator = MockWishSimulatorDataService();
      when(dataServiceMock.wishSimulator).thenReturn(wishSimulator);

      final notificationService = MockNotificationService();

      final service = getService(
        settings,
        dataService: dataServiceMock,
        settingsService: settingsService,
        notificationService: notificationService,
      );
      final restored = await service.restoreBackup(bk, AppBackupDataType.values);
      expect(restored, isTrue, reason: 'restoreBackup must report success when every data section restores without error');

      verify(settingsService.restoreFromBackup(bk.settings)).called(1);
      verify(inventory.restoreFromBackup(bk.inventory)).called(1);
      verify(calAscMat.restoreFromBackup(bk.calculatorAscMaterials)).called(1);
      verify(tierList.restoreFromBackup(bk.tierList)).called(1);
      verify(customBuilds.restoreFromBackup(bk.customBuilds)).called(1);
      verify(gameCodes.restoreFromBackup(bk.gameCodes)).called(1);
      verify(notificationService.cancelAllNotifications()).called(1);
      verify(notifications.restoreFromBackup(bk.notifications, settings.serverResetTime)).called(1);
    });
  });

  group('Delete backup', () {
    test('file does not exist, nothing gets deleted', () async {
      final service = getService(settings);
      final deleted = await service.deleteBackup(join(backupDirPath, 'non_existent_file.bk'));
      expect(deleted, isFalse, reason: 'deleteBackup must report false when the target file does not exist');
    });

    test('file exists, so it gets deleted', () async {
      const dataTypes = AppBackupDataType.values;
      final dataService = getMockedDataService(dataTypes);
      final service = getService(settings, dataService: dataService);
      final result = await service.createBackup(dataTypes);
      final deleted = await service.deleteBackup(result.path);
      expect(deleted, isTrue, reason: 'deleteBackup must report true after removing an existing backup file');
    });
  });

  group('Copy imported file', () {
    test('file does not exist, nothing gets copied', () async {
      final service = getService(settings);
      final copied = await service.copyImportedFile(join(backupDirPath, 'non_existent_file.bk'));
      expect(copied, isFalse, reason: 'copyImportedFile must report false when the source file does not exist');
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
      expect(copied, isTrue, reason: 'copyImportedFile must report true after copying an existing backup file into the backups dir');
    });
  });
}
