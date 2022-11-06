import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_list_subtitle_dates.dart';

class NotificationSubtitle extends StatelessWidget {
  final DateTime createdAt;
  final DateTime completesAt;
  final String? note;
  final List<Widget> children;
  final bool useTwentyFourHoursFormat;

  const NotificationSubtitle({
    super.key,
    required this.createdAt,
    required this.completesAt,
    required this.useTwentyFourHoursFormat,
    this.note,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (note.isNotNullEmptyOrWhitespace)
          Text(
            note!,
            style: theme.textTheme.subtitle2,
            overflow: TextOverflow.ellipsis,
          ),
        ...children,
        NotificationListSubtitleDates(
          createdAt: createdAt,
          completesAt: completesAt,
          useTwentyFourHoursFormat: useTwentyFourHoursFormat,
        ),
      ],
    );
  }
}
