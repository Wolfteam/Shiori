import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';

part 'artifacts_bloc.freezed.dart';
part 'artifacts_event.dart';
part 'artifacts_state.dart';

class ArtifactsBloc extends Bloc<ArtifactsEvent, ArtifactsState> {
  final GenshinService _genshinService;

  ArtifactsBloc(this._genshinService) : super(const ArtifactsState.loading());

  _LoadedState get currentState => state as _LoadedState;

  @override
  Stream<ArtifactsState> mapEventToState(
    ArtifactsEvent event,
  ) async* {
    final s = event.map(
      init: (e) => _buildInitialState(excludeKeys: e.excludeKeys),
      artifactFilterTypeChanged: (e) => currentState.copyWith.call(tempArtifactFilterType: e.artifactFilterType),
      rarityChanged: (e) => currentState.copyWith.call(tempRarity: e.rarity),
      sortDirectionTypeChanged: (e) => currentState.copyWith.call(tempSortDirectionType: e.sortDirectionType),
      searchChanged: (e) => _buildInitialState(
        search: e.search,
        artifactFilterType: currentState.artifactFilterType,
        rarity: currentState.rarity,
        sortDirectionType: currentState.sortDirectionType,
      ),
      applyFilterChanges: (_) => _buildInitialState(
        search: currentState.search,
        artifactFilterType: currentState.tempArtifactFilterType,
        rarity: currentState.tempRarity,
        sortDirectionType: currentState.tempSortDirectionType,
      ),
      cancelChanges: (_) => currentState.copyWith.call(
        tempArtifactFilterType: currentState.artifactFilterType,
        tempRarity: currentState.rarity,
        tempSortDirectionType: currentState.sortDirectionType,
      ),
      collapseNotes: (e) => currentState.copyWith.call(collapseNotes: e.collapse),
      resetFilters: (_) => _buildInitialState(excludeKeys: state.maybeMap(loaded: (state) => state.excludeKeys, orElse: () => [])),
    );

    yield s;
  }

  ArtifactsState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    int rarity = 0,
    ArtifactFilterType artifactFilterType = ArtifactFilterType.name,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
  }) {
    final isLoaded = state is _LoadedState;
    var data = _genshinService.getArtifactsForCard();
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
      );
    }

    if (search != null && search.isNotEmpty) {
      data = data.where((el) => el.name.toLowerCase().contains(search.toLowerCase())).toList();
    }

    if (rarity > 0) {
      data = data.where((el) => el.rarity == rarity).toList();
    }

    _sortData(data, artifactFilterType, sortDirectionType);

    final s = currentState.copyWith.call(
      artifacts: data,
      search: search,
      rarity: rarity,
      tempRarity: rarity,
      artifactFilterType: artifactFilterType,
      tempArtifactFilterType: artifactFilterType,
      sortDirectionType: sortDirectionType,
      tempSortDirectionType: sortDirectionType,
      excludeKeys: excludeKeys,
    );
    return s;
  }

  void _sortData(
    List<ArtifactCardModel> data,
    ArtifactFilterType artifactFilterType,
    SortDirectionType sortDirectionType,
  ) {
    switch (artifactFilterType) {
      case ArtifactFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }
        break;
      case ArtifactFilterType.rarity:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.rarity.compareTo(y.rarity));
        } else {
          data.sort((x, y) => y.rarity.compareTo(x.rarity));
        }
        break;
      default:
        break;
    }
  }
}
