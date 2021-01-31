extension StringExtensions on String {
  bool get isNullEmptyOrWhitespace => this == null || isEmpty;
  bool get isNotNullEmptyOrWhitespace => !isNullEmptyOrWhitespace;
}
