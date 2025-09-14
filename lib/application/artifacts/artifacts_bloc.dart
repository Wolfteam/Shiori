import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'artifacts_bloc.freezed.dart';
part 'artifacts_event.dart';
part 'artifacts_state.dart';

class ArtifactsBloc extends Bloc<ArtifactsEvent, ArtifactsState> {
  final GenshinService _genshinService;
  final List<ArtifactCardModel> _allArtifacts = [];

  ArtifactsBloc(this._genshinService) : super(const ArtifactsState.loading());

  ArtifactsStateLoaded get currentState => state as ArtifactsStateLoaded;

  @override
  Stream<ArtifactsState> mapEventToState(ArtifactsEvent event) async* {
    switch (event) {
      case ArtifactsEventInit():
        if (_allArtifacts.isEmpty || event.force) {
          _allArtifacts.clear();
          _allArtifacts.addAll(_genshinService.artifacts.getArtifactsForCard());
        }

        yield _buildInitialState(excludeKeys: event.excludeKeys, type: event.type);
      case ArtifactsEventCollapseNotesChanged():
        yield currentState.copyWith.call(collapseNotes: event.collapse);
      case ArtifactsEventSearchChanged():
        yield _buildInitialState(
          search: event.search,
          artifactFilterType: currentState.artifactFilterType,
          rarity: currentState.rarity,
          sortDirectionType: currentState.sortDirectionType,
          excludeKeys: currentState.excludeKeys,
          type: currentState.type,
        );
      case ArtifactsEventRarityChanged():
        yield currentState.copyWith.call(tempRarity: event.rarity);
      case ArtifactsEventArtifactFilterChanged():
        yield currentState.copyWith.call(tempArtifactFilterType: event.artifactFilterType);
      case ArtifactsEventSortDirectionTypeChanged():
        yield currentState.copyWith.call(tempSortDirectionType: event.sortDirectionType);
      case ArtifactsEventApplyFilterChanges():
        yield _buildInitialState(
          search: currentState.search,
          artifactFilterType: currentState.tempArtifactFilterType,
          rarity: currentState.tempRarity,
          sortDirectionType: currentState.tempSortDirectionType,
          excludeKeys: currentState.excludeKeys,
          type: currentState.type,
        );
      case ArtifactsEventCancelChanges():
        yield currentState.copyWith.call(
          tempArtifactFilterType: currentState.artifactFilterType,
          tempRarity: currentState.rarity,
          tempSortDirectionType: currentState.sortDirectionType,
          excludeKeys: currentState.excludeKeys,
          type: currentState.type,
        );
      case ArtifactsEventResetFilters():
        yield _buildInitialState(excludeKeys: currentState.excludeKeys, type: currentState.type);
    }
  }

  ArtifactsState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    int rarity = 0,
    ArtifactFilterType artifactFilterType = ArtifactFilterType.name,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
    ArtifactType? type,
  }) {
    final isLoaded = state is ArtifactsStateLoaded;
    var data = [..._allArtifacts];
    if (excludeKeys.isNotEmpty) {
      data = data.where((el) => !excludeKeys.contains(el.key)).toList();
    }

    if (!isLoaded) {
      _sortData(data, artifactFilterType, sortDirectionType);
      return ArtifactsState.loaded(
        artifacts: data,
        collapseNotes: false,
        search: search,
        rarity: rarity,
        tempRarity: rarity,
        artifactFilterType: artifactFilterType,
        tempArtifactFilterType: artifactFilterType,
        sortDirectionType: sortDirectionType,
        tempSortDirectionType: sortDirectionType,
        excludeKeys: excludeKeys,
        type: type,
      );
    }

    if (search != null && search.isNotEmpty) {
      data = data.where((el) => el.name.toLowerCase().contains(search.toLowerCase())).toList();
    }

    if (rarity > 0) {
      data = data.where((el) => el.rarity == rarity).toList();
    }

    _sortData(data, artifactFilterType, sortDirectionType);

    return currentState.copyWith.call(
      artifacts: data,
      search: search,
      rarity: rarity,
      tempRarity: rarity,
      artifactFilterType: artifactFilterType,
      tempArtifactFilterType: artifactFilterType,
      sortDirectionType: sortDirectionType,
      tempSortDirectionType: sortDirectionType,
      excludeKeys: excludeKeys,
      type: type,
    );
  }

  void _sortData(List<ArtifactCardModel> data, ArtifactFilterType artifactFilterType, SortDirectionType sortDirectionType) {
    switch (artifactFilterType) {
      case ArtifactFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }
      case ArtifactFilterType.rarity:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.rarity.compareTo(y.rarity));
        } else {
          data.sort((x, y) => y.rarity.compareTo(x.rarity));
        }
    }
  }
}
