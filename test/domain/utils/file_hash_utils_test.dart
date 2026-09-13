import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/utils/file_hash_utils.dart';

void main() {
  late Directory tempDir;

  setUp(() async => tempDir = await Directory.systemTemp.createTemp('shiori-hash'));

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('sha256OfFile matches a one-shot hash of the same bytes', () async {
    final file = File('${tempDir.path}/a.bin');
    //Large enough to span multiple stream chunks
    final bytes = utf8.encode('shiori' * 200000);
    await file.writeAsBytes(bytes);

    final streamed = await FileHashUtils.sha256OfFile(file);

    expect(streamed, sha256.convert(bytes).toString());
  });

  test('sha256OfFile handles an empty file', () async {
    final file = File('${tempDir.path}/empty.bin');
    await file.writeAsBytes(<int>[]);

    expect(await FileHashUtils.sha256OfFile(file), sha256.convert(<int>[]).toString());
  });

  test('sha256OfFile is lowercase hex', () async {
    final file = File('${tempDir.path}/hex.bin');
    await file.writeAsBytes(utf8.encode('shiori'));

    final hash = await FileHashUtils.sha256OfFile(file);

    //The CLI writes lowercase hex into the manifest, and the comparison is a plain string equality
    expect(hash, matches(RegExp(r'^[0-9a-f]{64}$')));
  });
}
