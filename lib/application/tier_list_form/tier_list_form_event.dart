part of 'tier_list_form_bloc.dart';

@freezed
class TierListFormEvent with _$TierListFormEvent {
  const factory TierListFormEvent.nameChanged({
    required String name,
  }) = _NameChanged;

  const factory TierListFormEvent.close() = _Close;
}
