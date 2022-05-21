import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/images/circle_weapon.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ItemsAscensionStatsDialog extends StatelessWidget {
  final ItemType itemType;
  final StatType statType;

  const ItemsAscensionStatsDialog({
    Key? key,
    required this.itemType,
    required this.statType,
  })  : assert(itemType == ItemType.character || itemType == ItemType.weapon),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    return BlocProvider<ItemsAscensionStatsBloc>(
      create: (context) => Injection.itemsAscensionStatsBloc..add(ItemsAscensionStatsEvent.init(type: statType, itemType: itemType)),
      child: AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.translateStatTypeWithoutValue(statType),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              itemType == ItemType.character ? s.characters : s.weapons,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.caption,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.ok),
          )
        ],
        content: BlocBuilder<ItemsAscensionStatsBloc, ItemsAscensionStatsState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => SizedBox(
              height: mq.getHeightForDialogs(state.items.length + 1),
              width: mq.getWidthForDialogs(),
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) => _Row(itemType: itemType, item: state.items[index]),
              ),
            ),
            orElse: () => const Loading(useScaffold: false),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final ItemType itemType;
  final ItemCommonWithName item;

  const _Row({
    Key? key,
    required this.itemType,
    required this.item,
  })  : assert(itemType == ItemType.character || itemType == ItemType.weapon),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (itemType == ItemType.character)
              CircleCharacter(itemKey: item.key, image: item.image, radius: 40)
            else
              CircleWeapon(itemKey: item.key, image: item.image, radius: 40),
            Expanded(
              child: Padding(
                padding: Styles.edgeInsetHorizontal16,
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: theme.textTheme.subtitle1,
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
