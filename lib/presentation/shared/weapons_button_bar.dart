import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/weapon_type_extensions.dart';
import 'package:genshindb/generated/l10n.dart';

import 'extensions/i18n_extensions.dart';

class WeaponsButtonBar extends StatelessWidget {
  final List<WeaponType> selectedValues;
  final Function(WeaponType) onClick;

  const WeaponsButtonBar({
    Key? key,
    required this.onClick,
    this.selectedValues = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttons = WeaponType.values.map((e) => _buildIconButton(e, s.translateWeaponType(e))).toList();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: buttons,
    );
  }

  Widget _buildIconButton(WeaponType value, String tooltip) {
    final isSelected = selectedValues.isEmpty || !selectedValues.contains(value);
    return IconButton(
      icon: Opacity(
        opacity: !isSelected ? 1 : 0.2,
        child: Image.asset(value.getWeaponAssetPath()),
      ),
      onPressed: () => onClick(value),
      tooltip: tooltip,
    );
  }
}
