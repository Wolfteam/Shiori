import 'package:flutter/material.dart';
import 'package:genshindb/domain/utils/date_utils.dart' as utils;

class NotificationListSubtitleDates extends StatelessWidget {
  final DateTime createdAt;
  final DateTime completesAt;
  final bool useTwentyFourHoursFormat;

  const NotificationListSubtitleDates({
    Key key,
    @required this.createdAt,
    @required this.completesAt,
    @required this.useTwentyFourHoursFormat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5),
                child: const Icon(Icons.date_range, size: 13),
              ),
              Expanded(
                child: Text(
                  utils.DateUtils.formatDateMilitaryTime(createdAt, useTwentyFourHoursFormat: useTwentyFourHoursFormat),
                  style: theme.textTheme.caption,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5),
                child: const Icon(Icons.notifications_active, size: 13),
              ),
              Expanded(
                child: Text(
                  utils.DateUtils.formatDateMilitaryTime(completesAt, useTwentyFourHoursFormat: useTwentyFourHoursFormat),
                  style: theme.textTheme.caption,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
