import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'banner_history_charts_bloc.freezed.dart';
part 'banner_history_charts_event.dart';
part 'banner_history_charts_state.dart';

class BannerHistoryChartsBloc extends Bloc<BannerHistoryChartsEvent, BannerHistoryChartsState> {
  final GenshinService _genshinService;
  BannerHistoryChartsBloc(this._genshinService) : super(const BannerHistoryChartsState.initial());

  @override
  Stream<BannerHistoryChartsState> mapEventToState(BannerHistoryChartsEvent event) async* {}
}
