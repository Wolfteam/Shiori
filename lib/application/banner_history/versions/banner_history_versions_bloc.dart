import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'banner_history_versions_bloc.freezed.dart';
part 'banner_history_versions_event.dart';
part 'banner_history_versions_state.dart';

class BannerHistoryVersionsBloc extends Bloc<BannerHistoryVersionsEvent, BannerHistoryVersionsState> {
  final GenshinService _genshinService;

  BannerHistoryVersionsBloc(this._genshinService) : super(const BannerHistoryVersionsState.initial(banners: [], versions: []));

  @override
  Stream<BannerHistoryVersionsState> mapEventToState(BannerHistoryVersionsEvent event) async* {
    final s = event.map(init: (e) => _init(e.type));
    yield s;
  }

  BannerHistoryVersionsState _init(BannerHistoryItemType type) {
    final banners = _genshinService.getBannerHistory(type);
    return BannerHistoryVersionsState.initial(banners: banners, versions: _genshinService.getBannerHistoryVersions());
  }
}
