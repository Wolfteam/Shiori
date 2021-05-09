import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/utils/date_utils.dart' as utils;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/notifications/widgets/notification_note.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';

import 'notification_circle_item.dart';
import 'notification_dropdown_type.dart';
import 'notification_switch.dart';
import 'notification_title_body.dart';

class NotificationCustomForm extends StatelessWidget {
  final AppNotificationItemType itemType;
  final String title;
  final String body;
  final String note;
  final bool showNotification;
  final bool isInEditMode;
  final List<NotificationItemImage> images;
  final bool showOtherImages;
  final DateTime scheduledDate;
  final LanguageModel language;

  const NotificationCustomForm({
    Key key,
    @required this.itemType,
    @required this.title,
    @required this.body,
    @required this.note,
    @required this.showNotification,
    @required this.isInEditMode,
    @required this.images,
    @required this.showOtherImages,
    @required this.scheduledDate,
    @required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NotificationCircleItem.custom(itemType: itemType, images: images, showOtherImages: showOtherImages),
        NotificationDropdownType(selectedValue: AppNotificationType.custom, isInEditMode: isInEditMode),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Expanded(
                flex: 40,
                child: DropdownButton<AppNotificationItemType>(
                  isExpanded: true,
                  hint: Text(s.notificationType),
                  value: itemType,
                  onChanged: isInEditMode ? null : (v) => context.read<NotificationBloc>().add(NotificationEvent.itemTypeChanged(newValue: v)),
                  items: AppNotificationItemType.values
                      .map((type) => DropdownMenuItem(value: type, child: Text(s.translateAppNotificationItemType(type))))
                      .toList(),
                ),
              ),
              const Spacer(flex: 10),
              Expanded(
                flex: 40,
                child: OutlinedButton(
                  onPressed: () => _showQuantityPickerDialog(context, 720),
                  child: Text(utils.DateUtils.formatDateWithoutLocale(scheduledDate), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
        //TODO: HOW WILL YOU RETRIEVE THE GADGET'S COOLDOWN ?
        NotificationTitleBody(title: title, body: body),
        NotificationNote(note: note),
        NotificationSwitch(showNotification: showNotification),
      ],
    );
  }

  Future<void> _showQuantityPickerDialog(BuildContext context, int value) async {
    final s = S.of(context);
    final now = DateTime.now();
    final locale = Locale(language.code, language.countryCode);
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      locale: locale,
    );

    if (date == null) {
      return;
    }

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) {
      return;
    }

    final scheduledDate = date.add(Duration(hours: time.hour, minutes: time.minute));

    if (scheduledDate.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      ToastUtils.showInfoToast(ToastUtils.of(context), s.invalidDate);
      return;
    }
    context.read<NotificationBloc>().add(NotificationEvent.customDateChanged(newValue: scheduledDate));
  }
}
