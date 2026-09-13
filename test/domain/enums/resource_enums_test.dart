import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

void main() {
  group('ResourceContractVersion', () {
    test('values match the backend wire protocol', () {
      expect(ResourceContractVersion.v1.value, 1);
      expect(ResourceContractVersion.v2.value, 2);
    });

    test('fromValue maps known values and returns null otherwise', () {
      expect(ResourceContractVersion.fromValue(2), ResourceContractVersion.v2);
      expect(ResourceContractVersion.fromValue(99), isNull);
    });

    test('this build declares contract 2', () {
      expect(appResourceContractVersion, ResourceContractVersion.v2);
    });
  });

  group('ResourceUpdateMode', () {
    test('values match the backend wire protocol', () {
      expect(ResourceUpdateMode.legacy.value, 1);
      expect(ResourceUpdateMode.delta.value, 2);
      expect(ResourceUpdateMode.full.value, 3);
    });

    test('fromValue defaults to null for unknown modes', () {
      expect(ResourceUpdateMode.fromValue(3), ResourceUpdateMode.full);
      expect(ResourceUpdateMode.fromValue(42), isNull);
    });
  });
}
