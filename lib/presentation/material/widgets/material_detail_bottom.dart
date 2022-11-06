import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_bottom_portrait_layout.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/images/circle_monster.dart';
import 'package:shiori/presentation/shared/images/circle_weapon.dart';
import 'package:shiori/presentation/shared/images/wrapped_ascension_material.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/material_item_button.dart';

class MaterialDetailBottom extends StatelessWidget {
  final String? description;
  final int rarity;
  final List<ItemCommon> characters;
  final List<ItemCommon> weapons;
  final List<ItemObtainedFrom> obtainedFrom;
  final List<ItemCommon> relatedTo;
  final List<ItemCommon> droppedBy;

  const MaterialDetailBottom({
    super.key,
    this.description,
    required this.rarity,
    required this.characters,
    required this.weapons,
    required this.obtainedFrom,
    required this.relatedTo,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? _PortraitLayout(
            description: description,
            rarity: rarity,
            characters: characters,
            weapons: weapons,
            obtainedFrom: obtainedFrom,
            relatedTo: relatedTo,
            droppedBy: droppedBy,
          )
        : _LandscapeLayout(
            description: description,
            rarity: rarity,
            characters: characters,
            weapons: weapons,
            obtainedFrom: obtainedFrom,
            relatedTo: relatedTo,
            droppedBy: droppedBy,
          );
  }
}

class _ObtainedFromItem extends StatelessWidget {
  final ItemObtainedFrom from;
  final bool showDivider;

  const _ObtainedFromItem({required this.from, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final double size = getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile ? 35 : 70;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: from.items.map((e) => WrappedAscensionMaterial(itemKey: e.key, image: e.image, quantity: e.quantity, size: size * 2)).toList(),
        ),
        if (showDivider) const FractionallySizedBox(widthFactor: 0.8, child: Divider()),
      ],
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final String? description;
  final int rarity;
  final List<ItemCommon> characters;
  final List<ItemCommon> weapons;
  final List<ItemObtainedFrom> obtainedFrom;
  final List<ItemCommon> relatedTo;
  final List<ItemCommon> droppedBy;

  const _PortraitLayout({
    this.description,
    required this.rarity,
    required this.characters,
    required this.weapons,
    required this.obtainedFrom,
    required this.relatedTo,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final double size = getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile ? 35 : 70;
    final rarityColor = rarity.getRarityColors().last;
    return DetailBottomPortraitLayout(
      children: [
        if (description.isNotNullEmptyOrWhitespace)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: ItemDescriptionDetail(
              title: s.description,
              body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description!)),
              textColor: rarity.getRarityColors().last,
            ),
          ),
        if (obtainedFrom.isNotEmpty)
          ItemDescriptionDetail(
            title: s.obtainedFrom,
            body: Wrap(
              alignment: WrapAlignment.center,
              children: obtainedFrom.mapIndex((e, index) => _ObtainedFromItem(from: e, showDivider: index != obtainedFrom.length - 1)).toList(),
            ),
            textColor: rarityColor,
          ),
        if (characters.isNotEmpty)
          ItemDescriptionDetail(
            title: s.characters,
            body: Wrap(
              alignment: WrapAlignment.center,
              children: characters.map((e) => CircleCharacter(itemKey: e.key, image: e.image, radius: size)).toList(),
            ),
            textColor: rarityColor,
          ),
        if (weapons.isNotEmpty)
          ItemDescriptionDetail(
            title: s.weapons,
            body: Wrap(
              alignment: WrapAlignment.center,
              children: weapons.map((e) => CircleWeapon(itemKey: e.key, image: e.image, radius: size)).toList(),
            ),
            textColor: rarityColor,
          ),
        if (relatedTo.isNotEmpty)
          ItemDescriptionDetail(
            title: s.related,
            body: Wrap(
              alignment: WrapAlignment.center,
              children: relatedTo.map((e) => MaterialItemButton(itemKey: e.key, image: e.image, size: size * 2)).toList(),
            ),
            textColor: rarityColor,
          ),
        if (droppedBy.isNotEmpty)
          ItemDescriptionDetail(
            title: s.droppedBy,
            body: Wrap(
              alignment: WrapAlignment.center,
              children: droppedBy.map((e) => CircleMonster(itemKey: e.key, image: e.image, radius: size)).toList(),
            ),
            textColor: rarityColor,
          ),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final String? description;
  final int rarity;
  final List<ItemCommon> characters;
  final List<ItemCommon> weapons;
  final List<ItemObtainedFrom> obtainedFrom;
  final List<ItemCommon> relatedTo;
  final List<ItemCommon> droppedBy;

  const _LandscapeLayout({
    this.description,
    required this.rarity,
    required this.characters,
    required this.weapons,
    required this.obtainedFrom,
    required this.relatedTo,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tabs = <String>[];
    if (description.isNotNullEmptyOrWhitespace) {
      tabs.add(s.description);
    }
    if (obtainedFrom.isNotEmpty) {
      tabs.add(s.obtainedFrom);
    }
    if (characters.isNotEmpty) {
      tabs.add(s.characters);
    }
    if (weapons.isNotEmpty) {
      tabs.add(s.weapons);
    }
    if (relatedTo.isNotEmpty) {
      tabs.add(s.related);
    }
    if (droppedBy.isNotEmpty) {
      tabs.add(s.droppedBy);
    }
    final double size = getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile ? 35 : 70;
    final rarityColor = rarity.getRarityColors().last;
    return DetailTabLandscapeLayout(
      color: rarityColor,
      tabs: tabs,
      children: [
        if (description.isNotNullEmptyOrWhitespace)
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ItemDescriptionDetail(
                title: s.description,
                body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description!)),
                textColor: rarity.getRarityColors().last,
              ),
            ),
          ),
        if (obtainedFrom.isNotEmpty)
          SingleChildScrollView(
            child: ItemDescriptionDetail(
              title: s.obtainedFrom,
              body: Wrap(
                alignment: WrapAlignment.center,
                children: obtainedFrom.mapIndex((e, index) => _ObtainedFromItem(from: e, showDivider: index != obtainedFrom.length - 1)).toList(),
              ),
              textColor: rarityColor,
            ),
          ),
        if (characters.isNotEmpty)
          SingleChildScrollView(
            child: ItemDescriptionDetail(
              title: s.characters,
              body: Wrap(
                alignment: WrapAlignment.center,
                children: characters.map((e) => CircleCharacter(itemKey: e.key, image: e.image, radius: size)).toList(),
              ),
              textColor: rarityColor,
            ),
          ),
        if (weapons.isNotEmpty)
          SingleChildScrollView(
            child: ItemDescriptionDetail(
              title: s.weapons,
              body: Wrap(
                alignment: WrapAlignment.center,
                children: weapons.map((e) => CircleWeapon(itemKey: e.key, image: e.image, radius: size)).toList(),
              ),
              textColor: rarityColor,
            ),
          ),
        if (relatedTo.isNotEmpty)
          ItemDescriptionDetail(
            title: s.related,
            body: Wrap(
              alignment: WrapAlignment.center,
              children: relatedTo.map((e) => MaterialItemButton(itemKey: e.key, image: e.image, size: size * 2)).toList(),
            ),
            textColor: rarityColor,
          ),
        if (droppedBy.isNotEmpty)
          SingleChildScrollView(
            child: ItemDescriptionDetail(
              title: s.droppedBy,
              body: Wrap(
                alignment: WrapAlignment.center,
                children: droppedBy.map((e) => CircleMonster(itemKey: e.key, image: e.image, radius: size)).toList(),
              ),
              textColor: rarityColor,
            ),
          )
      ],
    );
  }
}
