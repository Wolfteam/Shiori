import 'package:flutter/material.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/circle_character.dart';
import 'package:genshindb/presentation/shared/circle_monster.dart';
import 'package:genshindb/presentation/shared/circle_weapon.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/material_item_button.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/wrapped_ascension_material.dart';

class MaterialDetailBottom extends StatelessWidget {
  final String? description;
  final int rarity;
  final List<String> charImgs;
  final List<String> weaponImgs;
  final List<ObtainedFromFileModel> obtainedFrom;
  final List<String> relatedTo;
  final List<String> droppedBy;

  const MaterialDetailBottom({
    Key? key,
    this.description,
    required this.rarity,
    required this.charImgs,
    required this.weaponImgs,
    required this.obtainedFrom,
    required this.relatedTo,
    required this.droppedBy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rarityColor = rarity.getRarityColors().last;
    return Card(
      margin: const EdgeInsets.only(top: 260, right: 10, left: 10),
      shape: Styles.cardItemDetailShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          children: [
            if (description.isNotNullEmptyOrWhitespace) _buildDescription(description!, rarity, context),
            if (obtainedFrom.isNotEmpty)
              ItemDescriptionDetail(
                title: s.obtainedFrom,
                body: Wrap(
                  alignment: WrapAlignment.center,
                  children: obtainedFrom.mapIndex((e, index) => _buildObtainedFromItem(e, showDivider: index != obtainedFrom.length - 1)).toList(),
                ),
                textColor: rarityColor,
              ),
            if (charImgs.isNotEmpty)
              ItemDescriptionDetail(
                title: s.characters,
                body: Wrap(
                  alignment: WrapAlignment.center,
                  children: charImgs.map((e) => CircleCharacter(image: e)).toList(),
                ),
                textColor: rarityColor,
              ),
            if (weaponImgs.isNotEmpty)
              ItemDescriptionDetail(
                title: s.weapons,
                body: Wrap(
                  alignment: WrapAlignment.center,
                  children: weaponImgs.map((e) => CircleWeapon(image: e)).toList(),
                ),
                textColor: rarityColor,
              ),
            if (relatedTo.isNotEmpty)
              ItemDescriptionDetail(
                title: s.related,
                body: Wrap(
                  alignment: WrapAlignment.center,
                  children: relatedTo.map((e) => MaterialItemButton(image: e, size: 55)).toList(),
                ),
                textColor: rarityColor,
              ),
            if (droppedBy.isNotEmpty)
              ItemDescriptionDetail(
                title: s.droppedBy,
                body: Wrap(
                  alignment: WrapAlignment.center,
                  children: droppedBy.map((e) => CircleMonster(image: e)).toList(),
                ),
                textColor: rarityColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObtainedFromItem(ObtainedFromFileModel from, {bool showDivider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: from.items.map((e) => WrappedAscensionMaterial(image: e.fullImagePath, quantity: e.quantity, size: 55)).toList(),
        ),
        if (showDivider) const FractionallySizedBox(widthFactor: 0.8, child: Divider()),
      ],
    );
  }

  Widget _buildDescription(String description, int rarity, BuildContext context) {
    final s = S.of(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ItemDescriptionDetail(
            title: s.description,
            body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
            textColor: rarity.getRarityColors().last,
          ),
        ),
      ],
    );
    return body;
  }
}
