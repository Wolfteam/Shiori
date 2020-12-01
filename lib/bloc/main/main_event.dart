part of 'main_bloc.dart';

@freezed
abstract class MainEvent with _$MainEvent {
  const factory MainEvent.init() = MainInitEvent;

  const factory MainEvent.themeChanged({
    @required AppThemeType theme,
  }) = MainThemeChangedEvent;

  const factory MainEvent.accentColorChanged({
    @required AppAccentColorType accentColor,
  }) = MainAccentColorChangedEvent;

  const factory MainEvent.goToTab({@required int index}) = MainGoToTabEvent;

  const MainEvent._();
}
