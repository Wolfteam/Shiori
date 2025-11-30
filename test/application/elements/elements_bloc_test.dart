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
  late final GenshinService genshinService;
  late final SettingsService settingsService;
  late final LocaleService localeService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);

      localeService = LocaleServiceImpl(settingsService);
      final resourceService = getResourceService(settingsService);
      genshinService = GenshinServiceImpl(resourceService, localeService);

      await genshinService.init(settingsService.language);
    });
  });

  test('Initial state', () => expect(ElementsBloc(genshinService).state, const ElementsState.loading()));

  blocTest<ElementsBloc, ElementsState>(
    'Init',
    build: () => ElementsBloc(genshinService),
    act: (bloc) => bloc.add(const ElementsEvent.init()),
    verify: (bloc) {
      final state = bloc.state;
      switch (state) {
        case ElementsStateLoading():
          throw InvalidStateError();
        case ElementsStateLoaded():
          expect(state.debuffs.length, 4);
          expect(state.reactions.length, 17);
          expect(state.resonances.length, 8);

          for (final debuff in state.debuffs) {
            checkTranslation(debuff.name, canBeNull: false);
            checkTranslation(debuff.effect, canBeNull: false);
            checkAsset(debuff.image);
          }

          final reactionImgs = state.reactions.expand((e) => e.principal + e.secondary).toList();
          for (final img in reactionImgs) {
            checkAsset(img);
          }

          final resonanceImgs = state.resonances.expand((e) => e.principal + e.secondary).toList();
          for (final img in resonanceImgs) {
            checkAsset(img);
          }
      }
    },
  );
}
