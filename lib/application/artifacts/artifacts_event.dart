part of 'artifacts_bloc.dart';

@freezed
sealed class ArtifactsEvent with _$ArtifactsEvent {
  const factory ArtifactsEvent.init({
    @Default(false) bool force,
    @Default(<String>[]) List<String> excludeKeys,
    ArtifactType? type,
  }) = ArtifactsEventInit;

  const factory ArtifactsEvent.collapseNotes({required bool collapse}) = ArtifactsEventCollapseNotesChanged;

  const factory ArtifactsEvent.searchChanged({
    required String search,
  }) = ArtifactsEventSearchChanged;

  const factory ArtifactsEvent.rarityChanged(int rarity) = ArtifactsEventRarityChanged;

  const factory ArtifactsEvent.artifactFilterTypeChanged(ArtifactFilterType artifactFilterType) =
      ArtifactsEventArtifactFilterChanged;

  const factory ArtifactsEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) =
      ArtifactsEventSortDirectionTypeChanged;

  const factory ArtifactsEvent.applyFilterChanges() = ArtifactsEventApplyFilterChanges;

  const factory ArtifactsEvent.cancelChanges() = ArtifactsEventCancelChanges;

  const factory ArtifactsEvent.resetFilters() = ArtifactsEventResetFilters;
}
