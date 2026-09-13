/// The integers are the wire values sent as the contractVersion query param and stored in
/// versions.json / manifest.json, so they must not change.
enum ResourceContractVersion {
  v1(1),
  v2(2);

  final int value;

  const ResourceContractVersion(this.value);

  static ResourceContractVersion? fromValue(int value) {
    for (final version in ResourceContractVersion.values) {
      if (version.value == value) {
        return version;
      }
    }
    return null;
  }
}

/// The contract this build supports. Bump it here and nowhere else.
const ResourceContractVersion appResourceContractVersion = ResourceContractVersion.v2;
