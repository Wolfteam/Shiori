import 'package:freezed_annotation/freezed_annotation.dart';

part 'empty_response_dto.g.dart';

abstract class BaseResponseDto {
  bool get succeed;

  String? get message;

  String? get messageId;
}

@JsonSerializable()
class EmptyResponseDto {
  final String? message;

  final String? messageId;

  final bool succeed;

  const EmptyResponseDto({
    required this.succeed,
    required this.message,
    required this.messageId,
  });

  factory EmptyResponseDto.fromJson(Map<String, dynamic> json) => _$EmptyResponseDtoFromJson(json);
}
