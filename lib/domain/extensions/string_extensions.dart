extension StringExtensions on String? {
  bool get isNullEmptyOrWhitespace => this == null || this!.isEmpty;
  bool get isNotNullEmptyOrWhitespace => !isNullEmptyOrWhitespace;

  bool isValidLength({int minLength = 0, int maxLength = 255}) => isNotNullEmptyOrWhitespace || this!.length > maxLength || this!.length < minLength;
}
