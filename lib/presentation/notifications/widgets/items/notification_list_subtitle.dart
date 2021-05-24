import 'package:flutter/material.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/utils/date_utils.dart' as utils;
import 'package:genshindb/generated/l10n.dart';

class NotificationSubtitle extends StatelessWidget {
  final DateTime createdAt;
  final DateTime completesAt;
  final String note;

  const NotificationSubtitle({
    Key key,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (note.isNotNullEmptyOrWhitespace) Text(note, style: theme.textTheme.subtitle2),
        Text(s.createdAtX(utils.DateUtils.formatDateWithoutLocale(createdAt)), style: theme.textTheme.caption),
        Text(s.completesAtX(utils.DateUtils.formatDateWithoutLocale(completesAt)), style: theme.textTheme.caption),
      ],
    );
  }
}
