import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'url_page_bloc.freezed.dart';
part 'url_page_event.dart';
part 'url_page_state.dart';

class UrlPageBloc extends Bloc<UrlPageEvent, UrlPageState> {
  final officialMapUrl = 'https://act.hoyolab.com/ys/app/interactive-map/index.html';
  final unofficialMapUrl = 'https://genshin-impact-map.appsample.com';
  final dailyCheckInUrl = 'https://act.hoyolab.com/ys/event/signin-sea-v3/index.html?act_id=e202102251931481';

  final NetworkService _networkService;
  final TelemetryService _telemetryService;
  final DeviceInfoService _deviceInfoService;
  final SettingsService _settingsService;

  UrlPageBloc(
    this._networkService,
    this._telemetryService,
    this._deviceInfoService,
    this._settingsService,
  ) : super(const UrlPageState.loading()) {
    on<UrlPageEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(UrlPageEvent event, Emitter<UrlPageState> emit) async {
    final s = await event.map(
      init: (e) async {
        final finalMapUrl = _settingsService.useOfficialMap ? _getMapUrl() : unofficialMapUrl;
        final isInternetAvailable = await _networkService.isInternetAvailable();
        await _telemetryService.trackUrlOpened(e.loadMap, e.loadDailyCheckIn, isInternetAvailable);
        return UrlPageState.loaded(
          hasInternetConnection: isInternetAvailable,
          mapUrl: finalMapUrl,
          dailyCheckInUrl: _getDailyCheckInUrl(),
          userAgent: _deviceInfoService.userAgent ?? '',
        );
      },
    );

    emit(s);
  }

  String _getDailyCheckInUrl() {
    final lang = _getPageLanguage();
    return '$dailyCheckInUrl&lang=$lang';
  }

  String _getMapUrl() {
    final lang = _getPageLanguage();
    return '$officialMapUrl?lang=$lang';
  }

  String _getPageLanguage() {
    switch (_settingsService.language) {
      case AppLanguageType.spanish:
        return 'es-es';
      case AppLanguageType.french:
        return 'fr-fr';
      case AppLanguageType.russian:
        return 'ru-ru';
      case AppLanguageType.simplifiedChinese:
        return 'zh-cn';
      case AppLanguageType.portuguese:
        return 'pt-pt';
      case AppLanguageType.japanese:
        return 'ja-jp';
      case AppLanguageType.vietnamese:
        return 'vi-vn';
      case AppLanguageType.indonesian:
        return 'id-id';
      case AppLanguageType.italian:
        return 'it-it';
      case AppLanguageType.deutsch:
        return 'de-de';
      case AppLanguageType.traditionalChinese:
        return 'zh-tw';
      case AppLanguageType.korean:
        return 'ko-kr';
      case AppLanguageType.thai:
        return 'th-th';
      case AppLanguageType.turkish:
        return 'tr-tr';
      default:
        return 'en-us';
    }
  }
}
