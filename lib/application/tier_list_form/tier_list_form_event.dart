part of 'tier_list_form_bloc.dart';

@freezed
sealed class TierListFormEvent with _$TierListFormEvent {
  const factory TierListFormEvent.nameChanged({
    required String name,
  }) = TierListFormEventNameChanged;
}
