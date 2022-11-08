import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/select_enum_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class SelectCharacterRoleTypeDialog extends StatelessWidget {
  final List<CharacterRoleType> excluded;
  final List<CharacterRoleType> selectedValues;
  final Function(CharacterRoleType?)? onSave;

  const SelectCharacterRoleTypeDialog({
    super.key,
    this.excluded = const <CharacterRoleType>[],
    this.selectedValues = const <CharacterRoleType>[],
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final translatedValues = EnumUtils.getTranslatedAndSortedEnum<CharacterRoleType>(
      CharacterRoleType.values,
      (type, _) => s.translateCharacterRoleType(type),
    );
    return SelectEnumDialog<CharacterRoleType>(
      title: s.role,
      values: translatedValues.map((e) => e.enumValue).toList(),
      selectedValues: selectedValues,
      excluded: excluded,
      lineThroughOnSelectedValues: true,
      textResolver: (type) => translatedValues.firstWhere((el) => el.enumValue == type).translation,
      onSave: (type) => _onSave(type, context),
    );
  }

  void _onSave(CharacterRoleType? type, BuildContext context) {
    onSave?.call(type);
    Navigator.pop<CharacterRoleType>(context, type);
  }
}
