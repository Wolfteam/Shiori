part of 'main_tab_bloc.dart';

@freezed
abstract class MainTabEvent with _$MainTabEvent {
  const factory MainTabEvent.goToTab({
    @required int index,
  }) = _GoToTab;
}
