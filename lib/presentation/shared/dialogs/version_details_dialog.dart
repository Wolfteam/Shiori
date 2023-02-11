import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
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
import 'package:shiori/presentation/shared/nothing_found_column.dart';

class VersionDetailsDialog extends StatelessWidget {
  final double version;
  final bool showWeapons;
  final bool showCharacters;

  const VersionDetailsDialog({
    super.key,
    required this.version,
    this.showCharacters = true,
    this.showWeapons = true,
  }) : assert(!(showCharacters == false && showWeapons == false), 'You must show either characters, weapons or both');

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
                loadedState: (state) => state.items.isEmpty
                    ? const NothingFoundColumn(mainAxisSize: MainAxisSize.min)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: state.items
                            .map(
                              (e) => _VersionDetailPeriod(
                                from: e.from,
                                until: e.until,
                                items: e.items,
                                showCharacters: showCharacters,
                                showWeapons: showWeapons,
                              ),
                            )
                            .toList(),
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
  final String from;
  final String until;
  final List<ItemCommonWithRarityAndType> items;
  final bool showWeapons;
  final bool showCharacters;

  const _VersionDetailPeriod({
    required this.from,
    required this.until,
    required this.items,
    required this.showCharacters,
    required this.showWeapons,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
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
          ScreenTypeLayout(
            mobile: _DetailDates(from: from, until: until, useRow: false),
            tablet: _DetailDates(from: from, until: until, useRow: true),
            desktop: _DetailDates(from: from, until: until, useRow: true),
          ),
          Divider(color: theme.colorScheme.primary),
          if (characters.isNotEmpty && showCharacters) Text(s.characters, style: theme.textTheme.titleMedium),
          if (characters.isNotEmpty && showCharacters)
            _Items(
              type: BannerHistoryItemType.character,
              items: characters,
            ),
          if (weapons.isNotEmpty && showWeapons) Text(s.weapons, style: theme.textTheme.titleMedium),
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
    required this.type,
    required this.items,
  });

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

class _DetailDates extends StatelessWidget {
  final String from;
  final String until;
  final bool useRow;

  const _DetailDates({
    required this.from,
    required this.until,
    required this.useRow,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final fromString = s.fromDate(from);
    final untilString = s.untilDate(until);
    final fromWidget = Tooltip(
      message: fromString,
      child: Text(
        fromString,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
    final untilWidget = Tooltip(
      message: untilString,
      child: Text(
        untilString,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
    if (useRow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: fromWidget),
          Expanded(child: untilWidget),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fromWidget,
        untilWidget,
      ],
    );
  }
}
