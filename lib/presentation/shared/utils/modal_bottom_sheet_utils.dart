import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/presentation/artifacts/widgets/artifact_bottom_sheet.dart' as artifacts;
import 'package:genshindb/presentation/calculator_asc_materials/widgets/add_edit_item_bottom_sheet.dart' as calc_asc_mat;
import 'package:genshindb/presentation/characters/widgets/character_bottom_sheet.dart' as characters;
import 'package:genshindb/presentation/materials/widgets/material_bottom_sheet.dart' as materials;
import 'package:genshindb/presentation/monsters/widgets/monster_bottom_sheet.dart' as monsters;
import 'package:genshindb/presentation/notifications/widgets/add_edit_notification_bottom_sheet.dart' as notifications;
import 'package:genshindb/presentation/shared/bottom_sheets/custom_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/weapons/widgets/weapon_bottom_sheet.dart' as weapons;
import 'package:responsive_builder/responsive_builder.dart';

class ModalBottomSheetUtils {
  static Widget getBottomSheetFromEndDrawerItemType(EndDrawerItemType? type, {Map<String, dynamic>? args}) {
    switch (type) {
      case EndDrawerItemType.characters:
        return const characters.CharacterBottomSheet();
      case EndDrawerItemType.weapons:
        return const weapons.WeaponBottomSheet();
      case EndDrawerItemType.artifacts:
        return const artifacts.ArtifactBottomSheet();
      case EndDrawerItemType.materials:
        return const materials.MaterialBottomSheet();
      case EndDrawerItemType.monsters:
        return const monsters.MonsterBottomSheet();
      case EndDrawerItemType.calculatorAscMaterialsAdd:
      case EndDrawerItemType.calculatorAscMaterialsEdit:
        assert(args != null);
        return calc_asc_mat.AddEditItemBottomSheet.getWidgetFromArgs(args!);
      case EndDrawerItemType.notifications:
        assert(args != null);
        return notifications.AddEditNotificationBottomSheet.getWidgetFromArgs(args!);
    }
    return Container();
  }

  static Future<void> showAppModalBottomSheet(BuildContext context, EndDrawerItemType type, {Map<String, dynamic>? args}) async {
    final size = MediaQuery.of(context).size;
    final device = getDeviceType(size);

    if (device == DeviceScreenType.mobile) {
      await showModalBottomSheet(
        context: context,
        shape: Styles.modalBottomSheetShape,
        isDismissible: true,
        isScrollControlled: true,
        builder: (ctx) => getBottomSheetFromEndDrawerItemType(type, args: args),
      );
      return;
    }

    await showCustomModalBottomSheet(
      context: context,
      builder: (ctx) => getBottomSheetFromEndDrawerItemType(type, args: args),
    );
  }
}
