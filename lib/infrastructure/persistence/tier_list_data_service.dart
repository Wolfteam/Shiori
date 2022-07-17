import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/tier_list_data_service.dart';

class TierListDataServiceImpl implements TierListDataService {
  final GenshinService _genshinService;
  late Box<TierListItem> _tierListBox;

  TierListDataServiceImpl(this._genshinService);

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
        return ItemCommon(character.key, character.fullImagePath);
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
  Future<void> deleteTierList() async {
    final keys = _tierListBox.values.map((e) => e.key);
    await _tierListBox.deleteAll(keys);
  }
}
