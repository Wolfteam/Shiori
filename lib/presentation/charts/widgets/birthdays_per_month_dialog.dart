import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/birthdays_per_month/birthdays_per_month_bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/utils/date_utils.dart' as date_utils;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

class BirthdaysPerMonthDialog extends StatelessWidget {
  final int month;

  const BirthdaysPerMonthDialog({
    Key? key,
    required this.month,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    return BlocProvider<BirthdaysPerMonthBloc>(
      create: (context) => Injection.birthdaysPerMonthBloc..add(BirthdaysPerMonthEvent.init(month: month)),
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
        content: BlocBuilder<BirthdaysPerMonthBloc, BirthdaysPerMonthState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => SizedBox(
              height: mq.getHeightForDialogs(state.characters.length + state.characters.length ~/ 2),
              width: mq.getWidthForDialogs(),
              child: ListView.builder(
                itemCount: state.characters.length,
                itemBuilder: (context, index) => _Row(character: state.characters[index]),
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
  final CharacterBirthdayModel character;

  const _Row({
    Key? key,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleCharacter(
              itemKey: character.key,
              image: character.image,
              radius: 40,
            ),
            Expanded(
              child: Padding(
                padding: Styles.edgeInsetHorizontal16,
                child: Column(
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
