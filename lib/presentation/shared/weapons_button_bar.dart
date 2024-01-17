import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';

class WeaponsButtonBar extends StatelessWidget {
  final List<WeaponType> selectedValues;
  final Function(WeaponType) onClick;
  final double iconSize;
  final bool enabled;

  const WeaponsButtonBar({
    super.key,
    required this.onClick,
    this.selectedValues = const [],
    this.iconSize = 24,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceEvenly,
      children: WeaponType.values.map((e) {
        final isSelected = selectedValues.isEmpty || !selectedValues.contains(e);
        return IconButton(
          iconSize: iconSize,
          icon: Opacity(
            opacity: !isSelected ? 1 : 0.2,
            child: Image.asset(
              e.getWeaponNormalSkillAssetPath(),
              width: iconSize * 1.3,
              height: iconSize * 1.3,
              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.5),
            ),
          ),
          onPressed: !enabled ? null : () => onClick(e),
          tooltip: s.translateWeaponType(e),
        );
      }).toList(),
    );
  }
}
