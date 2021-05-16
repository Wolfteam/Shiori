import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/notifications/widgets/notification_note.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';

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
    Key key,
    @required this.title,
    @required this.body,
    @required this.note,
    @required this.timeType,
    @required this.showNotification,
    @required this.withTimeReduction,
    @required this.isInEditMode,
    @required this.images,
    @required this.showOtherImages,
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
        Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: DropdownButton<ExpeditionTimeType>(
            isExpanded: true,
            hint: Text(s.chooseLanguage),
            value: timeType,
            onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.expeditionTimeTypeChanged(newValue: v)),
            items: ExpeditionTimeType.values
                .map<DropdownMenuItem<ExpeditionTimeType>>(
                  (type) => DropdownMenuItem<ExpeditionTimeType>(
                    value: type,
                    child: Text(s.translateExpeditionTimeType(type)),
                  ),
                )
                .toList(),
          ),
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
                activeColor: theme.accentColor,
              ),
            ),
            Expanded(child: NotificationSwitch(showNotification: showNotification)),
          ],
        ),
      ],
    );
  }
}
