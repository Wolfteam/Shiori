import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'banner_version_history_bloc.freezed.dart';
part 'banner_version_history_event.dart';
part 'banner_version_history_state.dart';

class BannerVersionHistoryBloc extends Bloc<BannerVersionHistoryEvent, BannerVersionHistoryState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  static const periodDateFormat = 'yyyy/MM/dd';

  BannerVersionHistoryBloc(this._genshinService, this._telemetryService) : super(const BannerVersionHistoryState.loading()) {
    on<BannerVersionHistoryEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(BannerVersionHistoryEvent event, Emitter<BannerVersionHistoryState> emit) async {
    switch (event) {
      case BannerVersionHistoryEventInit():
        final state = await _init(event.version);
        emit(state);
    }
  }

  Future<BannerVersionHistoryState> _init(double version) async {
    await _telemetryService.trackBannerHistoryItemOpened(version);
    final banners = _genshinService.bannerHistory.getBanners(version);
    final grouped = banners
        .groupListsBy(
          (el) => '${DateFormat(periodDateFormat).format(el.from)}_${DateFormat(periodDateFormat).format(el.until)}',
        )
        .values
        .map(
          (e) {
            final group = e.first;
            final items = e.expand((el) => el.items).toList();
            final finalItems = <ItemCommonWithRarityAndType>[];
            //this is to avoid duplicate items (e.g: on double banners like 2.4)
            for (final item in items) {
              if (finalItems.any((el) => el.key == item.key)) {
                continue;
              }
              finalItems.add(item);
            }

            return BannerHistoryGroupedPeriodModel(
              from: DateFormat(periodDateFormat).format(group.from),
              until: DateFormat(periodDateFormat).format(group.until),
              items: finalItems,
            );
          },
        )
        .toList();
    return BannerVersionHistoryState.loadedState(version: version, items: grouped);
  }
}
