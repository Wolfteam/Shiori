import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shiori/domain/services/persistence/calculator_asc_materials_data_service.dart';
import 'package:shiori/domain/services/persistence/custom_builds_data_service.dart';
import 'package:shiori/domain/services/persistence/game_codes_data_service.dart';
import 'package:shiori/domain/services/persistence/inventory_data_service.dart';
import 'package:shiori/domain/services/persistence/notifications_data_service.dart';
import 'package:shiori/domain/services/persistence/tier_list_data_service.dart';
import 'package:shiori/domain/services/persistence/wish_simulator_data_service.dart';

abstract class DataService {
  CalculatorAscMaterialsDataService get calculator;

  InventoryDataService get inventory;

  CustomBuildsDataService get customBuilds;

  NotificationsDataService get notifications;

  GameCodesDataService get gameCodes;

  TierListDataService get tierList;

  WishSimulatorDataService get wishSimulator;

  Future<void> init({String dir = 'shiori_data'});

  @visibleForTesting
  Future<void> initForTests(String path);

  Future<void> deleteThemAll();

  Future<void> closeThemAll();
}
