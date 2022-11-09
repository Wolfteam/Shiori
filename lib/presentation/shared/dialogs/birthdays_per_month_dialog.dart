import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/utils/date_utils.dart' as date_utils;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/dialogs/dialog_list_item_row.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';

class BirthdaysPerMonthDialog extends StatelessWidget {
  final int month;

  const BirthdaysPerMonthDialog({
    super.key,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    return BlocProvider<CharactersBirthdaysPerMonthBloc>(
      create: (context) => Injection.charactersBirthdaysPerMonthBloc..add(CharactersBirthdaysPerMonthEvent.init(month: month)),
      child: AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              date_utils.DateUtils.getMonthFullName(month),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              s.birthdays,
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
        content: BlocBuilder<CharactersBirthdaysPerMonthBloc, CharactersBirthdaysPerMonthState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => state.characters.isEmpty
                ? const NothingFoundColumn(mainAxisSize: MainAxisSize.min)
                : SizedBox(
                    height: mq.getHeightForDialogs(state.characters.length + state.characters.length ~/ 2),
                    width: mq.getWidthForDialogs(),
                    child: ListView.builder(
                      itemCount: state.characters.length,
                      itemBuilder: (context, index) {
                        final char = state.characters[index];
                        return DialogListItemRow(
                          itemType: ItemType.character,
                          itemKey: char.key,
                          image: char.image,
                          name: char.name,
                          getRowEndWidget: (_) => _RowEndColumn(character: char),
                        );
                      },
                    ),
                  ),
            orElse: () => const Loading(useScaffold: false, mainAxisSize: MainAxisSize.min),
          ),
        ),
      ),
    );
  }
}

class _RowEndColumn extends StatelessWidget {
  final CharacterBirthdayModel character;

  const _RowEndColumn({
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          character.name,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.subtitle1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              character.birthdayString,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.caption,
            ),
            Text(
              character.daysUntilBirthday > 0 ? s.inXDays(character.daysUntilBirthday) : s.today,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.caption!.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
