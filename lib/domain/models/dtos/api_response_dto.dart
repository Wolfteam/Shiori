import 'package:json_annotation/json_annotation.dart';
import 'package:shiori/domain/models/dtos/empty_response_dto.dart';

part 'api_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponseDto<T> implements EmptyResponseDto {
  @override
  final String? message;

  @override
  final String? messageId;

  @override
  final bool succeed;

  final T? result;

  ApiResponseDto({
    required this.succeed,
    this.message,
    this.messageId,
    this.result,
  });

  factory ApiResponseDto.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) => _$ApiResponseDtoFromJson(json, fromJsonT);
}
