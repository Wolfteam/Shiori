part of 'donations_bloc.dart';

@freezed
sealed class DonationsEvent with _$DonationsEvent {
  const factory DonationsEvent.init() = DonationsEventInit;

  const factory DonationsEvent.restorePurchases() = DonationsEventRestorePurchases;

  const factory DonationsEvent.purchase({
    required String identifier,
    required String offeringIdentifier,
  }) = DonationsEventPurchase;
}
