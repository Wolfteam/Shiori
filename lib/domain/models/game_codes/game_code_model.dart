import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'game_code_model.freezed.dart';

@freezed
class GameCodeModel with _$GameCodeModel {
  const factory GameCodeModel({
    required String code,
    AppServerResetTimeType? region,
    DateTime? discoveredOn,
    DateTime? expiredOn,
    required bool isExpired,
    required bool isUsed,
    required List<ItemAscensionMaterialModel> rewards,
  }) = _GameCodeModel;
}
