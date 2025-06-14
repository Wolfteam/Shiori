import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/custom_build/widgets/artifact_section.dart';
import 'package:shiori/presentation/custom_build/widgets/character_section.dart';
import 'package:shiori/presentation/custom_build/widgets/team_section.dart';
import 'package:shiori/presentation/custom_build/widgets/weapon_section.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

import '../extensions/widget_tester_extensions.dart';
import 'views.dart';

class CustomBuildsPage extends BasePage {
  const CustomBuildsPage(super.tester);

  Future<void> navigate() async {
    final splashPage = SplashPage(tester);
    await splashPage.initialize(deleteData: true);
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(tester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnCustomBuildsCard();
  }

  Future<void> tapOnFab() async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  Future<void> selectCharacter(String name) async {
    await tester.tap(find.byType(CharacterStackImage));
    await tester.pumpAndSettle();
    await enterSearchText(name);

    await tester.tap(find.byType(CharacterCard));
    await tester.pumpAndSettle();
  }

  int _getCharacterRoleTypeIndex(CharacterRoleType type) {
    return switch (type) {
      CharacterRoleType.burstSupport => 0,
      CharacterRoleType.dps => 1,
      CharacterRoleType.offFieldDps => 2,
      CharacterRoleType.subDps => 3,
      CharacterRoleType.support => 4,
      _ => throw ArgumentError.value(type),
    };
  }

  int _getCharacterRoleSubTypeIndex(CharacterRoleSubType type) {
    return switch (type) {
      CharacterRoleSubType.anemo => 0,
      CharacterRoleSubType.cryo => 1,
      CharacterRoleSubType.dendro => 2,
      CharacterRoleSubType.electro => 3,
      CharacterRoleSubType.elementalMastery => 4,
      CharacterRoleSubType.freeze => 5,
      CharacterRoleSubType.geo => 6,
      CharacterRoleSubType.healer => 7,
      CharacterRoleSubType.hydro => 8,
      CharacterRoleSubType.melt => 9,
      CharacterRoleSubType.none => 10,
      CharacterRoleSubType.physical => 11,
      CharacterRoleSubType.pyro => 12,
      CharacterRoleSubType.shield => 13,
    };
  }

  Future<void> selectRole(CharacterRoleType type) async {
    final int index = _getCharacterRoleTypeIndex(type);
    await tapOnCommonDropdownButton<CharacterRoleType>();
    await selectOptionFromDropdownButtonWithTitle<CharacterRoleType>(index: index);
  }

  Future<void> selectRoleSubType(CharacterRoleSubType type) async {
    final index = switch (type) {
      CharacterRoleSubType.anemo => 0,
      CharacterRoleSubType.cryo => 1,
      CharacterRoleSubType.dendro => 2,
      CharacterRoleSubType.electro => 3,
      CharacterRoleSubType.elementalMastery => 4,
      CharacterRoleSubType.freeze => 5,
      CharacterRoleSubType.geo => 6,
      CharacterRoleSubType.healer => 7,
      CharacterRoleSubType.hydro => 8,
      CharacterRoleSubType.melt => 9,
      CharacterRoleSubType.none => 10,
      CharacterRoleSubType.physical => 11,
      CharacterRoleSubType.pyro => 12,
      CharacterRoleSubType.shield => 13,
    };

    await tapOnCommonDropdownButton<CharacterRoleSubType>();
    await selectOptionFromDropdownButtonWithTitle<CharacterRoleSubType>(index: index);
  }

  Future<void> selectCharacterSkillTypeDialog(CharacterSkillType type) async {
    await tester.tap(find.descendant(of: find.byType(CharacterSection), matching: find.byIcon(Icons.add)).first);
    await tester.pumpAndSettle();

    final index = switch (type) {
      CharacterSkillType.elementalBurst => 0,
      CharacterSkillType.elementalSkill => 1,
      CharacterSkillType.normalAttack => 2,
      _ => throw ArgumentError.value(type),
    };
    await selectEnumDialogOption<CharacterSkillType>(index);
  }

  Future<void> setNote(String note) async {
    await tester.tap(find.descendant(of: find.byType(CharacterSection), matching: find.byIcon(Icons.add)).last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), note);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  Future<void> addWeapon(String name) async {
    await tester.doAppDragUntilVisible(
      find.descendant(of: find.byType(WeaponSection), matching: find.byIcon(Icons.add)),
      find.byType(SingleChildScrollView),
      BasePage.verticalDragOffset,
    );

    await tester.tap(find.descendant(of: find.byType(WeaponSection), matching: find.byIcon(Icons.add)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), name);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(WeaponCard));
    await tester.pumpAndSettle();
  }

  Future<void> addArtifact(String name, ArtifactType type) async {
    await tester.doAppDragUntilVisible(
      find.descendant(of: find.byType(ArtifactSection), matching: find.byIcon(Icons.add)),
      find.byType(SingleChildScrollView),
      BasePage.verticalDragOffset,
    );

    await tester.tap(find.descendant(of: find.byType(ArtifactSection), matching: find.byIcon(Icons.add)));
    await tester.pumpAndSettle();

    await selectEnumDialogOption<ArtifactType>(type.index);

    switch (type) {
      case ArtifactType.clock:
      case ArtifactType.goblet:
      case ArtifactType.crown:
        await selectEnumDialogOption<StatType>(3);
      default:
        break;
    }

    await tester.enterText(find.byType(TextField), name);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ArtifactCard));
    await tester.pumpAndSettle();
  }

  Future<void> addTeamCharacter(String name, CharacterRoleType type, CharacterRoleSubType subType) async {
    await tester.doAppDragUntilVisible(
      find.descendant(of: find.byType(TeamSection), matching: find.byIcon(Icons.add)),
      find.byType(SingleChildScrollView),
      BasePage.verticalDragOffset,
    );

    await tester.tap(find.descendant(of: find.byType(TeamSection), matching: find.byIcon(Icons.add)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), name);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CharacterCard));
    await tester.pumpAndSettle();

    await selectEnumDialogOption<CharacterRoleType>(_getCharacterRoleTypeIndex(type));
    await selectEnumDialogOption<CharacterRoleSubType>(_getCharacterRoleSubTypeIndex(subType));
  }

  Future<void> tapOnSave() async {
    await tester.tap(find.widgetWithIcon(IconButton, Icons.save));
    await tester.pumpAndSettle();
    await tester.pumpUntilFound(find.widgetWithIcon(AppBar, Icons.save_alt));
  }

  Future<void> tapOnDelete() async {
    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }
}
