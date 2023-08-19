import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/domain/services/logging_service.dart';

class AppBlocObserver extends BlocObserver {
  final LoggingService _logger;

  AppBlocObserver(this._logger);

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.error(bloc.runtimeType, 'Bloc error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
