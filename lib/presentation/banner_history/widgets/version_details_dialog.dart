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

class VersionDetailsDialog extends StatelessWidget {
  final double version;
  final bool showWeapons;
  final bool showCharacters;

  const VersionDetailsDialog({
    Key? key,
    required this.version,
    this.showCharacters = true,
    this.showWeapons = true,
  })  : assert(!(showCharacters == false && showWeapons == false), 'You must show either characters, weapons or both'),
        super(key: key);

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
                        showCharacters: showCharacters,
                        showWeapons: showWeapons,
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
  final bool showWeapons;
  final bool showCharacters;

  const _VersionDetailPeriod({
    Key? key,
    required this.from,
    required this.until,
    required this.items,
    required this.showCharacters,
    required this.showWeapons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final from = DateFormat(_dateFormat).format(this.from);
    final until = DateFormat(_dateFormat).format(this.until);
    final characters = items.where((el) => el.type == ItemType.character).toList()..sort((x, y) => y.rarity.compareTo(x.rarity));
    final weapons = items.where((el) => el.type == ItemType.weapon).toList()..sort((x, y) => y.rarity.compareTo(x.rarity));

    if (characters.isEmpty && !showWeapons || weapons.isEmpty && !showCharacters) {
      return const SizedBox.shrink();
    }

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
          if (characters.isNotEmpty && showCharacters) Text(s.characters, style: theme.textTheme.subtitle1),
          if (characters.isNotEmpty && showCharacters)
            _Items(
              type: BannerHistoryItemType.character,
              items: characters,
            ),
          if (weapons.isNotEmpty && showWeapons) Text(s.weapons, style: theme.textTheme.subtitle1),
          if (weapons.isNotEmpty && showWeapons)
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
