part of 'tier_list_form_bloc.dart';

@freezed
abstract class TierListFormState implements _$TierListFormState {
  const factory TierListFormState.loaded({
    @required String name,
    @required bool isNameDirty,
    @required bool isNameValid,
  }) = _LoadedState;
}
