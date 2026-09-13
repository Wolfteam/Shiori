import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';

part 'check_for_updates_result.freezed.dart';

@freezed
abstract class CheckForUpdatesResult with _$CheckForUpdatesResult {
  const factory CheckForUpdatesResult({
    required AppResourceUpdateResultType type,
    required int resourceVersion,
    String? jsonFileKeyName,
    int? downloadTotalSize,
    @Default(<String>[]) List<String> keyNames,
    @Default(ResourceUpdateMode.legacy) ResourceUpdateMode mode,
    @Default(<ResourceArchiveResponseDto>[]) List<ResourceArchiveResponseDto> archives,
  }) = _CheckForUpdatesResult;
}
