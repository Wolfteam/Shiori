import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/dialogs/dialog_list_item_row.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';

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
            loaded: (state) => state.items.isEmpty
                ? const NothingFoundColumn(mainAxisSize: MainAxisSize.min)
                : SizedBox(
                    height: mq.getHeightForDialogs(state.items.length + 1),
                    width: mq.getWidthForDialogs(),
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) => DialogListItemRow.fromItem(itemType: itemType, item: state.items[index]),
                    ),
                  ),
            orElse: () => const Loading(useScaffold: false, mainAxisSize: MainAxisSize.min),
          ),
        ),
      ),
    );
  }
}
