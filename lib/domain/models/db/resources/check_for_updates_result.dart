import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'check_for_updates_result.freezed.dart';

@freezed
class CheckForUpdatesResult with _$CheckForUpdatesResult {
  const factory CheckForUpdatesResult({
    required AppResourceUpdateResultType result,
    required int resourceVersion,
    String? zipFileKeyName,
    String? jsonFileKeyName,
    @Default(<String>[]) List<String> keyNames,
  }) = _CheckForUpdatesResult;
}
