/// How the backend answered a resource update check. The integers are wire values shared with the
/// backend enum, so they must not change.
enum ResourceUpdateMode {
  legacy(1),
  delta(2),
  full(3);

  final int value;

  const ResourceUpdateMode(this.value);

  static ResourceUpdateMode? fromValue(int value) {
    for (final mode in ResourceUpdateMode.values) {
      if (mode.value == value) {
        return mode;
      }
    }
    return null;
  }
}
