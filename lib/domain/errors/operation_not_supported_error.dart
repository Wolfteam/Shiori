class OperationNotSupportedError extends UnsupportedError {
  OperationNotSupportedError(super.message);

  OperationNotSupportedError.value(dynamic value, String name) : super('Value $value with name $name');
}
