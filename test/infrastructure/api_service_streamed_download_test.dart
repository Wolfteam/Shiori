import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/infrastructure/infrastructure.dart';

import '../mocks.mocks.dart';

void main() {
  late Directory tempDir;
  late HttpServer server;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('shiori-dl');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await server.close(force: true);
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('downloadAssetStreamed writes the body to disk and reports progress', () async {
    //Large enough that the socket cannot deliver it in a single read, which is the point being proven
    const chunkSize = 1024 * 1024;
    const chunkCount = 8;
    final chunk = List<int>.filled(chunkSize, 7);
    server.listen((request) async {
      request.response.statusCode = 200;
      request.response.headers.contentLength = chunkSize * chunkCount;
      //Sent and flushed one chunk at a time so the client genuinely has to consume a stream
      for (int i = 0; i < chunkCount; i++) {
        request.response.add(chunk);
        await request.response.flush();
      }
      await request.response.close();
    });

    final service = ApiServiceImpl(MockLoggingService());
    final destPath = p.join(tempDir.path, 'sub', 'delta.zip');
    final progress = <int>[];
    int? reportedTotal;

    final written = await service.downloadAssetStreamed(
      'ignored',
      destPath,
      overrideUrl: 'http://${server.address.host}:${server.port}/delta.zip',
      onBytes: (received, total) {
        progress.add(received);
        reportedTotal = total;
      },
    );

    expect(written, chunkSize * chunkCount);
    expect(File(destPath).lengthSync(), chunkSize * chunkCount);
    expect(reportedTotal, chunkSize * chunkCount);
    //More than one callback with strictly increasing totals is what separates this from bodyBytes
    expect(progress.length, greaterThan(1));
    expect(progress, orderedEquals(<int>[...progress]..sort()));
    expect(progress.last, chunkSize * chunkCount);
  });

  test('downloadAssetStreamed returns null and writes nothing on a non-success status', () async {
    server.listen((request) async {
      request.response.statusCode = 404;
      await request.response.close();
    });

    final service = ApiServiceImpl(MockLoggingService());
    final destPath = p.join(tempDir.path, 'delta.zip');

    final written = await service.downloadAssetStreamed(
      'ignored',
      destPath,
      overrideUrl: 'http://${server.address.host}:${server.port}/delta.zip',
    );

    expect(written, isNull);
    expect(File(destPath).existsSync(), isFalse);
  });

  test('downloadAssetStreamed deletes a partial file when the connection drops', () async {
    final payload = List<int>.filled(1024 * 64, 7);
    server.listen((request) async {
      request.response.statusCode = 200;
      //Promise more than we send, then kill the socket: the client must not keep the partial file
      request.response.headers.contentLength = payload.length * 2;
      request.response.add(payload);
      await request.response.flush();
      await request.response.close().catchError((_) {});
      await server.close(force: true);
    });

    final service = ApiServiceImpl(MockLoggingService());
    final destPath = p.join(tempDir.path, 'delta.zip');

    final written = await service.downloadAssetStreamed(
      'ignored',
      destPath,
      overrideUrl: 'http://${server.address.host}:${server.port}/delta.zip',
    );

    expect(written, isNull);
    expect(File(destPath).existsSync(), isFalse);
  });
}
