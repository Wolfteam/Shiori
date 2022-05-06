import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class VersionDetailsDialog extends StatelessWidget {
  final double version;

  const VersionDetailsDialog({
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
                  children: state.items.map((e) => _VersionDetailPeriod(from: e.from, until: e.until, items: e.items)).toList(),
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
