part of 'donations_bloc.dart';

@freezed
class DonationsState with _$DonationsState {
  const factory DonationsState.loading() = _Loading;

  const factory DonationsState.initial({
    required List<PackageItemModel> packages,
    required bool isInitialized,
    required bool noInternetConnection,
  }) = _InitialState;

  const factory DonationsState.purchaseCompleted({
    required bool error,
  }) = _PurchaseCompleted;

  const factory DonationsState.restoreCompleted({
    required bool error,
  }) = _RestoreCompleted;
}
