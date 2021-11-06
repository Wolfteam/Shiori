import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_note.dart';
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

import 'notification_circle_item.dart';
import 'notification_dropdown_type.dart';
import 'notification_switch.dart';
import 'notification_title_body.dart';

class NotificationExpeditionForm extends StatelessWidget {
  final String title;
  final String body;
  final String note;
  final ExpeditionTimeType timeType;
  final bool showNotification;
  final bool withTimeReduction;
  final bool isInEditMode;
  final List<NotificationItemImage> images;
  final bool showOtherImages;

  const NotificationExpeditionForm({
    Key? key,
    required this.title,
    required this.body,
    required this.note,
    required this.timeType,
    required this.showNotification,
    required this.withTimeReduction,
    required this.isInEditMode,
    required this.images,
    required this.showOtherImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NotificationCircleItem(type: AppNotificationType.expedition, images: images, showOtherImages: showOtherImages),
        NotificationDropdownType(selectedValue: AppNotificationType.expedition, isInEditMode: isInEditMode),
        DropdownButtonWithTitle<ExpeditionTimeType>(
          title: s.expeditionTime,
          items: EnumUtils.getTranslatedAndSortedEnum(ExpeditionTimeType.values, (val, _) => s.translateExpeditionTimeType(val)),
          currentValue: timeType,
          onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.expeditionTimeTypeChanged(newValue: v)),
        ),
        NotificationTitleBody(title: title, body: body),
        NotificationNote(note: note),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.twentyFivePercentTimeReduction),
                value: withTimeReduction,
                onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.timeReductionChanged(withTimeReduction: v)),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: theme.colorScheme.secondary,
              ),
            ),
            Expanded(child: NotificationSwitch(showNotification: showNotification)),
          ],
        ),
      ],
    );
  }
}
