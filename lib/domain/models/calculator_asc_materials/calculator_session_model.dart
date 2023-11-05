import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculator_session_model.freezed.dart';

@freezed
class CalculatorSessionModel with _$CalculatorSessionModel {
  const factory CalculatorSessionModel({
    required int key,
    required String name,
    required int position,
    required int numberOfCharacters,
    required int numberOfWeapons,
  }) = _CalculatorSessionModel;
}
