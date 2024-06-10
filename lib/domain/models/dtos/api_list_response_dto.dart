import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/models/dtos.dart';

part 'api_list_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiListResponseDto<T> implements ApiResponseDto<List<T>> {
  @override
  final String? message;

  @override
  final String? messageId;

  @override
  final List<T> result;

  @override
  final bool succeed;

  const ApiListResponseDto({
    required this.succeed,
    required this.result,
    this.message,
    this.messageId,
  });

  factory ApiListResponseDto.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) => _$ApiListResponseDtoFromJson(json, fromJsonT);
}
