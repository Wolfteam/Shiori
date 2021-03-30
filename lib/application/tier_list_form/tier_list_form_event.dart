part of 'tier_list_form_bloc.dart';

@freezed
abstract class TierListFormEvent implements _$TierListFormEvent {
  const factory TierListFormEvent.nameChanged({
    @required String name,
  }) = _NameChanged;

  const factory TierListFormEvent.close() = _Close;
}
