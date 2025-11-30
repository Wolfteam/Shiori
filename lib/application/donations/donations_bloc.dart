import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'donations_bloc.freezed.dart';
part 'donations_event.dart';
part 'donations_state.dart';

class DonationsBloc extends Bloc<DonationsEvent, DonationsState> {
  final PurchaseService _purchaseService;
  final NetworkService _networkService;
  final TelemetryService _telemetryService;

  static int maxUserIdLength = 20;

  //The user id must be something like 12345_xyz
  static String appUserIdRegex = '([a-zA-Z0-9]{5,20})';

  DonationsBloc(this._purchaseService, this._networkService, this._telemetryService) : super(const DonationsState.loading()) {
    on<DonationsEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(DonationsEvent event, Emitter<DonationsState> emit) async {
    emit(const DonationsState.loading());

    if (!await _networkService.isInternetAvailable()) {
      emit(const DonationsState.initial(packages: [], isInitialized: false, noInternetConnection: true, canMakePurchases: false));
      return;
    }

    if (!await _purchaseService.isPlatformSupported()) {
      emit(
        const DonationsState.initial(
          packages: [],
          isInitialized: false,
          noInternetConnection: false,
          canMakePurchases: false,
        ),
      );
      return;
    }

    final canMakePurchases = await _purchaseService.canMakePurchases();
    if (!canMakePurchases) {
      emit(
        DonationsState.initial(
          packages: [],
          isInitialized: _purchaseService.isInitialized,
          noInternetConnection: false,
          canMakePurchases: false,
        ),
      );
      return;
    }

    if (!_purchaseService.isInitialized) {
      await _purchaseService.init();
    }

    final s = await switch (event) {
      DonationsEventInit() => _init(),
      DonationsEventRestorePurchases() => _restorePurchases(),
      final DonationsEventPurchase e => _purchase(e),
    };

    emit(s);

    switch (s) {
      case final DonationsStatePurchaseCompleted state when state.error:
      case final DonationsStateRestoreCompleted state when state.error:
        emit(await _init());
      default:
        break;
    }
  }

  Future<DonationsState> _init() async {
    final packages = await _purchaseService.getInAppPurchases();
    return DonationsState.initial(
      packages: packages,
      isInitialized: _purchaseService.isInitialized,
      noInternetConnection: false,
      canMakePurchases: true,
    );
  }

  Future<DonationsState> _restorePurchases() async {
    final restored = await _purchaseService.restorePurchases();
    await _telemetryService.trackRestore(restored);
    return DonationsState.restoreCompleted(error: !restored);
  }

  Future<DonationsState> _purchase(DonationsEventPurchase e) async {
    if (e.identifier.isNullEmptyOrWhitespace) {
      throw Exception('Invalid package identifier');
    }

    if (e.offeringIdentifier.isNullEmptyOrWhitespace) {
      throw Exception('Invalid offering identifier');
    }

    final succeed = await _purchaseService.purchase(e.identifier, e.offeringIdentifier);
    await _telemetryService.trackPurchase(e.identifier, succeed);
    return DonationsState.purchaseCompleted(error: !succeed);
  }
}
