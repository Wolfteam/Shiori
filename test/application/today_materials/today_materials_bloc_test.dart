import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/app_language_type.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final TelemetryService telemetryService;
  late final GenshinService genshinService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(settingsService.language);
    });
  });

  test(
    'Initial state',
    () => expect(TodayMaterialsBloc(genshinService, telemetryService).state, const TodayMaterialsState.loading()),
  );

  blocTest<TodayMaterialsBloc, TodayMaterialsState>(
    'Init',
    build: () => TodayMaterialsBloc(genshinService, telemetryService),
    act: (bloc) => bloc.add(const TodayMaterialsEvent.init()),
    verify: (bloc) {
      bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.charAscMaterials, isNotEmpty);
          expect(state.weaponAscMaterials, isNotEmpty);
          expect(state.charAscMaterials, isNotEmpty);
          final items = state.charAscMaterials.expand((el) => el.characters).toList() + state.weaponAscMaterials.expand((el) => el.weapons).toList();
          checkItemsCommonWithName(items);

          final days = (state.charAscMaterials.expand((e) => e.days).toList() + state.weaponAscMaterials.expand((e) => e.days).toList()).toSet();
          expect(days.length, TodayMaterialsBloc.days.length);
        },
      );
    },
  );
}
