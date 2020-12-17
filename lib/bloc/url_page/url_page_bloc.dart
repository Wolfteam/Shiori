import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../services/network_service.dart';

part 'url_page_bloc.freezed.dart';
part 'url_page_event.dart';
part 'url_page_state.dart';

class UrlPageBloc extends Bloc<UrlPageEvent, UrlPageState> {
  final wishSimulatorUrl = 'https://gi-wish-simulator.uzairashraf.dev';
  final mapUrl = 'https://genshin-impact-map.appsample.com';

  final NetworkService _networkService;
  UrlPageBloc(this._networkService) : super(const UrlPageState.loading());

  @override
  Stream<UrlPageState> mapEventToState(
    UrlPageEvent event,
  ) async* {
    final s = await event.when(
      init: () async {
        final isInternetAvailable = await _networkService.isInternetAvailable();
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
