import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final SettingsService settingsService;
  late final LocaleService localeService;
  late final GenshinService genshinService;

  final expectedDays = [
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
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    manuallyInitLocale(localeService, settingsService.language);

    return Future(() async {
      await genshinService.init(settingsService.language);
    });
  });

  test('Initial state', () => expect(HomeBloc(genshinService, settingsService, localeService).state, const HomeState.loading()));

  void checkState(HomeState state, AppServerResetTimeType resetTimeType, {bool checkServerDate = true}) {
    switch (state) {
      case HomeStateLoading():
        throw InvalidStateError();
      case HomeStateLoaded():
        expect(state.charAscMaterials, isNotEmpty);
        expect(state.weaponAscMaterials, isNotEmpty);
        expect(state.day, isIn(expectedDays));
        if (checkServerDate) {
          final serverDate = genshinService.getServerDate(resetTimeType);
          expect(state.day, serverDate.weekday);
          final dayName = localeService.getDayNameFromDate(serverDate);
          expect(dayName, state.dayName);
        }

        final allChars = genshinService.characters.getCharactersForCard();

        for (final material in state.charAscMaterials) {
          checkKey(material.key);
          checkTranslation(material.name, canBeNull: false);
          checkAsset(material.image);
          expect(material.days, isNotEmpty);
          expect(material.days.every((day) => expectedDays.contains(day)), isTrue);
          if (material.characters.isEmpty) {
            final charsThatUseThisMaterial = allChars.where((c) => c.materials.contains(material.key)).toList();
            for (final char in charsThatUseThisMaterial) {
              expect(char.isComingSoon, isTrue);
            }
          }
          checkItemsCommonWithName(material.characters, checkEmpty: material.characters.isNotEmpty);
        }

        for (final material in state.weaponAscMaterials) {
          checkKey(material.key);
          checkTranslation(material.name, canBeNull: false);
          checkAsset(material.image);
          expect(material.days, isNotEmpty);
          expect(material.days.every((day) => expectedDays.contains(day)), isTrue);
          checkItemsCommonWithName(material.weapons);
        }

        for (final birthday in state.characterImgBirthday) {
          checkItemKeyAndImage(birthday.key, birthday.image);
        }
    }
  }

  group('Init', () {
    blocTest<HomeBloc, HomeState>(
      'north america reset time',
      setUp: () {
        when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);
      },
      build: () => HomeBloc(genshinService, settingsService, localeService),
      act: (bloc) => bloc.add(const HomeEvent.init()),
      verify: (bloc) {
        checkState(bloc.state, AppServerResetTimeType.northAmerica);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'asia reset time',
      setUp: () {
        when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.asia);
      },
      build: () => HomeBloc(genshinService, settingsService, localeService),
      act: (bloc) => bloc.add(const HomeEvent.init()),
      verify: (bloc) {
        checkState(bloc.state, AppServerResetTimeType.asia);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'europe reset time',
      setUp: () {
        when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.europe);
      },
      build: () => HomeBloc(genshinService, settingsService, localeService),
      act: (bloc) => bloc.add(const HomeEvent.init()),
      verify: (bloc) {
        checkState(bloc.state, AppServerResetTimeType.europe);
      },
    );
  });

  const day = DateTime.sunday;
  blocTest<HomeBloc, HomeState>(
    'Day changed',
    setUp: () {
      when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);
    },
    build: () => HomeBloc(genshinService, settingsService, localeService),
    act: (bloc) => bloc.add(const HomeEvent.dayChanged(newDay: day)),
    verify: (bloc) {
      final state = bloc.state;
      switch (state) {
        case HomeStateLoading():
          throw InvalidStateError();
        case HomeStateLoaded():
          final charMaterials = genshinService.characters.getCharacterAscensionMaterials(day);
          final weaponMaterials = genshinService.weapons.getWeaponAscensionMaterials(day);
          final now = DateTime.now();
          final charsForBirthday = genshinService.characters.getCharacterBirthdays(month: now.month, day: now.day);
          checkState(state, AppServerResetTimeType.northAmerica, checkServerDate: false);
          expect(state.charAscMaterials.length, charMaterials.length);
          expect(state.weaponAscMaterials.length, weaponMaterials.length);
          expect(state.characterImgBirthday.length, charsForBirthday.length);
      }
    },
  );
}
