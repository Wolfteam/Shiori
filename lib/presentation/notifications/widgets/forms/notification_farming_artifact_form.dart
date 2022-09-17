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
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
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
    Key? key,
    required this.title,
    required this.body,
    required this.note,
    required this.artifactFarmingTimeType,
    required this.showNotification,
    required this.isInEditMode,
    required this.images,
    required this.showOtherImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NotificationCircleItem(type: _type, images: images, showOtherImages: showOtherImages),
        NotificationDropdownType(selectedValue: _type, isInEditMode: isInEditMode),
        DropdownButtonWithTitle<ArtifactFarmingTimeType>(
          title: s.time,
          currentValue: artifactFarmingTimeType,
          items: EnumUtils.getTranslatedAndSortedEnum(ArtifactFarmingTimeType.values, (val, _) => s.translateArtifactFarmingTimeType(val)),
          onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.artifactFarmingTimeTypeChanged(newValue: v)),
        ),
        NotificationTitleBody(title: title, body: body),
        NotificationNote(note: note),
        NotificationSwitch(showNotification: showNotification),
      ],
    );
  }
}
