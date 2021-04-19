extension DurationExtensions on Duration {
  String formatDuration() {
    if (isNegative) {
      return '∞';
    }
    String twoDigits(num n) => n.toString().padLeft(2, '0');
    final twoDigitHour = twoDigits(inHours);
    final twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    if (inHours != 0) return '$twoDigitHour:$twoDigitMinutes:$twoDigitSeconds';
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
