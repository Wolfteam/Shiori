import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/infrastructure/infrastructure.dart';

void main() {
  const checker = DiskSpaceInfoChecker();

  test('reports a plausible amount of free space for an existing directory', () async {
    final free = await checker.freeBytesFor(Directory.systemTemp.path);

    //A null here would mean the ffi query failed on this platform, which is what this test guards
    expect(free, isNotNull);
    expect(free, greaterThan(0));
  });

  test('answers for a path that does not exist yet', () async {
    //The updater asks about an archive it is about to create, so the path is normally absent
    final path = p.join(Directory.systemTemp.path, 'shiori-not-created-yet', 'delta.zip');

    expect(await checker.freeBytesFor(path), isNotNull);
  });

  test('does not throw for a path whose ancestors do not exist either', () async {
    //It resolves to the nearest existing ancestor, so this answers instead of failing
    expect(await checker.freeBytesFor('/this/does/not/resolve/anywhere/at/all'), isNotNull);
  });
}
