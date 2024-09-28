import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_circle_item.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_dropdown_type.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_note.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_switch.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_title_body.dart';
import 'package:shiori/presentation/shared/dialogs/number_picker_dialog.dart';

class NotificationResinForm extends StatelessWidget {
  final String title;
  final String body;
  final int currentResin;
  final String note;
  final bool showNotification;
  final bool isInEditMode;
  final List<NotificationItemImage> images;
  final bool showOtherImages;

  const NotificationResinForm({
    super.key,
    required this.title,
    required this.body,
    required this.currentResin,
    required this.note,
    required this.showNotification,
    required this.isInEditMode,
    required this.images,
    required this.showOtherImages,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NotificationCircleItem(type: AppNotificationType.resin, images: images, showOtherImages: showOtherImages),
        Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 40,
              child: NotificationDropdownType(selectedValue: AppNotificationType.resin, isInEditMode: isInEditMode),
            ),
            const Spacer(flex: 10),
            Flexible(
              fit: FlexFit.tight,
              flex: 40,
              child: OutlinedButton(
                onPressed: () => _showQuantityPickerDialog(context, currentResin),
                child: Text(s.currentX(currentResin)),
              ),
            ),
          ],
        ),
        Container(margin: const EdgeInsets.only(top: 15), child: NotificationTitleBody(title: title, body: body)),
        NotificationNote(note: note),
        NotificationSwitch(showNotification: showNotification),
      ],
    );
  }

  Future<void> _showQuantityPickerDialog(BuildContext context, int value) async {
    final s = S.of(context);
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) => NumberPickerDialog(
        maxItemLevel: maxResinValue - 1,
        minItemLevel: minResinValue,
        value: value,
        title: s.resin,
      ),
    ).then((newValue) {
      if (newValue == null || !context.mounted) {
        return;
      }

      context.read<NotificationBloc>().add(NotificationEvent.resinChanged(newValue: newValue));
    });
  }
}
