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
  late final GenshinService _genshinService;
  late final SettingsService _settingsService;
  late final LocaleService _localeService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      _settingsService = MockSettingsService();
      when(_settingsService.language).thenReturn(AppLanguageType.english);

      _localeService = LocaleServiceImpl(_settingsService);
      final resourceService = getResourceService(_settingsService);
      _genshinService = GenshinServiceImpl(resourceService, _localeService);

      await _genshinService.init(_settingsService.language);
    });
  });

  test('Initial state', () => expect(ElementsBloc(_genshinService).state, const ElementsState.loading()));

  blocTest<ElementsBloc, ElementsState>(
    'Init',
    build: () => ElementsBloc(_genshinService),
    act: (bloc) => bloc.add(const ElementsEvent.init()),
    verify: (bloc) {
      bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
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
        },
      );
    },
  );
}
