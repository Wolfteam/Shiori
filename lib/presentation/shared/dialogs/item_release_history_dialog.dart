import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

const _dateFormat = 'yyyy/MM/dd';

class ItemReleaseHistoryDialog extends StatelessWidget {
  final String itemKey;
  final String itemName;
  final double? selectedVersion;

  const ItemReleaseHistoryDialog({
    Key? key,
    required this.itemKey,
    required this.itemName,
    this.selectedVersion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocProvider<ItemReleaseHistoryBloc>(
      create: (context) => Injection.itemReleaseHistoryBloc..add(ItemReleaseHistoryEvent.init(itemKey: itemKey)),
      child: AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.releaseHistory),
            Text(itemName, style: theme.textTheme.subtitle2),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.ok),
          )
        ],
        content: SingleChildScrollView(
          child: BlocBuilder<ItemReleaseHistoryBloc, ItemReleaseHistoryState>(
            builder: (context, state) => state.map(
              loading: (_) => const Loading(useScaffold: false),
              initial: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: state.history
                    .mapIndex(
                      (e, i) => _ReleasedOn(
                        history: e,
                        selected: e.version == selectedVersion,
                        lastItem: i == state.history.length - 1,
                        index: i,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReleasedOn extends StatelessWidget {
  final ItemReleaseHistoryModel history;
  final bool selected;
  final bool lastItem;
  final int index;

  const _ReleasedOn({
    Key? key,
    required this.history,
    required this.selected,
    required this.lastItem,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat(_dateFormat);
    final selectedColor = selected ? theme.colorScheme.primary.withOpacity(0.5) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Text(
            '${index + 1} -',
            style: theme.textTheme.caption!.copyWith(fontSize: 18, color: selectedColor),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: selectedColor,
                padding: selected ? Styles.edgeInsetHorizontal5.add(const EdgeInsets.only(top: 5)) : null,
                child: Text(
                  s.appVersion(history.version),
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ...history.dates.map(
                (e) => Container(
                  color: selectedColor,
                  padding: selected ? Styles.edgeInsetHorizontal5.add(const EdgeInsets.only(bottom: 5)) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(s.fromDate(dateFormat.format(e.from))),
                      Text(s.untilDate(dateFormat.format(e.until))),
                    ],
                  ),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }
}
