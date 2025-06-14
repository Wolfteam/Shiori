part of 'donations_bloc.dart';

@freezed
sealed class DonationsState with _$DonationsState {
  const factory DonationsState.loading() = DonationsStateLoading;

  const factory DonationsState.initial({
    required List<PackageItemModel> packages,
    required bool isInitialized,
    required bool noInternetConnection,
    required bool canMakePurchases,
  }) = DonationsStateInitial;

  const factory DonationsState.purchaseCompleted({
    required bool error,
  }) = DonationsStatePurchaseCompleted;

  const factory DonationsState.restoreCompleted({
    required bool error,
  }) = DonationsStateRestoreCompleted;
}
