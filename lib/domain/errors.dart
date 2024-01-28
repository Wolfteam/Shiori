import 'package:shiori/domain/extensions/string_extensions.dart';

class NotFoundError extends Error {
  //The id of the resource
  final dynamic id;

  //Parameter name (if applicable)
  final String? name;

  //Additional message
  final String? message;

  NotFoundError(this.id, [this.name, this.message]);

  @override
  String toString() {
    final String errorValue = Error.safeToString(id);
    final String nameString = name.isNotNullEmptyOrWhitespace ? '($name):' : '';
    final String errorValueString = '($errorValue)';
    final String resourceString = '$nameString$errorValueString';
    return 'NotFoundError: The resource $resourceString does not exist.${message ?? ''}';
  }
}
