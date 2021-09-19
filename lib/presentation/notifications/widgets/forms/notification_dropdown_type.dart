import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class NotificationDropdownType extends StatelessWidget {
  final AppNotificationType selectedValue;
  final bool isInEditMode;
  final bool isExpanded;

  const NotificationDropdownType({
    Key? key,
    required this.selectedValue,
    required this.isInEditMode,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final translatedValues = EnumUtils.getTranslatedAndSortedEnum<AppNotificationType>(
      AppNotificationType.values,
      (type) => s.translateAppNotificationType(type),
    );

    return DropdownButtonWithTitle<TranslatedEnum<AppNotificationType>>(
      margin: EdgeInsets.zero,
      title: s.notificationType,
      isExpanded: isExpanded,
      currentValue: translatedValues.firstWhere((el) => el.enumValue == selectedValue),
      items: translatedValues,
      itemBuilder: (translatedType, _) => Text(translatedType.translation, overflow: TextOverflow.ellipsis),
      onChanged: isInEditMode ? null : (v) => context.read<NotificationBloc>().add(NotificationEvent.typeChanged(newValue: v.enumValue)),
    );
  }
}
