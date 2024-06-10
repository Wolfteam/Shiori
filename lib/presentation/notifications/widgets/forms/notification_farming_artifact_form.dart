import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_circle_item.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_dropdown_type.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_note.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_switch.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_title_body.dart';
import 'package:shiori/presentation/shared/common_dropdown_button.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

const _type = AppNotificationType.farmingArtifacts;

class NotificationFarmingArtifactForm extends StatelessWidget {
  final String title;
  final String body;
  final String note;
  final ArtifactFarmingTimeType artifactFarmingTimeType;
  final bool showNotification;
  final bool isInEditMode;
  final List<NotificationItemImage> images;
  final bool showOtherImages;

  const NotificationFarmingArtifactForm({
    super.key,
    required this.title,
    required this.body,
    required this.note,
    required this.artifactFarmingTimeType,
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
        NotificationCircleItem(type: _type, images: images, showOtherImages: showOtherImages),
        NotificationDropdownType(selectedValue: _type, isInEditMode: isInEditMode),
        CommonDropdownButton<ArtifactFarmingTimeType>(
          title: s.time,
          hint: s.time,
          withoutUnderLine: false,
          currentValue: artifactFarmingTimeType,
          values: EnumUtils.getTranslatedAndSortedEnum(ArtifactFarmingTimeType.values, (val, _) => s.translateArtifactFarmingTimeType(val)),
          onChanged: (v, _) => context.read<NotificationBloc>().add(NotificationEvent.artifactFarmingTimeTypeChanged(newValue: v)),
        ),
        NotificationTitleBody(title: title, body: body),
        NotificationNote(note: note),
        NotificationSwitch(showNotification: showNotification),
      ],
    );
  }
}
