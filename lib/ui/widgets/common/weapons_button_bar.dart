import 'package:flutter/material.dart';

import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/extensions/weapon_type_extensions.dart';
import '../../../generated/l10n.dart';

class WeaponsButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttons = WeaponType.values
        .map(
          (e) => IconButton(
            // iconSize: 12,
            icon: Image.asset(e.getWeaponAssetPath()),
            onPressed: () => {},
            tooltip: s.translateWeaponType(e),
          ),
        )
        .toList();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: buttons,
    );
  }
}
