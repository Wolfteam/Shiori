import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_bottom_sheet.dart' as artifacts;
import 'package:shiori/presentation/calculator_asc_materials/widgets/add_edit_item_bottom_sheet.dart' as calc_asc_mat;
import 'package:shiori/presentation/characters/widgets/character_bottom_sheet.dart' as characters;
import 'package:shiori/presentation/materials/widgets/material_bottom_sheet.dart' as materials;
import 'package:shiori/presentation/monsters/widgets/monster_bottom_sheet.dart' as monsters;
import 'package:shiori/presentation/notifications/widgets/add_edit_notification_bottom_sheet.dart' as notifications;
import 'package:shiori/presentation/shared/bottom_sheets/custom_bottom_sheet.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_bottom_sheet.dart' as weapons;

class ModalBottomSheetUtils {
  static Widget getBottomSheetFromEndDrawerItemType(BuildContext context, EndDrawerItemType? type, {Map<String, dynamic>? args}) {
    switch (type) {
      case EndDrawerItemType.characters:
        return const characters.CharacterBottomSheet();
      case EndDrawerItemType.weapons:
        return const weapons.WeaponBottomSheet();
      case EndDrawerItemType.artifacts:
        return const artifacts.ArtifactBottomSheet();
      case EndDrawerItemType.materials:
        return materials.MaterialBottomSheet.route(context);
      case EndDrawerItemType.monsters:
        return monsters.MonsterBottomSheet.route(context);
      case EndDrawerItemType.calculatorAscMaterialsAdd:
      case EndDrawerItemType.calculatorAscMaterialsEdit:
        assert(args != null);
        return calc_asc_mat.AddEditItemBottomSheet.getWidgetFromArgs(context, args!);
      case EndDrawerItemType.notifications:
        assert(args != null);
        return notifications.AddEditNotificationBottomSheet.getWidgetFromArgs(context, args!);
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
        builder: (ctx) => getBottomSheetFromEndDrawerItemType(context, type, args: args),
      );
      return;
    }

    await showCustomModalBottomSheet(
      context: context,
      builder: (ctx) => getBottomSheetFromEndDrawerItemType(context, type, args: args),
    );
  }
}
