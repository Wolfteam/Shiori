import 'dart:io';

import 'package:crypto/crypto.dart';

/// Hashing helpers that never hold a whole file in memory — archives reach 150+ MB.
class FileHashUtils {
  static Future<String> sha256OfFile(File file) async {
    final digestSink = _DigestSink();
    final sink = sha256.startChunkedConversion(digestSink);
    await for (final chunk in file.openRead()) {
      sink.add(chunk);
    }
    sink.close();
    return digestSink.digest.toString();
  }
}

class _DigestSink implements Sink<Digest> {
  Digest? _digest;

  Digest get digest {
    final value = _digest;
    if (value == null) {
      throw StateError('The digest was never produced');
    }
    return value;
  }

  @override
  void add(Digest data) {
    _digest = data;
  }

  @override
  void close() {}
}
