import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/select_enum_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class SelectCharacterRoleSubTypeDialog extends StatelessWidget {
  final List<CharacterRoleSubType> excluded;
  final List<CharacterRoleSubType> selectedValues;
  final Function(CharacterRoleSubType?)? onSave;

  const SelectCharacterRoleSubTypeDialog({
    super.key,
    this.excluded = const <CharacterRoleSubType>[],
    this.selectedValues = const <CharacterRoleSubType>[],
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final translatedValues = EnumUtils.getTranslatedAndSortedEnum<CharacterRoleSubType>(
      CharacterRoleSubType.values,
      (type, _) => s.translateCharacterRoleSubType(type),
    );
    return SelectEnumDialog<CharacterRoleSubType>(
      title: s.subType,
      values: translatedValues.map((e) => e.enumValue).toList(),
      selectedValues: selectedValues,
      excluded: excluded,
      lineThroughOnSelectedValues: true,
      textResolver: (type) => translatedValues.firstWhere((el) => el.enumValue == type).translation,
      onSave: (type) => _onSave(type, context),
    );
  }

  void _onSave(CharacterRoleSubType? type, BuildContext context) {
    onSave?.call(type);
    Navigator.pop<CharacterRoleSubType>(context, type);
  }
}
