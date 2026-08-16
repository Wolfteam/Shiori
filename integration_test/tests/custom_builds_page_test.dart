import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/custom_build/widgets/artifact_row.dart';
import 'package:shiori/presentation/custom_build/widgets/team_character_row.dart';
import 'package:shiori/presentation/custom_build/widgets/weapon_row.dart';
import 'package:shiori/presentation/custom_builds/widgets/custom_build_card.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';

import '../extensions/widget_tester_extensions.dart';
import '../game_data.dart';
import '../views/views.dart';

void main() {
  group('Custom builds page', () {
    testWidgets('creates custom build', (widgetTester) async {
      final page = CustomBuildsPage(widgetTester);
      await page.navigate();
      await page.tapOnFab();

      //Set common stuff
      await page.selectCharacter(GameData.keqing.key);
      await page.selectRole(CharacterRoleType.burstSupport);
      await page.selectRoleSubType(CharacterRoleSubType.dendro);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.elementalBurst);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.elementalSkill);
      await page.setNote('Besto');
      await page.setNote('Girl');

      //Set weapon stuff
      await page.addWeapon('mistspl');
      await page.addWeapon('the black');
      await page.addWeapon("lion's roar");
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);
      await widgetTester.doAppDragUntilVisible(
        find.byWidgetPredicate((widget) => widget is WeaponRow && widget.weapon.index == 2),
        find.byType(CustomScrollView),
        BasePage.verticalDragOffset,
      );
      expect(
        find.byType(WeaponRow),
        findsNWidgets(3),
        reason: 'Adding three weapons must render exactly three weapon rows in the build',
      );

      //Set artifact stuff
      for (final type in ArtifactType.values) {
        await page.addArtifact('thundering', type);
      }
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);
      await widgetTester.doAppDragUntilVisible(
        find.byWidgetPredicate((widget) => widget is ArtifactRow && widget.artifact.type == ArtifactType.crown),
        find.byType(CustomScrollView),
        BasePage.verticalDragOffset,
      );
      expect(
        find.byType(ArtifactRow),
        findsNWidgets(ArtifactType.values.length),
        reason: 'Adding one artifact per type must render a row for each of the ${ArtifactType.values.length} slots',
      );

      //Set team characters
      await page.addTeamCharacter(GameData.fischl.key, CharacterRoleType.offFieldDps, CharacterRoleSubType.electro);
      await page.addTeamCharacter(GameData.nahida.key, CharacterRoleType.support, CharacterRoleSubType.dendro);
      await page.addTeamCharacter('kazuha', CharacterRoleType.support, CharacterRoleSubType.anemo);
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);
      await widgetTester.doAppDragUntilVisible(
        find.byWidgetPredicate((widget) => widget is TeamCharacterRow && widget.character.index == 2),
        find.byType(CustomScrollView),
        BasePage.verticalDragOffset,
      );
      expect(
        find.byType(TeamCharacterRow),
        findsNWidgets(3),
        reason: 'Adding three team characters must render exactly three team character rows',
      );

      await page.tapOnSave();
      await page.tapOnBackButton();

      final Finder cardFinder = find.byType(CustomBuildCard);
      expect(
        cardFinder,
        findsOneWidget,
        reason: 'Saving the build should list exactly one custom build card to inspect',
      );

      final CustomBuildCard card = widgetTester.widget<CustomBuildCard>(cardFinder);
      expect(
        card.item.character.key,
        GameData.keqing.key,
        reason: 'The saved custom build must lead with ${GameData.keqing.name} (key ${GameData.keqing.key})',
      );
      expect(
        card.item.character.elementType,
        GameData.keqing.element,
        reason: '${GameData.keqing.name} on the custom build must show element ${GameData.keqing.element.name}',
      );
    });

    testWidgets('creates custom build and deletes it', (widgetTester) async {
      final page = CustomBuildsPage(widgetTester);
      await page.navigate();
      await page.tapOnFab();

      //Set common stuff
      await page.selectCharacter(GameData.keqing.key);

      //Set weapon stuff
      await page.addWeapon('mistspl');
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);

      //Set artifact stuff
      for (final type in ArtifactType.values) {
        await page.addArtifact('thundering', type);
      }
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);

      await page.tapOnSave();
      await page.tapOnBackButton();

      expect(
        find.byType(CustomBuildCard),
        findsOneWidget,
        reason: 'Saving the build should list exactly one custom build card',
      );
      await page.tapOnDelete();
      expect(
        find.byType(CustomBuildCard),
        findsNothing,
        reason: 'Deleting the only build should clear the custom builds list',
      );
    });

    testWidgets('creates custom build and updates it', (widgetTester) async {
      final page = CustomBuildsPage(widgetTester);
      await page.navigate();
      await page.tapOnFab();

      //Set common stuff
      await page.selectCharacter(GameData.keqing.key);

      //Set weapon stuff
      await page.addWeapon('mistspl');
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);

      //Set artifact stuff
      for (final type in ArtifactType.values) {
        await page.addArtifact('thundering', type);
      }
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);

      await page.tapOnSave();
      await page.tapOnBackButton();

      expect(
        find.byType(CustomBuildCard),
        findsOneWidget,
        reason: 'The build must exist as a single card before it can be opened for updating',
      );

      //Update it
      //The CharacterStackImage has an absorb pointer
      await widgetTester.tap(find.byType(CharacterStackImage), warnIfMissed: false);
      await widgetTester.pumpAndSettle();

      await page.selectCharacter(GameData.nahida.key);
      await page.selectRole(CharacterRoleType.dps);
      await page.selectRoleSubType(CharacterRoleSubType.dendro);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.elementalSkill);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.elementalBurst);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.normalAttack);
      await page.addWeapon('thousand floating');
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);
      await page.addTeamCharacter(GameData.keqing.key, CharacterRoleType.dps, CharacterRoleSubType.electro);

      await page.tapOnSave();
      await page.tapOnBackButton();

      expect(
        find.byType(CustomBuildCard),
        findsOneWidget,
        reason: 'Updating the build should keep a single custom build card, not create a duplicate',
      );
    });
  });
}
