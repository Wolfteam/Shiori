import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final SettingsService _settingsService;
  late final LocaleService _localeService;
  late final GenshinService _genshinService;

  final _expectedDays = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    _localeService = LocaleServiceImpl(_settingsService);
    final resourceService = getResourceService(_settingsService);
    _genshinService = GenshinServiceImpl(resourceService, _localeService);
    manuallyInitLocale(_localeService, _settingsService.language);

    return Future(() async {
      await _genshinService.init(_settingsService.language);
    });
  });

  test('Initial state', () => expect(HomeBloc(_genshinService, _settingsService, _localeService).state, const HomeState.loading()));

  void _checkState(HomeState state, AppServerResetTimeType resetTimeType, {bool checkServerDate = true}) {
    state.map(
      loading: (_) => throw Exception('Invalid state'),
      loaded: (state) {
        expect(state.charAscMaterials, isNotEmpty);
        expect(state.weaponAscMaterials, isNotEmpty);
        expect(state.day, isIn(_expectedDays));
        if (checkServerDate) {
          final serverDate = _genshinService.getServerDate(resetTimeType);
          expect(state.day, serverDate.weekday);
          final dayName = _localeService.getDayNameFromDate(serverDate);
          expect(dayName, state.dayName);
        }

        for (final material in state.charAscMaterials) {
          checkKey(material.key);
          checkTranslation(material.name, canBeNull: false);
          checkAsset(material.image);
          expect(material.days, isNotEmpty);
          expect(material.days.every((day) => _expectedDays.contains(day)), isTrue);
          checkItemsCommon(material.characters);
        }

        for (final material in state.weaponAscMaterials) {
          checkKey(material.key);
          checkTranslation(material.name, canBeNull: false);
          checkAsset(material.image);
          expect(material.days, isNotEmpty);
          expect(material.days.every((day) => _expectedDays.contains(day)), isTrue);
          checkItemsCommon(material.weapons);
        }

        for (final birthday in state.characterImgBirthday) {
          checkItemKeyAndImage(birthday.key, birthday.image);
        }
      },
    );
  }

  group('Init', () {
    blocTest<HomeBloc, HomeState>(
      'north america reset time',
      setUp: () {
        when(_settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);
      },
      build: () => HomeBloc(_genshinService, _settingsService, _localeService),
      act: (bloc) => bloc.add(const HomeEvent.init()),
      verify: (bloc) {
        _checkState(bloc.state, AppServerResetTimeType.northAmerica);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'asia reset time',
      setUp: () {
        when(_settingsService.serverResetTime).thenReturn(AppServerResetTimeType.asia);
      },
      build: () => HomeBloc(_genshinService, _settingsService, _localeService),
      act: (bloc) => bloc.add(const HomeEvent.init()),
      verify: (bloc) {
        _checkState(bloc.state, AppServerResetTimeType.asia);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'europe reset time',
      setUp: () {
        when(_settingsService.serverResetTime).thenReturn(AppServerResetTimeType.europe);
      },
      build: () => HomeBloc(_genshinService, _settingsService, _localeService),
      act: (bloc) => bloc.add(const HomeEvent.init()),
      verify: (bloc) {
        _checkState(bloc.state, AppServerResetTimeType.europe);
      },
    );
  });

  const day = DateTime.sunday;
  blocTest<HomeBloc, HomeState>(
    'Day changed',
    setUp: () {
      when(_settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);
    },
    build: () => HomeBloc(_genshinService, _settingsService, _localeService),
    act: (bloc) => bloc.add(const HomeEvent.dayChanged(newDay: day)),
    verify: (bloc) {
      bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          final charMaterials = _genshinService.characters.getCharacterAscensionMaterials(day);
          final weaponMaterials = _genshinService.weapons.getWeaponAscensionMaterials(day);
          final now = DateTime.now();
          final charsForBirthday = _genshinService.characters.getCharacterBirthdays(month: now.month, day: now.day);
          _checkState(state, AppServerResetTimeType.northAmerica, checkServerDate: false);
          expect(state.charAscMaterials.length, charMaterials.length);
          expect(state.weaponAscMaterials.length, weaponMaterials.length);
          expect(state.characterImgBirthday.length, charsForBirthday.length);
        },
      );
    },
  );
}
