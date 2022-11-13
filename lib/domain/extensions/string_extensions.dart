extension StringExtensions on String? {
  bool get isNullEmptyOrWhitespace => this == null || this!.isEmpty;

  bool get isNotNullEmptyOrWhitespace => !isNullEmptyOrWhitespace;

  bool isValidLength({int minLength = 0, int maxLength = 255}) => isNotNullEmptyOrWhitespace || this!.length > maxLength || this!.length < minLength;

  String substringIfOverflow(int maxLength, {int numberOfDots = 3}) {
    if (isNullEmptyOrWhitespace) {
      return '';
    }

    if (this!.length < maxLength) {
      return this!;
    }

    final take = maxLength - numberOfDots;
    if (this!.length < take) {
      return this!;
    }

    final newValue = this!.substring(0, take);
    return '$newValue...';
  }

  String toCapitalized() => this == null
      ? ''
      : this!.isNotEmpty
          ? '${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}'
          : '';
}
