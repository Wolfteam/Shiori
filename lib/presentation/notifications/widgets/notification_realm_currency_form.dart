import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/dropdown_button_with_title.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/number_picker_dialog.dart';

import 'notification_circle_item.dart';
import 'notification_dropdown_type.dart';
import 'notification_note.dart';
import 'notification_switch.dart';
import 'notification_title_body.dart';

const _type = AppNotificationType.realmCurrency;

class NotificationRealmCurrency extends StatelessWidget {
  final String title;
  final String body;
  final int currentRealmCurrency;
  final String note;
  final bool showNotification;
  final bool isInEditMode;
  final List<NotificationItemImage> images;
  final bool showOtherImages;
  final RealmRankType currentRankType;
  final int currentTrustRank;

  const NotificationRealmCurrency({
    Key key,
    @required this.title,
    @required this.body,
    @required this.currentRealmCurrency,
    @required this.note,
    @required this.showNotification,
    @required this.isInEditMode,
    @required this.images,
    @required this.showOtherImages,
    @required this.currentRankType,
    @required this.currentTrustRank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NotificationCircleItem(type: _type, images: images, showOtherImages: showOtherImages),
        Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 60,
              child: NotificationDropdownType(selectedValue: _type, isInEditMode: isInEditMode),
            ),
            const Spacer(flex: 10),
            Flexible(
              fit: FlexFit.tight,
              flex: 30,
              child: OutlinedButton(
                onPressed: () => _showRealmRankLevelPickerDialog(context),
                child: Text(s.currentX(currentRealmCurrency)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 40,
              child: DropdownButtonWithTitle<RealmRankType>(
                title: s.realmRank,
                currentValue: currentRankType,
                items: RealmRankType.values,
                itemBuilder: (type, index) => DropdownMenuItem<RealmRankType>(
                  value: type,
                  child: Text('# ${index + 1} - ${s.translateRealRankType(type)}'),
                ),
                onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.realmRankTypeChanged(newValue: v)),
              ),
            ),
            const Spacer(flex: 10),
            Expanded(
              flex: 40,
              child: DropdownButtonWithTitle<int>(
                title: s.trustRank,
                currentValue: currentTrustRank,
                items: trustRank.keys,
                itemBuilder: (level, _) => DropdownMenuItem<int>(value: level, child: Text('$level')),
                onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.realmTrustRankLevelChanged(newValue: v)),
              ),
            ),
          ],
        ),
        NotificationTitleBody(title: title, body: body),
        NotificationNote(note: note),
        NotificationSwitch(showNotification: showNotification),
      ],
    );
  }

  Future<void> _showRealmRankLevelPickerDialog(BuildContext context) async {
    final s = S.of(context);
    final max = getMaxRealmCurrency(currentTrustRank);
    final newValue = await showDialog<int>(
      context: context,
      builder: (_) => NumberPickerDialog(
        maxItemLevel: max - 1,
        minItemLevel: 0,
        value: currentRealmCurrency,
        title: s.realmCurrency,
      ),
    );

    if (newValue == null) {
      return;
    }

    context.read<NotificationBloc>().add(NotificationEvent.realmCurrencyChanged(newValue: newValue));
  }
}
