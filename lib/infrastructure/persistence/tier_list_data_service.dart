import 'package:darq/darq.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/tier_list_data_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class TierListDataServiceImpl implements TierListDataService {
  final GenshinService _genshinService;
  final ResourceService _resourceService;

  late Box<TierListItem> _tierListBox;

  TierListDataServiceImpl(this._genshinService, this._resourceService);

  @override
  Future<void> init() async {
    _tierListBox = await Hive.openBox<TierListItem>('tierList');
  }

  @override
  Future<void> deleteThemAll() async {
    await _tierListBox.clear();
  }

  @override
  List<TierListRowModel> getTierList() {
    final values = _tierListBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    return values.map((e) {
      final characters = e.charKeys.map((e) {
        final character = _genshinService.characters.getCharacter(e);
        final image = _resourceService.getCharacterImagePath(character.image);
        final iconImage = _resourceService.getCharacterIconImagePath(character.iconImage);
        return ItemCommon(character.key, image, iconImage);
      }).toList();
      return TierListRowModel.row(tierText: e.text, items: characters, tierColor: e.color);
    }).toList();
  }

  @override
  Future<void> saveTierList(List<TierListRowModel> tierList) async {
    await deleteTierList();
    final toSave = tierList.mapIndex((e, i) => TierListItem(e.tierText, e.tierColor, i, e.items.map((i) => i.key).toList())).toList();
    await _tierListBox.addAll(toSave);
  }

  @override
  Future<void> deleteTierList() {
    return deleteThemAll();
  }

  @override
  List<BackupTierListModel> getDataForBackup() {
    return _tierListBox.values.map((e) => BackupTierListModel(text: e.text, position: e.position, color: e.color, charKeys: e.charKeys)).toList();
  }

  @override
  Future<void> restoreFromBackup(List<BackupTierListModel> data) {
    final tierList = data
        .orderBy((e) => e.position)
        .map((e) => TierListRowModel.row(tierText: e.text, items: e.charKeys.map((c) => ItemCommon(c, '', '')).toList(), tierColor: e.color))
        .toList();

    return saveTierList(tierList);
  }
}
