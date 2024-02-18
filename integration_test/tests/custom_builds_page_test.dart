import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/custom_build/widgets/artifact_row.dart';
import 'package:shiori/presentation/custom_build/widgets/team_character_row.dart';
import 'package:shiori/presentation/custom_build/widgets/weapon_row.dart';
import 'package:shiori/presentation/custom_builds/widgets/custom_build_card.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';

import '../views/views.dart';

void main() {
  group('Custom builds page', () {
    testWidgets('creates custom build', (widgetTester) async {
      final page = CustomBuildsPage(widgetTester);
      await page.navigate();
      await page.tapOnFab();

      //Set common stuff
      await page.selectCharacter('keqing');
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
      await widgetTester.dragUntilVisible(
        find.byWidgetPredicate((widget) => widget is WeaponRow && widget.weapon.index == 2),
        find.byType(CustomScrollView),
        BasePage.verticalDragOffset,
      );
      expect(find.byType(WeaponRow), findsNWidgets(3));

      //Set artifact stuff
      for (final type in ArtifactType.values) {
        await page.addArtifact('thundering', type);
      }
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);
      await widgetTester.dragUntilVisible(
        find.byWidgetPredicate((widget) => widget is ArtifactRow && widget.artifact.type == ArtifactType.crown),
        find.byType(CustomScrollView),
        BasePage.verticalDragOffset,
      );
      expect(find.byType(ArtifactRow), findsNWidgets(ArtifactType.values.length));

      //Set team characters
      await page.addTeamCharacter('fischl', CharacterRoleType.offFieldDps, CharacterRoleSubType.electro);
      await page.addTeamCharacter('nahida', CharacterRoleType.support, CharacterRoleSubType.dendro);
      await page.addTeamCharacter('kazuha', CharacterRoleType.support, CharacterRoleSubType.anemo);
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);
      await widgetTester.dragUntilVisible(
        find.byWidgetPredicate((widget) => widget is TeamCharacterRow && widget.character.index == 2),
        find.byType(CustomScrollView),
        BasePage.verticalDragOffset,
      );
      expect(find.byType(TeamCharacterRow), findsNWidgets(3));

      await page.tapOnSave();
      await page.tapOnBackButton();

      expect(find.byType(CustomBuildCard), findsOneWidget);
    });

    testWidgets('creates custom build and deletes it', (widgetTester) async {
      final page = CustomBuildsPage(widgetTester);
      await page.navigate();
      await page.tapOnFab();

      //Set common stuff
      await page.selectCharacter('keqing');

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

      expect(find.byType(CustomBuildCard), findsOneWidget);
      await page.tapOnDelete();
      expect(find.byType(CustomBuildCard), findsNothing);
    });

    testWidgets('creates custom build and updates it', (widgetTester) async {
      final page = CustomBuildsPage(widgetTester);
      await page.navigate();
      await page.tapOnFab();

      //Set common stuff
      await page.selectCharacter('keqing');

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

      expect(find.byType(CustomBuildCard), findsOneWidget);

      //Update it
      //The CharacterStackImage has an absorb pointer
      await widgetTester.tap(find.byType(CharacterStackImage), warnIfMissed: false);
      await widgetTester.pumpAndSettle();

      await page.selectCharacter('nahida');
      await page.selectRole(CharacterRoleType.dps);
      await page.selectRoleSubType(CharacterRoleSubType.dendro);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.elementalSkill);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.elementalBurst);
      await page.selectCharacterSkillTypeDialog(CharacterSkillType.normalAttack);
      await page.addWeapon('thousand floating');
      await widgetTester.pumpAndSettle(BasePage.threeHundredMsDuration);
      await page.addTeamCharacter('keqing', CharacterRoleType.dps, CharacterRoleSubType.electro);

      await page.tapOnSave();
      await page.tapOnBackButton();

      expect(find.byType(CustomBuildCard), findsOneWidget);
    });
  });
}
