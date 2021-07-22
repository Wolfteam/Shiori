part of 'artifacts_bloc.dart';

@freezed
class ArtifactsEvent with _$ArtifactsEvent {
  const factory ArtifactsEvent.init({@Default(<String>[]) List<String> excludeKeys}) = _Init;

  const factory ArtifactsEvent.collapseNotes({required bool collapse}) = _CollapseNotesChanged;

  const factory ArtifactsEvent.searchChanged({
    required String search,
  }) = _SearchChanged;

  const factory ArtifactsEvent.rarityChanged(int rarity) = _RarityChanged;

  const factory ArtifactsEvent.artifactFilterTypeChanged(ArtifactFilterType artifactFilterType) = _ArtifactFilterChanged;

  const factory ArtifactsEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) = _SortDirectionTypeChanged;

  const factory ArtifactsEvent.applyFilterChanges() = _ApplyFilterChanges;

  const factory ArtifactsEvent.cancelChanges() = _CancelChanges;

  const factory ArtifactsEvent.resetFilters() = _ResetFilters;
}
