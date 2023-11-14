import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/calculator_asc_materials_data_service.dart';
import 'package:shiori/domain/services/persistence/custom_builds_data_service.dart';
import 'package:shiori/domain/services/persistence/game_codes_data_service.dart';
import 'package:shiori/domain/services/persistence/inventory_data_service.dart';
import 'package:shiori/domain/services/persistence/notifications_data_service.dart';
import 'package:shiori/domain/services/persistence/tier_list_data_service.dart';
import 'package:shiori/domain/services/persistence/wish_simulator_data_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/persistence/calculator_asc_materials_data_service.dart';
import 'package:shiori/infrastructure/persistence/custom_builds_data_service.dart';
import 'package:shiori/infrastructure/persistence/game_codes_data_service.dart';
import 'package:shiori/infrastructure/persistence/inventory_data_service.dart';
import 'package:shiori/infrastructure/persistence/notifications_data_service.dart';
import 'package:shiori/infrastructure/persistence/tier_list_data_service.dart';
import 'package:shiori/infrastructure/persistence/wish_simulator_data_service.dart';
import 'package:synchronized/synchronized.dart';

class DataServiceImpl implements DataService {
  final InventoryDataService _inventory;
  final CustomBuildsDataService _builds;
  final NotificationsDataService _notifications;
  final GameCodesDataService _gameCodes;
  final TierListDataService _tierList;
  final WishSimulatorDataService _wishSimulator;

  late final CalculatorAscMaterialsDataService _calculator;

  bool _initialized = false;

  final _initLock = Lock();
  final _deleteAllLock = Lock();

  @override
  CalculatorAscMaterialsDataService get calculator => _calculator;

  @override
  InventoryDataService get inventory => _inventory;

  @override
  CustomBuildsDataService get customBuilds => _builds;

  @override
  NotificationsDataService get notifications => _notifications;

  @override
  GameCodesDataService get gameCodes => _gameCodes;

  @override
  TierListDataService get tierList => _tierList;

  @override
  WishSimulatorDataService get wishSimulator => _wishSimulator;

  DataServiceImpl(GenshinService genshinService, CalculatorAscMaterialsService calculatorService, ResourceService resourceService)
      : _inventory = InventoryDataServiceImpl(genshinService),
        _builds = CustomBuildsDataServiceImpl(genshinService, resourceService),
        _notifications = NotificationsDataServiceImpl(genshinService),
        _gameCodes = GameCodesDataServiceImpl(genshinService, resourceService),
        _tierList = TierListDataServiceImpl(genshinService, resourceService),
        _wishSimulator = WishSimulatorDataServiceImpl() {
    _calculator = CalculatorAscMaterialsDataServiceImpl(genshinService, calculatorService, _inventory, resourceService);
  }

  Future<void> _initServices() async {
    await _calculator.init();
    await _inventory.init();
    await _builds.init();
    await _notifications.init();
    await _gameCodes.init();
    await _tierList.init();
    await _wishSimulator.init();
  }

  Future<void> _init() async {
    if (_initialized) {
      return;
    }
    registerAdapters();
    _initServices();
    _initialized = true;
  }

  @override
  Future<void> init({String dir = 'shiori_data'}) async {
    await _initLock.synchronized(() async {
      await Hive.initFlutter(dir);
      await _init();
    });
  }

  @visibleForTesting
  @override
  Future<void> initForTests(String path, {bool registerAdapters = true}) async {
    await _initLock.synchronized(() async {
      Hive.init(path);
      if (registerAdapters) {
        this.registerAdapters();
      }
      await _initServices();
      _initialized = true;
    });
  }

  @override
  Future<void> deleteThemAll() async {
    await _deleteAllLock.synchronized(() async {
      await _calculator.deleteThemAll();
      await _inventory.deleteThemAll();
      await _builds.deleteThemAll();
      await _notifications.deleteThemAll();
      await _gameCodes.deleteThemAll();
      await _tierList.deleteThemAll();
      await _wishSimulator.deleteThemAll();
    });
  }

  @override
  @visibleForTesting
  Future<void> closeThemAll() async {
    await _deleteAllLock.synchronized(() async {
      await Hive.close();
    });

    await Future.wait([
      _inventory.itemAddedToInventory.close(),
      _inventory.itemUpdatedInInventory.close(),
      _inventory.itemDeletedFromInventory.close(),
      _calculator.itemAdded.close(),
      _calculator.itemDeleted.close(),
    ]);
  }

  @override
  void registerAdapters() {
    //Calculator Asc. Mat.
    Hive.registerAdapter(CalculatorCharacterSkillAdapter());
    Hive.registerAdapter(CalculatorItemAdapter());
    Hive.registerAdapter(CalculatorSessionAdapter());
    //Inventory
    Hive.registerAdapter(InventoryItemAdapter());
    Hive.registerAdapter(InventoryUsedItemAdapter());
    //Game Codes
    Hive.registerAdapter(GameCodeAdapter());
    Hive.registerAdapter(GameCodeRewardAdapter());
    //Tier List
    Hive.registerAdapter(TierListItemAdapter());
    //Notifications
    Hive.registerAdapter(NotificationCustomAdapter());
    Hive.registerAdapter(NotificationExpeditionAdapter());
    Hive.registerAdapter(NotificationFarmingArtifactAdapter());
    Hive.registerAdapter(NotificationFarmingMaterialAdapter());
    Hive.registerAdapter(NotificationFurnitureAdapter());
    Hive.registerAdapter(NotificationGadgetAdapter());
    Hive.registerAdapter(NotificationRealmCurrencyAdapter());
    Hive.registerAdapter(NotificationResinAdapter());
    Hive.registerAdapter(NotificationWeeklyBossAdapter());
    //Wish simulator
    Hive.registerAdapter(WishSimulatorBannerPullHistoryAdapter());
    Hive.registerAdapter(WishSimulatorBannerItemPullHistoryAdapter());
    //Custom builds
    Hive.registerAdapter(CustomBuildAdapter());
    Hive.registerAdapter(CustomBuildWeaponAdapter());
    Hive.registerAdapter(CustomBuildArtifactAdapter());
    Hive.registerAdapter(CustomBuildNoteAdapter());
    Hive.registerAdapter(CustomBuildTeamCharacterAdapter());
  }
}
