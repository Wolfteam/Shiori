import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_list_subtitle.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';

class NotificationRealmCurrencySubtitle extends StatelessWidget {
  final int initialRealmCurrency;
  final RealmRankType currentRankType;
  final int currentTrustRank;
  final DateTime createdAt;
  final DateTime completesAt;
  final String? note;
  final bool useTwentyFourHoursFormat;

  const NotificationRealmCurrencySubtitle({
    super.key,
    required this.initialRealmCurrency,
    required this.currentRankType,
    required this.currentTrustRank,
    required this.createdAt,
    required this.completesAt,
    required this.useTwentyFourHoursFormat,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final currentValue = getCurrentRealmCurrency(initialRealmCurrency, currentTrustRank, currentRankType, completesAt);

    return NotificationSubtitle(
      createdAt: createdAt,
      completesAt: completesAt,
      useTwentyFourHoursFormat: useTwentyFourHoursFormat,
      note: note,
      children: [
        Text('$currentValue / ${getRealmMaxCurrency(currentTrustRank)}', style: theme.textTheme.bodyMedium),
        Text('${s.realmRank}: ${s.translateRealRankType(currentRankType, showRatio: true)}', style: theme.textTheme.bodySmall),
        Text('${s.trustRank}: $currentTrustRank', style: theme.textTheme.bodySmall),
      ],
    );
  }
}
