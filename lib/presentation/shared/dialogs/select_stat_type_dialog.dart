import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/select_enum_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class SelectStatTypeDialog extends StatelessWidget {
  final List<StatType> values;
  final List<StatType> excluded;
  final Function(StatType?)? onSave;
  final String? title;

  const SelectStatTypeDialog({
    super.key,
    required this.values,
    this.excluded = const <StatType>[],
    this.onSave,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final translatedValues = EnumUtils.getTranslatedAndSortedEnum<StatType>(values, (type, _) => s.translateStatTypeWithoutValue(type));
    return SelectEnumDialog<StatType>(
      title: title ?? s.stats,
      values: translatedValues.map((e) => e.enumValue).toList(),
      selectedValues: const <StatType>[],
      excluded: excluded,
      textResolver: (type) => translatedValues.firstWhere((el) => el.enumValue == type).translation,
      onSave: (type) => _onSave(type, context),
    );
  }

  void _onSave(StatType? type, BuildContext context) {
    onSave?.call(type);
    Navigator.pop<StatType>(context, type);
  }
}
