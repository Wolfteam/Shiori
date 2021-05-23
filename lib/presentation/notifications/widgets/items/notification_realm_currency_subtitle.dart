import 'package:flutter/material.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/utils/date_utils.dart' as utils;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';

class NotificationRealmCurrencySubtitle extends StatelessWidget {
  final int initialRealmCurrency;
  final RealmRankType currentRankType;
  final int currentTrustRank;
  final DateTime createdAt;
  final DateTime completesAt;
  final String note;

  const NotificationRealmCurrencySubtitle({
    Key key,
    @required this.initialRealmCurrency,
    @required this.currentRankType,
    @required this.currentTrustRank,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final currentValue = getCurrentRealmCurrency(initialRealmCurrency, currentTrustRank, currentRankType, completesAt);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$currentValue / ${getRealmMaxCurrency(currentTrustRank)}', style: theme.textTheme.bodyText2),
        Text('${s.realmRank}: ${s.translateRealRankType(currentRankType, showRatio: true)}', style: theme.textTheme.caption),
        Text('${s.trustRank}: $currentTrustRank', style: theme.textTheme.caption),
        if (note.isNotNullEmptyOrWhitespace) Text(note, style: theme.textTheme.subtitle2),
        Text(s.createdAtX(utils.DateUtils.formatDateWithoutLocale(createdAt)), style: theme.textTheme.caption),
        Text(s.completesAtX(utils.DateUtils.formatDateWithoutLocale(completesAt)), style: theme.textTheme.caption),
      ],
    );
  }
}
