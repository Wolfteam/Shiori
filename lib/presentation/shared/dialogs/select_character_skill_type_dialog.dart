import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/select_enum_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class SelectCharacterSkillTypeDialog extends StatelessWidget {
  final List<CharacterSkillType> excluded;
  final List<CharacterSkillType> selectedValues;
  final Function(CharacterSkillType?)? onSave;

  const SelectCharacterSkillTypeDialog({
    Key? key,
    this.excluded = const <CharacterSkillType>[],
    this.selectedValues = const <CharacterSkillType>[],
    this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final translatedValues = EnumUtils.getTranslatedAndSortedEnum<CharacterSkillType>(
      CharacterSkillType.values,
      (type, _) => s.translateCharacterSkillType(type),
    );
    return SelectEnumDialog<CharacterSkillType>(
      title: s.talentsAscension,
      values: translatedValues.map((e) => e.enumValue).toList(),
      selectedValues: selectedValues,
      excluded: excluded,
      lineThroughOnSelectedValues: true,
      textResolver: (type) => translatedValues.firstWhere((el) => el.enumValue == type).translation,
      onSave: (type) => _onSave(type, context),
    );
  }

  void _onSave(CharacterSkillType? type, BuildContext context) {
    onSave?.call(type);
    Navigator.pop<CharacterSkillType>(context, type);
  }
}
