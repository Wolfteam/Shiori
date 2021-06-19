extension StringExtensions on String {
  bool get isNullEmptyOrWhitespace => this == null || isEmpty;
  bool get isNotNullEmptyOrWhitespace => !isNullEmptyOrWhitespace;

  bool isValidLength({int minLength = 0, int maxLength = 255}) => isNotNullEmptyOrWhitespace || length > maxLength || length < minLength;
}
