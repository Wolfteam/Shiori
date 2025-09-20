class InvalidStateError extends Error {
  final Type? type;

  InvalidStateError([this.type]);

  @override
  String toString() {
    const msg = 'InvalidStateError: Invalid state';
    if (type == null) {
      return '$msg on type $type';
    }
    return msg;
  }
}
