import 'package:flutter/material.dart';

import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/weapon_type_extensions.dart';

class WeaponsButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buttons = WeaponType.values
        .map((e) => IconButton(
              // iconSize: 12,
              icon: Image.asset(e.getWeaponAssetPath()),
              onPressed: () => {},
              tooltip: 'Algo',
            ))
        .toList();

    return Wrap(
      children: buttons,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
    );
  }
}
