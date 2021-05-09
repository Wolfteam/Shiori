import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_bottom_sheet.dart';

import 'notification_custom_form.dart';
import 'notification_expedition_form.dart';
import 'notification_resin_form.dart';

class AddEditNotificationBottomSheet extends StatelessWidget {
  final bool isInEditMode;

  const AddEditNotificationBottomSheet({
    Key key,
    @required this.isInEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (ctx, state) => CommonBottomSheet(
        titleIcon: isInEditMode ? Icons.edit : Icons.add,
        title: isInEditMode ? s.editNotification : s.addNotification,
        onOk: !state.isBodyValid || !state.isTitleValid
            ? null
            : () {
                context.read<NotificationBloc>().add(const NotificationEvent.saveChanges());
                Navigator.pop(context);
              },
        onCancel: () => Navigator.pop(context),
        child: state.map(
          resin: (state) => NotificationResinForm(
            title: state.title,
            body: state.body,
            showNotification: state.showNotification,
            currentResin: state.currentResin,
            note: state.note,
            isInEditMode: isInEditMode,
            images: state.images,
            showOtherImages: state.showOtherImages,
          ),
          expedition: (state) => NotificationExpeditionForm(
            title: state.title,
            body: state.body,
            note: state.note,
            showNotification: state.showNotification,
            timeType: state.expeditionTimeType,
            isInEditMode: isInEditMode,
            withTimeReduction: state.withTimeReduction,
            images: state.images,
            showOtherImages: state.showOtherImages,
          ),
          custom: (state) => NotificationCustomForm(
            itemType: state.itemType,
            title: state.title,
            body: state.body,
            note: state.note,
            showNotification: state.showNotification,
            isInEditMode: isInEditMode,
            images: state.images,
            showOtherImages: state.showOtherImages,
            scheduledDate: state.scheduledDate,
            language: state.language,
          ),
        ),
      ),
    );
  }
}
