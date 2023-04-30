part of 'donations_bloc.dart';

@freezed
class DonationsEvent with _$DonationsEvent {
  const factory DonationsEvent.init() = _Init;

  const factory DonationsEvent.restorePurchases() = _RestorePurchases;

  const factory DonationsEvent.purchase({
    required String identifier,
    required String offeringIdentifier,
  }) = _Purchase;
}
