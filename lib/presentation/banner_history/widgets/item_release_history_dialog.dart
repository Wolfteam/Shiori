import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/loading.dart';

const _dateFormat = 'yyyy/MM/dd';

class ItemReleaseHistoryDialog extends StatelessWidget {
  final String itemKey;

  const ItemReleaseHistoryDialog({
    Key? key,
    required this.itemKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider<ItemReleaseHistoryBloc>(
      create: (context) => Injection.itemReleaseHistoryBloc..add(ItemReleaseHistoryEvent.init(itemKey: itemKey)),
      child: AlertDialog(
        title: Text(s.bannerHistory),
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
                children: state.history.map((e) => _ReleasedOn(history: e)).toList(),
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

  const _ReleasedOn({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat(_dateFormat);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.appVersion(history.version),
            style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          ...history.dates.map(
            (e) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.fromDate(dateFormat.format(e.from))),
                Text(s.untilDate(dateFormat.format(e.until))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
