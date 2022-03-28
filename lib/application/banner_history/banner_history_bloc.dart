import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'banner_history_bloc.freezed.dart';
part 'banner_history_event.dart';
part 'banner_history_state.dart';

class BannerHistoryBloc extends Bloc<BannerHistoryEvent, BannerHistoryState> {
  final GenshinService _genshinService;

  BannerHistoryBloc(this._genshinService) : super(const BannerHistoryState.initial(banners: [], versions: []));

  @override
  Stream<BannerHistoryState> mapEventToState(BannerHistoryEvent event) async* {
    final s = event.map(init: (e) => _init(e.type));
    yield s;
  }

  BannerHistoryState _init(BannerHistoryItemType type) {
    final banners = _genshinService.getBannerHistory(type);
    return BannerHistoryState.initial(banners: banners, versions: _genshinService.getBannerHistoryVersions());
  }
}
