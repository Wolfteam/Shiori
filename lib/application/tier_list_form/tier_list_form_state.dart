part of 'tier_list_form_bloc.dart';

@freezed
class TierListFormState with _$TierListFormState {
  const factory TierListFormState.loaded({
    required String name,
    required bool isNameDirty,
    required bool isNameValid,
  }) = _LoadedState;
}
