import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
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

  //The user id must be something like 12345_xyz
  static String appUserIdRegex = '([a-zA-Z0-9]{5,20})';

  DonationsBloc(this._purchaseService, this._networkService) : super(const DonationsState.loading());

  @override
  Stream<DonationsState> mapEventToState(DonationsEvent event) async* {
    yield const DonationsState.loading();

    if (!await _networkService.isInternetAvailable()) {
      yield const DonationsState.initial(packages: [], isInitialized: false, noInternetConnection: true, canMakePurchases: false);
      return;
    }

    if (!await _purchaseService.isPlatformSupported()) {
      yield const DonationsState.initial(packages: [], isInitialized: false, noInternetConnection: false, canMakePurchases: false);
      return;
    }

    final canMakePurchases = await _purchaseService.canMakePurchases();
    if (!canMakePurchases) {
      yield DonationsState.initial(
        packages: [],
        isInitialized: _purchaseService.isInitialized,
        noInternetConnection: false,
        canMakePurchases: false,
      );
      return;
    }

    if (!_purchaseService.isInitialized) {
      await _purchaseService.init();
    }

    final s = await event.map(
      init: (_) => _init(),
      restorePurchases: (e) => _restorePurchases(e.userId),
      purchase: (e) => _purchase(e),
    );

    yield s;
    yield await s.maybeMap(
      purchaseCompleted: (state) async {
        if (state.error) {
          return _init();
        }
        return state;
      },
      restoreCompleted: (state) async {
        if (state.error) {
          return _init();
        }
        return state;
      },
      orElse: () async => s,
    );
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

  Future<DonationsState> _restorePurchases(String userId) async {
    if (!RegExp(appUserIdRegex).hasMatch(userId)) {
      throw Exception('AppUserId is not valid');
    }
    final restored = await _purchaseService.restorePurchases(userId);
    return DonationsState.restoreCompleted(error: !restored);
  }

  Future<DonationsState> _purchase(_Purchase e) async {
    if (!RegExp(appUserIdRegex).hasMatch(e.userId)) {
      throw Exception('AppUserId is not valid');
    }

    if (e.identifier.isNullEmptyOrWhitespace) {
      throw Exception('Invalid package identifier');
    }

    if (e.offeringIdentifier.isNullEmptyOrWhitespace) {
      throw Exception('Invalid offering identifier');
    }

    final succeed = await _purchaseService.purchase(e.userId, e.identifier, e.offeringIdentifier);
    return DonationsState.purchaseCompleted(error: !succeed);
  }
}
