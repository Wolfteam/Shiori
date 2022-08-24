import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_custom_builds_bloc_tests';

void main() {
  late DataService _dataService;
  late GenshinService _genshinService;

  const _keqingKey = 'keqing';
  const _ganyuKey = 'ganyu';
  const _aquilaFavoniaKey = 'aquila-favonia';
  const _thunderingFuryKey = 'thundering-fury';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = SettingsServiceImpl(MockLoggingService());
    final localeService = LocaleServiceImpl(settingsService);
    _genshinService = GenshinServiceImpl(localeService);
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService));

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      await _dataService.init(dir: _dbFolder);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbFolder);
    });
  });

  Future<CustomBuildModel> _saveCustomBuild(String charKey) async {
    final artifact = _genshinService.artifacts.getArtifactForCard(_thunderingFuryKey);
    final weapon = _genshinService.weapons.getWeapon(_aquilaFavoniaKey);
    return _dataService.customBuilds.saveCustomBuild(
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
          roleType: CharacterRoleType.offFieldDps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'beidou',
          index: 1,
          name: 'Beidou',
          image: '',
          roleType: CharacterRoleType.offFieldDps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'bennett',
          index: 2,
          name: 'Bennett',
          image: '',
          roleType: CharacterRoleType.burstSupport,
          subType: CharacterRoleSubType.pyro,
        ),
      ],
      [CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill, CharacterSkillType.normalAttack],
    );
  }

  test('Initial state', () => expect(CustomBuildsBloc(_dataService).state, const CustomBuildsState.loaded(builds: [])));

  blocTest<CustomBuildsBloc, CustomBuildsState>(
    'Create build for $_keqingKey',
    setUp: () async {
      await _saveCustomBuild(_keqingKey);
    },
    build: () => CustomBuildsBloc(_dataService),
    act: (bloc) => bloc.add(const CustomBuildsEvent.load()),
    verify: (bloc) {
      final state = bloc.state;
      expect(state.builds.length, 1);

      final build = state.builds.first;
      expect(build.character.key, _keqingKey);
      expect(build.character.roleType, CharacterRoleType.dps);
      expect(build.type, CharacterRoleType.dps);
      expect(build.subType, CharacterRoleSubType.electro);
      expect(build.showOnCharacterDetail, true);
      expect(build.isRecommended, true);
      expect(build.weapons.length, 1);

      final weapon = build.weapons.first;
      expect(weapon.key == _aquilaFavoniaKey, true);
      expect(weapon.refinement == 5, true);

      final artifacts = build.artifacts;
      expect(artifacts.length, 5);
      expect(artifacts.every((el) => el.key == _thunderingFuryKey), true);
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
    'Create and delete $_ganyuKey build',
    build: () => CustomBuildsBloc(_dataService),
    setUp: () async {
      final build = await _saveCustomBuild(_ganyuKey);
      deleteKey = build.key;
    },
    act: (bloc) => bloc
      ..add(const CustomBuildsEvent.load())
      ..add(CustomBuildsEvent.delete(key: deleteKey)),
    skip: 1,
    verify: (bloc) {
      expect(bloc.state.builds.any((el) => el.character.key == _ganyuKey), false);
    },
  );
}
