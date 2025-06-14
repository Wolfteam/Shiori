part of 'main_tab_bloc.dart';

@freezed
sealed class MainTabEvent with _$MainTabEvent {
  const factory MainTabEvent.goToTab({
    required int index,
  }) = MainTabEventGoToTab;
}
