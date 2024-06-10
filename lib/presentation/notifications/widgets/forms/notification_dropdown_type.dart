import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/common_dropdown_button.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class NotificationDropdownType extends StatelessWidget {
  final AppNotificationType selectedValue;
  final bool isInEditMode;
  final bool isExpanded;

  const NotificationDropdownType({
    super.key,
    required this.selectedValue,
    required this.isInEditMode,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final translatedValues = EnumUtils.getTranslatedAndSortedEnum<AppNotificationType>(
      AppNotificationType.values,
      (type, _) => s.translateAppNotificationType(type),
    );

    return CommonDropdownButton<AppNotificationType>(
      title: s.notificationType,
      hint: s.notificationType,
      isExpanded: isExpanded,
      currentValue: translatedValues.firstWhere((el) => el.enumValue == selectedValue).enumValue,
      values: translatedValues,
      withoutUnderLine: false,
      onChanged: isInEditMode ? null : (v, _) => context.read<NotificationBloc>().add(NotificationEvent.typeChanged(newValue: v)),
    );
  }
}
