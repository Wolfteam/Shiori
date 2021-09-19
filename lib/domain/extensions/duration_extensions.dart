import 'package:shiori/domain/extensions/string_extensions.dart';

extension DurationExtensions on Duration {
  String formatDuration({String? negativeText}) {
    if (isNegative) {
      return negativeText.isNotNullEmptyOrWhitespace ? negativeText! : '∞';
    }
    String twoDigits(num n) => n.toString().padLeft(2, '0');
    final twoDigitHour = twoDigits(inHours);
    final twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    if (inHours != 0) return '$twoDigitHour:$twoDigitMinutes:$twoDigitSeconds';
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
