import 'package:flutter/material.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';

import 'notification_list_subtitle.dart';

class NotificationRealmCurrencySubtitle extends StatelessWidget {
  final int initialRealmCurrency;
  final RealmRankType currentRankType;
  final int currentTrustRank;
  final DateTime createdAt;
  final DateTime completesAt;
  final String note;
  final bool useTwentyFourHoursFormat;

  const NotificationRealmCurrencySubtitle({
    Key key,
    @required this.initialRealmCurrency,
    @required this.currentRankType,
    @required this.currentTrustRank,
    @required this.createdAt,
    @required this.completesAt,
    @required this.useTwentyFourHoursFormat,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final currentValue = getCurrentRealmCurrency(initialRealmCurrency, currentTrustRank, currentRankType, completesAt);

    return NotificationSubtitle(
      createdAt: createdAt,
      completesAt: completesAt,
      useTwentyFourHoursFormat: useTwentyFourHoursFormat,
      children: [
        Text('$currentValue / ${getRealmMaxCurrency(currentTrustRank)}', style: theme.textTheme.bodyText2),
        Text('${s.realmRank}: ${s.translateRealRankType(currentRankType, showRatio: true)}', style: theme.textTheme.caption),
        Text('${s.trustRank}: $currentTrustRank', style: theme.textTheme.caption),
      ],
    );
  }
}
