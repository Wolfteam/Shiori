import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_custom_build_bloc_tests';

void main() {
  late GenshinService _genshinService;
  late DataService _dataService;
  late TelemetryService _telemetryService;
  late LoggingService _loggingService;
  late CustomBuildsBloc _customBuildsBloc;
  late ResourceService _resourceService;

  const _keqingKey = 'keqing';
  const _ganyuKey = 'ganyu';
  const _aquilaFavoniaKey = 'aquila-favonia';
  const _thunderingFuryKey = 'thundering-fury';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = SettingsServiceImpl(MockLoggingService());
    final localeService = LocaleServiceImpl(settingsService);
    _resourceService = getResourceService(settingsService);
    _genshinService = GenshinServiceImpl(_resourceService, localeService);
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService, _resourceService), _resourceService);
    _telemetryService = MockTelemetryService();
    _loggingService = MockLoggingService();
    _customBuildsBloc = CustomBuildsBloc(_dataService);

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

  CustomBuildBloc _getBloc() => CustomBuildBloc(
        _genshinService,
        _dataService,
        _telemetryService,
        _loggingService,
        _resourceService,
        _customBuildsBloc,
      );

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

  test(
    'Initial state',
    () => expect(_getBloc().state, const CustomBuildState.loading()),
  );

  group('Load', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'create',
      build: () => _getBloc(),
      act: (bloc) => bloc.add(const CustomBuildEvent.load(initialTitle: 'DPS PRO')),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          final character = _genshinService.characters.getCharactersForCard().first;
          expect(state.title, 'DPS PRO');
          expect(state.type, CharacterRoleType.dps);
          expect(state.subType, CharacterRoleSubType.none);
          expect(state.showOnCharacterDetail, true);
          expect(state.isRecommended, false);
          expect(state.character.key, character.key);
          expect(state.weapons.isEmpty, true);
          expect(state.artifacts.isEmpty, true);
          expect(state.teamCharacters.isEmpty, true);
          expect(state.notes.isEmpty, true);
          expect(state.skillPriorities.isEmpty, true);
          expect(state.subStatsSummary.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    int _buildKey = 0;
    blocTest<CustomBuildBloc, CustomBuildState>(
      'existing $_keqingKey build',
      setUp: () async {
        final build = await _saveCustomBuild(_keqingKey);
        _buildKey = build.key;
      },
      build: () => _getBloc(),
      act: (bloc) => bloc.add(CustomBuildEvent.load(initialTitle: 'XXX', key: _buildKey)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.title, '$_keqingKey pro DPS');
          expect(state.type, CharacterRoleType.dps);
          expect(state.subType, CharacterRoleSubType.electro);
          expect(state.showOnCharacterDetail, true);
          expect(state.isRecommended, true);
          expect(state.character.key, _keqingKey);
          expect(state.weapons.length == 1, true);
          expect(state.artifacts.length == 5, true);
          expect(state.teamCharacters.length == 3, true);
          expect(state.notes.length == 1, true);
          expect(state.skillPriorities.length == 3, true);
          expect(state.subStatsSummary.isNotEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );
  });

  group('General', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'character changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: _ganyuKey)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.character.key, _ganyuKey);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'title changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.titleChanged(newValue: 'KEQING PRO')),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.title, 'KEQING PRO');
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'role changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.roleChanged(newValue: CharacterRoleType.offFieldDps)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.type, CharacterRoleType.offFieldDps);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'sub role changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.subRoleChanged(newValue: CharacterRoleSubType.cryo)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.subType, CharacterRoleSubType.cryo);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'show on character detail changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.showOnCharacterDetailChanged(newValue: false)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.showOnCharacterDetail, false);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'is recommended changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.isRecommendedChanged(newValue: true)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.isRecommended, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );
  });

  group('Notes', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.addNote(note: 'You need C6')),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.notes.length == 2, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, note is not valid',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.addNote(note: '')),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.deleteNote(index: 0)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.notes.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, index is not valid',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.deleteNote(index: 10)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Skill priorities', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalSkill)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.skillPriorities.length == 2, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, skill already exist',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalSkill))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalSkill)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.skillPriorities.length == 2, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, skill is not valid',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.others)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.normalAttack))
        ..add(const CustomBuildEvent.deleteSkillPriority(index: 1)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.skillPriorities.length == 1, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, index is not valid',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.normalAttack))
        ..add(const CustomBuildEvent.deleteSkillPriority(index: 2)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Weapons', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.weapons.length == 1, true);
          expect(state.weapons.first.key == _aquilaFavoniaKey, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, weapon already exists',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, weapon is not valid for current character',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: _ganyuKey))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: _aquilaFavoniaKey, newValue: 5)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.weapons.first.refinement == 5, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed, weapon does not exist',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: _aquilaFavoniaKey, newValue: 5)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed, refinement has not changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: _aquilaFavoniaKey, newValue: 5))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: _aquilaFavoniaKey, newValue: 5)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.weapons.first.refinement == 5, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed, invalid value',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: _aquilaFavoniaKey, newValue: 6)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: _aquilaFavoniaKey, newValue: 5))
        ..add(const CustomBuildEvent.deleteWeapon(key: _aquilaFavoniaKey)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.weapons.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, weapon does not exist',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: _aquilaFavoniaKey, newValue: 5))
        ..add(const CustomBuildEvent.deleteWeapon(key: _aquilaFavoniaKey))
        ..add(const CustomBuildEvent.deleteWeapon(key: _aquilaFavoniaKey)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete all weapons',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const CustomBuildEvent.deleteWeapons()),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.weapons.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'order changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: _keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const CustomBuildEvent.addWeapon(key: 'the-flute'))
        ..add(
          CustomBuildEvent.weaponsOrderChanged(
            weapons: [
              SortableItem('the-flute', 'The Flute'),
              SortableItem(_aquilaFavoniaKey, 'Aquila Favonia'),
            ],
          ),
        ),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.weapons.length == 2, true);
          expect(state.weapons.first.key == 'the-flute', true);
          expect(state.weapons.last.key == _aquilaFavoniaKey, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'stat changed',
      build: () => _getBloc(),
      act: (bloc) {
        final weapon = _genshinService.weapons.getWeapon(_aquilaFavoniaKey);
        return bloc
          ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
          ..add(const CustomBuildEvent.characterChanged(newKey: _keqingKey))
          ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
          ..add(CustomBuildEvent.weaponStatChanged(key: _aquilaFavoniaKey, newValue: weapon.stats[3]));
      },
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          final stat = _genshinService.weapons.getWeapon(_aquilaFavoniaKey).stats[3];
          expect(state.weapons.length == 1, true);
          expect(state.weapons.first.key == _aquilaFavoniaKey, true);
          expect(state.weapons.first.stat == stat, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );
  });

  group('Artifacts', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.artifacts.length == 1, true);
          final artifact = state.artifacts.first;
          expect(artifact.key == _thunderingFuryKey, true);
          expect(artifact.type == ArtifactType.flower, true);
          expect(artifact.statType == StatType.hp, true);
          expect(artifact.subStats.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, type already exists',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.crown, statType: StatType.hp))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.crown, statType: StatType.critDmgPercentage)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.artifacts.length == 1, true);
          final artifact = state.artifacts.first;
          expect(artifact.key == _thunderingFuryKey, true);
          expect(artifact.type == ArtifactType.crown, true);
          expect(artifact.statType == StatType.critDmgPercentage, true);
          expect(artifact.subStats.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add sub stats',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(
            type: ArtifactType.flower,
            subStats: [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage, StatType.atk],
          ),
        )
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(
            type: ArtifactType.plume,
            subStats: [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage],
          ),
        ),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.artifacts.length == 2, true);
          final flower = state.artifacts.first;
          expect(flower.type, ArtifactType.flower);
          expect(listEquals(flower.subStats, [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage, StatType.atk]), true);

          final plume = state.artifacts.last;
          expect(plume.type, ArtifactType.plume);
          expect(listEquals(plume.subStats, [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage]), true);

          expect(state.subStatsSummary.isNotEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add sub stats, artifact does not exist',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(type: ArtifactType.crown, subStats: [StatType.critRatePercentage, StatType.critDmgPercentage]),
        ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add sub-stats, sub-stat is not valid',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(type: ArtifactType.flower, subStats: [StatType.critRatePercentage, StatType.hp]),
        ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add sub-stats, sub-stat is not valid',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(type: ArtifactType.flower, subStats: [StatType.critRatePercentage, StatType.hp]),
        ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.deleteArtifact(type: ArtifactType.flower)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.artifacts.isEmpty, true);
          expect(state.subStatsSummary.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, type does not exist',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.deleteArtifact(type: ArtifactType.crown)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete all artifacts',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
        ..add(const CustomBuildEvent.deleteArtifacts()),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.artifacts.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );
  });

  group('Team characters', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(key: _ganyuKey, roleType: CharacterRoleType.offFieldDps, subType: CharacterRoleSubType.electro),
        ),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.teamCharacters.length == 1, true);
          final char = state.teamCharacters.first;
          expect(char.roleType, CharacterRoleType.offFieldDps);
          expect(char.subType, CharacterRoleSubType.electro);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, team character is the same as the main one',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: _ganyuKey))
        ..add(
          const CustomBuildEvent.addTeamCharacter(key: _ganyuKey, roleType: CharacterRoleType.offFieldDps, subType: CharacterRoleSubType.electro),
        ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add the same character multiple times',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(key: _ganyuKey, roleType: CharacterRoleType.offFieldDps, subType: CharacterRoleSubType.electro),
        )
        ..add(
          const CustomBuildEvent.addTeamCharacter(key: _ganyuKey, roleType: CharacterRoleType.offFieldDps, subType: CharacterRoleSubType.electro),
        ),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.teamCharacters.length == 1, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'order changed',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(key: _ganyuKey, roleType: CharacterRoleType.offFieldDps, subType: CharacterRoleSubType.cryo),
        )
        ..add(
          const CustomBuildEvent.addTeamCharacter(key: _keqingKey, roleType: CharacterRoleType.dps, subType: CharacterRoleSubType.electro),
        )
        ..add(
          CustomBuildEvent.teamCharactersOrderChanged(
            characters: [
              SortableItem(_keqingKey, 'Keqing'),
              SortableItem(_ganyuKey, 'Ganyu'),
            ],
          ),
        ),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.teamCharacters.length == 2, true);
          final keqing = state.teamCharacters.first;
          expect(keqing.roleType, CharacterRoleType.dps);
          expect(keqing.subType, CharacterRoleSubType.electro);

          final ganyu = state.teamCharacters.last;
          expect(ganyu.roleType, CharacterRoleType.offFieldDps);
          expect(ganyu.subType, CharacterRoleSubType.cryo);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(key: _ganyuKey, roleType: CharacterRoleType.offFieldDps, subType: CharacterRoleSubType.electro),
        )
        ..add(const CustomBuildEvent.deleteTeamCharacter(key: _ganyuKey)),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.teamCharacters.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, team character does not exist',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.deleteTeamCharacter(key: _ganyuKey)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Save', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'all stuff was set',
      build: () => _getBloc(),
      act: (bloc) {
        final weapon = _genshinService.weapons.getWeapon(_aquilaFavoniaKey);
        return bloc
          ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
          ..add(const CustomBuildEvent.characterChanged(newKey: _keqingKey))
          ..add(const CustomBuildEvent.isRecommendedChanged(newValue: true))
          ..add(const CustomBuildEvent.showOnCharacterDetailChanged(newValue: false))
          ..add(const CustomBuildEvent.addNote(note: 'You need C6'))
          ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
          ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
          ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
          ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.clock, statType: StatType.atkPercentage))
          ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.goblet, statType: StatType.electroDmgBonusPercentage))
          ..add(const CustomBuildEvent.addArtifact(key: _thunderingFuryKey, type: ArtifactType.crown, statType: StatType.critDmgPercentage))
          ..add(
            const CustomBuildEvent.addArtifactSubStats(
              type: ArtifactType.crown,
              subStats: [
                StatType.critRatePercentage,
                StatType.atkPercentage,
                StatType.atk,
              ],
            ),
          )
          ..add(const CustomBuildEvent.addWeapon(key: _aquilaFavoniaKey))
          ..add(CustomBuildEvent.weaponStatChanged(key: _aquilaFavoniaKey, newValue: weapon.stats.first))
          ..add(
            const CustomBuildEvent.addTeamCharacter(key: _ganyuKey, roleType: CharacterRoleType.offFieldDps, subType: CharacterRoleSubType.cryo),
          )
          ..add(const CustomBuildEvent.saveChanges());
      },
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          final stat = _genshinService.weapons.getWeapon(_aquilaFavoniaKey).stats.first;
          expect(state.character.key, _keqingKey);
          expect(state.isRecommended, true);
          expect(state.showOnCharacterDetail, false);
          expect(state.skillPriorities.length == 1, true);
          expect(state.notes.length == 1, true);
          expect(state.weapons.length == 1, true);
          expect(state.weapons.first.stat.level, stat.level);
          expect(state.weapons.first.stat.isAnAscension, stat.isAnAscension);
          expect(state.artifacts.length == 5, true);
          expect(state.subStatsSummary.isNotEmpty, true);
          expect(state.teamCharacters.length == 1, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'nothing was set',
      build: () => _getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: _keqingKey))
        ..add(const CustomBuildEvent.saveChanges()),
      verify: (bloc) => bloc.state.maybeMap(
        loaded: (state) {
          expect(state.character.key, _keqingKey);
          expect(state.isRecommended, false);
          expect(state.showOnCharacterDetail, true);
          expect(state.skillPriorities.isEmpty, true);
          expect(state.notes.isEmpty, true);
          expect(state.weapons.isEmpty, true);
          expect(state.artifacts.isEmpty, true);
          expect(state.subStatsSummary.isEmpty, true);
          expect(state.teamCharacters.isEmpty, true);
        },
        orElse: () => throw Exception('Invalid custom build state'),
      ),
    );
  });
}
