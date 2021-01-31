import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/services/network_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'url_page_bloc.freezed.dart';
part 'url_page_event.dart';
part 'url_page_state.dart';

class UrlPageBloc extends Bloc<UrlPageEvent, UrlPageState> {
  final wishSimulatorUrl = 'https://gi-wish-simulator.uzairashraf.dev';
  final mapUrl = 'https://genshin-impact-map.appsample.com';

  final NetworkService _networkService;
  final TelemetryService _telemetryService;

  UrlPageBloc(this._networkService, this._telemetryService) : super(const UrlPageState.loading());

  @override
  Stream<UrlPageState> mapEventToState(
    UrlPageEvent event,
  ) async* {
    final s = await event.map(
      init: (e) async {
        final isInternetAvailable = await _networkService.isInternetAvailable();
        await _telemetryService.trackUrlOpened(e.loadMap, e.loadWishSimulator, isInternetAvailable);
        return UrlPageState.loaded(
          hasInternetConnection: isInternetAvailable,
          mapUrl: mapUrl,
          wishSimulatorUrl: wishSimulatorUrl,
        );
      },
    );

    yield s;
  }
}
