import 'package:collection/collection.dart' show IterableExtension;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/game_codes_data_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class GameCodesDataServiceImpl implements GameCodesDataService {
  final GenshinService _genshinService;
  final ResourceService _resourceService;

  late Box<GameCode> _gameCodesBox;
  late Box<GameCodeReward> _gameCodeRewardsBox;

  GameCodesDataServiceImpl(this._genshinService, this._resourceService);

  @override
  Future<void> init() async {
    _gameCodesBox = await Hive.openBox<GameCode>('gameCodes');
    _gameCodeRewardsBox = await Hive.openBox<GameCodeReward>('gameCodeRewards');
  }

  @override
  Future<void> deleteThemAll() async {
    await _gameCodesBox.clear();
    await _gameCodeRewardsBox.clear();
  }

  @override
  List<GameCodeModel> getAllGameCodes() {
    return _gameCodesBox.values.map((e) {
      final rewards = _gameCodeRewardsBox.values.where((el) => el.gameCodeKey == e.key).map((reward) {
        final material = _genshinService.materials.getMaterial(reward.itemKey);
        final imagePath = _resourceService.getMaterialImagePath(material.image, material.type);
        return ItemAscensionMaterialModel.fromMaterial(reward.quantity, material, imagePath);
      }).toList();
      //Some codes don't have an expiration date, that's why we use this boolean here
      final expired = e.isExpired || (e.expiredOn?.isBefore(DateTime.now()) ?? false);
      return GameCodeModel(
        code: e.code,
        isExpired: expired,
        expiredOn: e.expiredOn,
        discoveredOn: e.discoveredOn,
        isUsed: e.usedOn != null,
        rewards: rewards,
        region: e.region != null ? AppServerResetTimeType.values[e.region!] : null,
      );
    }).toList();
  }

  @override
  Future<void> saveGameCodes(List<GameCodeModel> itemsFromApi) async {
    final itemsOnDb = _gameCodesBox.values.toList();

    for (final item in itemsFromApi) {
      final gcOnDb = itemsOnDb.firstWhereOrNull((el) => el.code == item.code);
      if (gcOnDb != null) {
        gcOnDb.isExpired = item.isExpired;
        gcOnDb.expiredOn = item.expiredOn;
        gcOnDb.discoveredOn = item.discoveredOn;
        gcOnDb.region = item.region?.index;
        await gcOnDb.save();
        await deleteAllGameCodeRewards(gcOnDb.key as int);
        await saveGameCodeRewards(gcOnDb.key as int, item.rewards);
      } else {
        final gc = GameCode(item.code, null, item.discoveredOn, item.expiredOn, item.isExpired, item.region?.index);
        await _gameCodesBox.add(gc);
        //This line shouldn't be necessary, though for testing purposes I'll leave it here
        await deleteAllGameCodeRewards(gc.key as int);
        await saveGameCodeRewards(gc.key as int, item.rewards);
      }
    }
  }

  @override
  Future<void> saveGameCodeRewards(int gameCodeKey, List<ItemAscensionMaterialModel> rewards) {
    final rewardsToSave = rewards.map((e) => GameCodeReward(gameCodeKey, e.key, e.requiredQuantity)).toList();
    return _gameCodeRewardsBox.addAll(rewardsToSave);
  }

  @override
  Future<void> deleteAllGameCodeRewards(int gameCodeKey) {
    final keys = _gameCodeRewardsBox.values.where((el) => el.gameCodeKey == gameCodeKey).map((e) => e.key).toList();
    return _gameCodeRewardsBox.deleteAll(keys);
  }

  @override
  Future<void> markCodeAsUsed(String code, {bool wasUsed = true}) async {
    final usedGameCode = _gameCodesBox.values.firstWhereOrNull((el) => el.code == code)!;
    usedGameCode.usedOn = wasUsed ? DateTime.now() : null;
    await usedGameCode.save();
  }

  @override
  List<BackupGameCodeModel> getDataForBackup() {
    return _gameCodesBox.values.map((gameCode) {
      final rewards = _gameCodeRewardsBox.values.where((el) => el.gameCodeKey == gameCode.key).toList();
      return BackupGameCodeModel(
        code: gameCode.code,
        isExpired: gameCode.isExpired,
        discoveredOn: gameCode.discoveredOn,
        expiredOn: gameCode.expiredOn,
        region: gameCode.region,
        usedOn: gameCode.usedOn,
        rewards: rewards.map((e) => BackupGameCodeRewardModel(itemKey: e.itemKey, quantity: e.quantity)).toList(),
      );
    }).toList();
  }

  @override
  Future<void> restoreFromBackup(List<BackupGameCodeModel> data) async {
    await deleteThemAll();
    for (final gameCode in data) {
      final gc = GameCode(gameCode.code, gameCode.usedOn, gameCode.discoveredOn, gameCode.expiredOn, gameCode.isExpired, gameCode.region);
      await _gameCodesBox.add(gc);
      final rewards = gameCode.rewards.map((e) => GameCodeReward(gc.key as int, e.itemKey, e.quantity)).toList();
      await _gameCodeRewardsBox.addAll(rewards);
    }
  }
}
