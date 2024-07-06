import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';

const _dbFolder = 'shiori_custom_builds_bloc_tests';

void main() {
  late DataService dataService;
  late GenshinService genshinService;
  late final String dbPath;

  const keqingKey = 'keqing';
  const ganyuKey = 'ganyu';
  const aquilaFavoniaKey = 'aquila-favonia';
  const thunderingFuryKey = 'thundering-fury';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = SettingsServiceImpl();
    final localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(genshinService, CalculatorAscMaterialsServiceImpl(genshinService, resourceService), resourceService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  Future<CustomBuildModel> saveCustomBuild(String charKey) async {
    final artifact = genshinService.artifacts.getArtifactForCard(thunderingFuryKey);
    final weapon = genshinService.weapons.getWeapon(aquilaFavoniaKey);
    return dataService.customBuilds.saveCustomBuild(
      charKey,
      '$charKey pro DPS',
      CharacterRoleType.dps,
      CharacterRoleSubType.electro,
      true,
      true,
      const [CustomBuildNoteModel(index: 0, note: 'You need 200ER')],
      [
        CustomBuildWeaponModel(
          key: weapon.key,
          index: 0,
          rarity: weapon.rarity,
          refinement: 5,
          subStatType: weapon.secondaryStat,
          name: 'Aquila Favonia',
          image: weapon.image,
          stat: weapon.stats.last,
          stats: weapon.stats,
        ),
      ],
      [
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.flower,
          name: artifact.name,
          statType: StatType.hp,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atkPercentage,
            StatType.atk,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.plume,
          name: artifact.name,
          statType: StatType.atk,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atkPercentage,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.clock,
          name: artifact.name,
          statType: StatType.atkPercentage,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atk,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.goblet,
          name: artifact.name,
          statType: StatType.electroDmgBonusPercentage,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atkPercentage,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.crown,
          name: artifact.name,
          statType: StatType.critDmgPercentage,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.atkPercentage,
            StatType.energyRechargePercentage,
          ],
        ),
      ],
      const [
        CustomBuildTeamCharacterModel(
          key: 'fischl',
          index: 0,
          name: 'Fischl',
          image: '',
          iconImage: '',
          roleType: CharacterRoleType.offFieldDps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'beidou',
          index: 1,
          name: 'Beidou',
          image: '',
          iconImage: '',
          roleType: CharacterRoleType.offFieldDps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'bennett',
          index: 2,
          name: 'Bennett',
          image: '',
          iconImage: '',
          roleType: CharacterRoleType.burstSupport,
          subType: CharacterRoleSubType.pyro,
        ),
      ],
      [CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill, CharacterSkillType.normalAttack],
    );
  }

  test('Initial state', () => expect(CustomBuildsBloc(dataService).state, const CustomBuildsState.loaded()));

  blocTest<CustomBuildsBloc, CustomBuildsState>(
    'Create build for $keqingKey',
    setUp: () async {
      await saveCustomBuild(keqingKey);
    },
    build: () => CustomBuildsBloc(dataService),
    act: (bloc) => bloc.add(const CustomBuildsEvent.load()),
    verify: (bloc) {
      final state = bloc.state;
      expect(state.builds.length, 1);

      final build = state.builds.first;
      expect(build.character.key, keqingKey);
      expect(build.character.roleType, CharacterRoleType.dps);
      expect(build.type, CharacterRoleType.dps);
      expect(build.subType, CharacterRoleSubType.electro);
      expect(build.showOnCharacterDetail, true);
      expect(build.isRecommended, true);
      expect(build.weapons.length, 1);

      final weapon = build.weapons.first;
      expect(weapon.key == aquilaFavoniaKey, true);
      expect(weapon.refinement == 5, true);

      final artifacts = build.artifacts;
      expect(artifacts.length, 5);
      expect(artifacts.every((el) => el.key == thunderingFuryKey), true);
      expect(artifacts.every((el) => el.subStats.length > 2), true);
      expect(artifacts.map((e) => e.type).toSet().length == 5, true);
      expect(artifacts.map((e) => e.statType).toSet().length == 5, true);

      final teams = build.teamCharacters;
      expect(teams.length == 3, true);

      expect(build.skillPriorities.length == 3, true);
    },
  );

  int deleteKey = 0;
  blocTest<CustomBuildsBloc, CustomBuildsState>(
    'Create and delete $ganyuKey build',
    build: () => CustomBuildsBloc(dataService),
    setUp: () async {
      final build = await saveCustomBuild(ganyuKey);
      deleteKey = build.key;
    },
    act: (bloc) => bloc
      ..add(const CustomBuildsEvent.load())
      ..add(CustomBuildsEvent.delete(key: deleteKey)),
    skip: 1,
    verify: (bloc) {
      expect(bloc.state.builds.any((el) => el.character.key == ganyuKey), false);
    },
  );
}
