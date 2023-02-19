import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/calculator_data_service.dart';
import 'package:shiori/domain/services/persistence/custom_builds_data_service.dart';
import 'package:shiori/domain/services/persistence/game_codes_data_service.dart';
import 'package:shiori/domain/services/persistence/inventory_data_service.dart';
import 'package:shiori/domain/services/persistence/notifications_data_service.dart';
import 'package:shiori/domain/services/persistence/pity_counter_data_service.dart';
import 'package:shiori/domain/services/persistence/tier_list_data_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/persistence/calculator_data_service.dart';
import 'package:shiori/infrastructure/persistence/custom_builds_data_service.dart';
import 'package:shiori/infrastructure/persistence/game_codes_data_service.dart';
import 'package:shiori/infrastructure/persistence/inventory_data_service.dart';
import 'package:shiori/infrastructure/persistence/notifications_data_service.dart';
import 'package:shiori/infrastructure/persistence/pity_counter_data_service.dart';
import 'package:shiori/infrastructure/persistence/tier_list_data_service.dart';
import 'package:synchronized/synchronized.dart';

class DataServiceImpl implements DataService {
  final PityCounterDataService _pityCounter;
  final InventoryDataService _inventory;
  final CustomBuildsDataService _builds;
  final NotificationsDataService _notifications;
  final GameCodesDataService _gameCodes;
  final TierListDataService _tierList;

  late final CalculatorDataService _calculator;

  final _initLock = Lock();
  final _deleteAllLock = Lock();

  @override
  PityCounterDataService get pityCounter => _pityCounter;

  @override
  CalculatorDataService get calculator => _calculator;

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

  DataServiceImpl(GenshinService genshinService, CalculatorService calculatorService, ResourceService resourceService)
      : _pityCounter = PityCounterDataServiceImpl(),
        _inventory = InventoryDataServiceImpl(genshinService),
        _builds = CustomBuildsDataServiceImpl(genshinService, resourceService),
        _notifications = NotificationsDataServiceImpl(genshinService),
        _gameCodes = GameCodesDataServiceImpl(genshinService, resourceService),
        _tierList = TierListDataServiceImpl(genshinService, resourceService) {
    _calculator = CalculatorDataServiceImpl(genshinService, calculatorService, _inventory, resourceService);
  }

  Future<void> _init() async {
    _registerAdapters();
    await _pityCounter.init();
    await _calculator.init();
    await _inventory.init();
    await _builds.init();
    await _notifications.init();
    await _gameCodes.init();
    await _tierList.init();
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
  Future<void> initForTests(String path) async {
    await _initLock.synchronized(() async {
      Hive.init(path);
      await _init();
    });
  }

  @override
  Future<void> deleteThemAll() async {
    await _deleteAllLock.synchronized(() async {
      await _pityCounter.deleteThemAll();
      await _calculator.deleteThemAll();
      await _inventory.deleteThemAll();
      await _builds.deleteThemAll();
      await _notifications.deleteThemAll();
      await _gameCodes.deleteThemAll();
      await _tierList.deleteThemAll();
    });
  }

  @override
  Future<void> closeThemAll() async {
    await _deleteAllLock.synchronized(() async {
      await Hive.close();
    });

    await Future.wait([
      _inventory.itemAddedToInventory.close(),
      _inventory.itemUpdatedInInventory.close(),
      _inventory.itemDeletedFromInventory.close(),
    ]);
  }

  void _registerAdapters() {
    Hive.registerAdapter(CalculatorCharacterSkillAdapter());
    Hive.registerAdapter(CalculatorItemAdapter());
    Hive.registerAdapter(CalculatorSessionAdapter());
    Hive.registerAdapter(InventoryItemAdapter());
    Hive.registerAdapter(InventoryUsedItemAdapter());
    Hive.registerAdapter(GameCodeAdapter());
    Hive.registerAdapter(GameCodeRewardAdapter());
    Hive.registerAdapter(TierListItemAdapter());
    Hive.registerAdapter(NotificationCustomAdapter());
    Hive.registerAdapter(NotificationExpeditionAdapter());
    Hive.registerAdapter(NotificationFarmingArtifactAdapter());
    Hive.registerAdapter(NotificationFarmingMaterialAdapter());
    Hive.registerAdapter(NotificationFurnitureAdapter());
    Hive.registerAdapter(NotificationGadgetAdapter());
    Hive.registerAdapter(NotificationRealmCurrencyAdapter());
    Hive.registerAdapter(NotificationResinAdapter());
    Hive.registerAdapter(NotificationWeeklyBossAdapter());
  }
}
