import 'package:flutter/material.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/utils/date_utils.dart' as utils;
import 'package:genshindb/generated/l10n.dart';

class NotificationResinSubtitle extends StatelessWidget {
  final int initialResin;
  final DateTime createdAt;
  final DateTime completesAt;
  final String note;

  const NotificationResinSubtitle({
    Key key,
    @required this.initialResin,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final currentValue = getCurrentResin(initialResin, completesAt);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$currentValue / $maxResinValue', style: theme.textTheme.bodyText2),
        if (note.isNotNullEmptyOrWhitespace) Text(note, style: theme.textTheme.subtitle2),
        Text(s.createdAtX(utils.DateUtils.formatDateWithoutLocale(createdAt)), style: theme.textTheme.caption),
        Text(s.completesAtX(utils.DateUtils.formatDateWithoutLocale(completesAt)), style: theme.textTheme.caption),
      ],
    );
  }
}
