import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'game_code_response_dto.g.dart';

@JsonSerializable()
class GameCodeResponseDto {
  final String code;

  @JsonKey(name: 'region')
  final int? regionIndex;

  AppServerResetTimeType? get region => regionIndex == null ? null : AppServerResetTimeType.values[regionIndex!];

  final DateTime? discoveredOn;

  final DateTime? expiredOn;

  final bool isExpired;

  final List<WikiGameCodeMaterialResponseDto> rewards;

  const GameCodeResponseDto({
    required this.code,
    this.regionIndex,
    this.discoveredOn,
    this.expiredOn,
    required this.isExpired,
    required this.rewards,
  });

  factory GameCodeResponseDto.fromJson(Map<String, dynamic> json) => _$GameCodeResponseDtoFromJson(json);
}

@JsonSerializable()
class WikiGameCodeMaterialResponseDto {
  final String wikiName;

  @JsonKey(name: 'type')
  final int typeIndex;

  MaterialType get type => MaterialType.values[typeIndex];

  final int quantity;

  const WikiGameCodeMaterialResponseDto({
    required this.wikiName,
    required this.typeIndex,
    required this.quantity,
  });

  factory WikiGameCodeMaterialResponseDto.fromJson(Map<String, dynamic> json) => _$WikiGameCodeMaterialResponseDtoFromJson(json);
}
