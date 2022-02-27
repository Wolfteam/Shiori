import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';

part 'donations_bloc.freezed.dart';
part 'donations_event.dart';
part 'donations_state.dart';

class DonationsBloc extends Bloc<DonationsEvent, DonationsState> {
  final PurchaseService _purchaseService;
  final NetworkService _networkService;

  static int maxUserIdLength = 20;

  DonationsBloc(this._purchaseService, this._networkService) : super(const DonationsState.loading());

  @override
  Stream<DonationsState> mapEventToState(DonationsEvent event) async* {
    if (!await _networkService.isInternetAvailable()) {
      yield const DonationsState.initial(packages: [], isInitialized: false, noInternetConnection: true);
      return;
    }

    if (!await _purchaseService.isPlatformSupported()) {
      yield const DonationsState.initial(packages: [], isInitialized: false, noInternetConnection: false);
      return;
    }

    if (!_purchaseService.isInitialized) {
      await _purchaseService.init();
    }

    final currentState = state;
    final s = await event.map(
      init: (_) => _init(),
      restorePurchases: (e) => _restorePurchases(e.userId),
      purchase: (e) => _purchase(e),
    );

    yield s;

    if ((s is _PurchaseCompleted && s.error) || (s is _RestoreCompleted && s.error)) {
      yield currentState;
    }
  }

  Future<DonationsState> _init() async {
    final packages = await _purchaseService.getInAppPurchases();
    return DonationsState.initial(packages: packages, isInitialized: _purchaseService.isInitialized, noInternetConnection: false);
  }

  Future<DonationsState> _restorePurchases(String userId) async {
    final restored = await _purchaseService.restorePurchases(userId);
    return DonationsState.restoreCompleted(error: !restored);
  }

  Future<DonationsState> _purchase(_Purchase e) async {
    final succeed = await _purchaseService.purchase(e.userId, e.identifier, e.offeringIdentifier);
    return DonationsState.purchaseCompleted(error: !succeed);
  }
}
