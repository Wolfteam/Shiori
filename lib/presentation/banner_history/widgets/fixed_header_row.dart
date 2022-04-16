import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/images/circle_weapon.dart';
import 'package:shiori/presentation/shared/loading.dart';

const _dateFormat = 'yyyy/MM/dd';

class FixedHeaderRow extends StatelessWidget {
  final BannerHistoryItemType type;
  final List<double> versions;
  final List<double> selectedVersions;
  final EdgeInsets margin;
  final double firstCellWidth;
  final double firstCellHeight;
  final double cellWidth;
  final double cellHeight;

  const FixedHeaderRow({
    Key? key,
    required this.type,
    required this.versions,
    required this.selectedVersions,
    required this.margin,
    required this.firstCellWidth,
    required this.firstCellHeight,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: listview wont work inside a column...
    // return ListView.builder(
    //   itemCount: versions.length + 1,
    //   scrollDirection: Axis.horizontal,
    //   itemBuilder: (ctx, index) => index == 0
    //       ? _VersionsCharactersCell(cellWidth: firstCellWidth, cellHeight: firstCellHeight, margin: margin)
    //       : _VersionCard(cellWidth: cellWidth, cellHeight: cellHeight, margin: margin, version: versions[index - 1]),
    // );
    return Row(
      children: List.generate(
        versions.length + 1,
        (index) => index == 0
            ? _VersionsCharactersCell(type: type, cellWidth: firstCellWidth, cellHeight: firstCellHeight, margin: margin)
            : _VersionCard(
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                margin: margin,
                version: versions[index - 1],
                isSelected: selectedVersions.contains(versions[index - 1]),
              ),
      ),
    );
  }
}

class _VersionsCharactersCell extends StatelessWidget {
  final BannerHistoryItemType type;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _VersionsCharactersCell({
    Key? key,
    required this.type,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    String text = '';
    switch (type) {
      case BannerHistoryItemType.character:
        text = s.characters;
        break;
      case BannerHistoryItemType.weapon:
        text = s.weapons;
        break;
      default:
        throw Exception('Invalid banner history item type');
    }
    return Container(
      width: cellWidth,
      height: cellHeight,
      margin: margin,
      child: Transform.rotate(
        angle: math.pi / 6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.versions,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
            ),
            Divider(color: theme.colorScheme.primary, thickness: 3, indent: 5, endIndent: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final double version;
  final bool isSelected;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _VersionCard({
    Key? key,
    required this.version,
    required this.isSelected,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.read<BannerHistoryBloc>().add(BannerHistoryEvent.versionSelected(version: version)),
      onLongPress: () => showDialog(context: context, builder: (_) => _VersionDetailsDialog(version: version)),
      child: Card(
        margin: margin,
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.45) : theme.colorScheme.primary,
        elevation: isSelected ? 0 : 10,
        child: Container(
          alignment: Alignment.center,
          width: cellWidth,
          height: cellHeight,
          child: Text(
            '$version',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _VersionDetailsDialog extends StatelessWidget {
  final double version;

  const _VersionDetailsDialog({
    Key? key,
    required this.version,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = S.of(context);
    return BlocProvider<BannerHistoryItemBloc>(
      create: (context) => Injection.bannerHistoryItemBloc..add(BannerHistoryItemEvent.init(version: version)),
      child: AlertDialog(
        title: Text(s.appVersion(version)),
        content: SizedBox(
          width: mq.getWidthForDialogs(),
          child: SingleChildScrollView(
            child: BlocBuilder<BannerHistoryItemBloc, BannerHistoryItemState>(
              builder: (context, state) => state.maybeMap(
                loadedState: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: state.items
                      .groupListsBy((el) => '${DateFormat(_dateFormat).format(el.from)}_${DateFormat(_dateFormat).format(el.until)}')
                      .values
                      .map(
                    (e) {
                      final group = e.first;

                      return _VersionDetailPeriod(
                        from: group.from,
                        until: group.until,
                        items: e.expand((el) => el.items).toList(),
                      );
                    },
                  ).toList(),
                ),
                orElse: () => const Loading(useScaffold: false),
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.ok),
          )
        ],
      ),
    );
  }
}

class _VersionDetailPeriod extends StatelessWidget {
  final DateTime from;
  final DateTime until;
  final List<ItemCommonWithRarityAndType> items;

  const _VersionDetailPeriod({
    Key? key,
    required this.from,
    required this.until,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final from = DateFormat(_dateFormat).format(this.from);
    final until = DateFormat(_dateFormat).format(this.until);
    final characters = items.where((el) => el.type == ItemType.character).toList()..sort((x, y) => y.rarity.compareTo(x.rarity));
    final weapons = items.where((el) => el.type == ItemType.weapon).toList()..sort((x, y) => y.rarity.compareTo(x.rarity));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.fromDate(from), style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold)),
              Text(s.untilDate(until), style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: theme.colorScheme.primary),
          if (characters.isNotEmpty) Text(s.characters, style: theme.textTheme.subtitle1),
          if (characters.isNotEmpty)
            _Items(
              type: BannerHistoryItemType.character,
              items: characters,
            ),
          if (weapons.isNotEmpty) Text(s.weapons, style: theme.textTheme.subtitle1),
          if (weapons.isNotEmpty)
            _Items(
              type: BannerHistoryItemType.weapon,
              items: weapons,
            ),
        ],
      ),
    );
  }
}

class _Items extends StatelessWidget {
  final BannerHistoryItemType type;
  final List<ItemCommonWithRarityAndType> items;

  const _Items({
    Key? key,
    required this.type,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: type == BannerHistoryItemType.character ? 80 : 70,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (ctx, index) {
          final item = items[index];
          final gradient = item.rarity.getRarityGradient();
          switch (type) {
            case BannerHistoryItemType.character:
              return CircleCharacter(itemKey: item.key, image: item.image, gradient: gradient);
            case BannerHistoryItemType.weapon:
              return CircleWeapon(itemKey: item.key, image: item.image, gradient: gradient);
            default:
              throw Exception('Banner history item type = $type is not valid');
          }
        },
      ),
    );
  }
}
