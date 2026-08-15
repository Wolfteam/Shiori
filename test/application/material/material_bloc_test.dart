import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final TelemetryService telemetryService;
  late final GenshinService genshinService;
  late final ResourceService resourceService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settingsService);
    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(settingsService.language);
    });
  });

  test(
    'Initial state',
    () => expect(
      MaterialBloc(genshinService, telemetryService, resourceService).state,
      const MaterialState.loading(),
      reason: 'A fresh MaterialBloc should start in loading state',
    ),
  );

  group('Load from key', () {
    const key = 'slime-secretions';
    blocTest<MaterialBloc, MaterialState>(
      key,
      build: () => MaterialBloc(genshinService, telemetryService, resourceService),
      act: (bloc) => bloc.add(const MaterialEvent.loadFromKey(key: key)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case MaterialStateLoading():
            throw InvalidStateError();
          case MaterialStateLoaded():
            checkTranslation(state.name, canBeNull: false);
            checkAsset(state.fullImage);
            expect(state.rarity, 2, reason: 'slime-secretions rarity should be 2, got ${state.rarity}');
            expect(state.type, MaterialType.common, reason: 'slime-secretions should be a common material, got ${state.type}');
            checkItemsCommonWithName(state.characters);
            checkItemsCommonWithName(state.weapons);
            checkItemsCommonWithName(state.droppedBy);
            expect(state.days, isEmpty, reason: 'slime-secretions is not farmable by day so days should be empty');
            expect(state.obtainedFrom, isNotEmpty, reason: 'slime-secretions should list at least one obtainedFrom source');
            final items = state.obtainedFrom.expand((el) => el.items).toList();
            for (final item in items) {
              checkItemKeyAndImage(item.key, item.image);
            }
            checkItemsCommonWithName(state.relatedMaterials);
        }
      },
    );
  });
}
