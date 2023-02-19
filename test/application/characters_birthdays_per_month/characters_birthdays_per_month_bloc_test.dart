import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late LocaleService localeService;
  late SettingsService settingsService;
  late GenshinService genshinService;
  late TelemetryService telemetryService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.showCharacterDetails).thenReturn(true);
    localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    telemetryService = MockTelemetryService();

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  test(
    'Initial state',
    () => expect(
      CharactersBirthdaysPerMonthBloc(genshinService, telemetryService).state,
      const CharactersBirthdaysPerMonthState.loading(),
    ),
  );

  group('Init', () {
    blocTest<CharactersBirthdaysPerMonthBloc, CharactersBirthdaysPerMonthState>(
      'emits loaded state',
      build: () => CharactersBirthdaysPerMonthBloc(genshinService, telemetryService),
      act: (bloc) => bloc.add(const CharactersBirthdaysPerMonthEvent.init(month: DateTime.january)),
      expect: () {
        final characters = genshinService.characters.getCharacterBirthdays(month: DateTime.january);
        return [CharactersBirthdaysPerMonthState.loaded(characters: characters, month: DateTime.january)];
      },
    );

    blocTest<CharactersBirthdaysPerMonthBloc, CharactersBirthdaysPerMonthState>(
      'invalid month',
      build: () => CharactersBirthdaysPerMonthBloc(genshinService, telemetryService),
      act: (bloc) => bloc.add(const CharactersBirthdaysPerMonthEvent.init(month: 13)),
      errors: () => [isA<Exception>()],
    );
  });
}
