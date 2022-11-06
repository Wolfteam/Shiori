import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_list_subtitle.dart';

class NotificationResinSubtitle extends StatelessWidget {
  final int initialResin;
  final DateTime createdAt;
  final DateTime completesAt;
  final String? note;
  final bool useTwentyFourHoursFormat;

  const NotificationResinSubtitle({
    super.key,
    required this.initialResin,
    required this.createdAt,
    required this.completesAt,
    required this.useTwentyFourHoursFormat,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = getCurrentResin(initialResin, completesAt);
    return NotificationSubtitle(
      createdAt: createdAt,
      completesAt: completesAt,
      useTwentyFourHoursFormat: useTwentyFourHoursFormat,
      note: note,
      children: [
        Text('$currentValue / $maxResinValue', style: theme.textTheme.bodyText2),
      ],
    );
  }
}
