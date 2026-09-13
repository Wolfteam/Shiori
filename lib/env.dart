import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

class Env {
  static const int minResourceVersion = 44;

  /// Max number of queued telemetry entries. Binds in the normal case.
  static const int maxTelemetryEntries = 5000;

  /// Max total bytes of queued telemetry. Binds in the pathological case
  /// (a run of large stack traces), where the count cap alone would allow
  /// ~80 MB resident in a plain Hive box.
  static const int maxTelemetryTotalBytes = 8 * 1024 * 1024;

  /// Each telemetry message is truncated to this at save time, so no single
  /// entry can ever exceed the payload budget and stall the queue.
  static const int maxTelemetryMessageBytes = 16 * 1024;

  /// Budget for one upload request. Targets ~50% of the 256 KB SQS ceiling because the
  /// API Gateway integration URL-encodes the body (`$util.urlEncode($input.json('$'))`),
  /// which measurably inflates it beyond what a naive pre-encoding estimate assumes.
  static const int maxTelemetryPayloadBytes = 64 * 1024;

  /// Caps how many chunks are uploaded per app launch, bounding splash-screen latency on a
  /// slow connection. Any remainder stays queued and drains on the next launch, the same
  /// designed behaviour as a failed chunk.
  static const int maxTelemetryChunksPerRun = 4;

  /// The active log file rotates at this size. Disk is hard-bounded at 2x.
  static const int maxLogFileSizeInBytes = 2 * 1024 * 1024;

  /// Log files older than this are deleted at startup.
  static const int maxLogFileAgeInDays = 14;

  static const String androidPurchasesKey = CommonEnv.androidPurchasesKey;

  static const String iosPurchasesKey = CommonEnv.iosPurchasesKey;

  static const String commonHeaderName = CommonEnv.commonHeaderName;
  static const String apiHeaderName = CommonEnv.apiHeaderName;

  static const String publicKey = CommonEnv.publicKey;
  static const String privateKey = CommonEnv.privateKey;
  static const String letsEncryptKey = CommonEnv.letsEncryptKey;

  static const bool isReleaseMode = kReleaseMode;

  static const String apiBaseUrl = isReleaseMode ? ProdEnv.apiBaseUrl : DevEnv.apiBaseUrl;

  static const String assetsBaseUrl = isReleaseMode ? ProdEnv.assetsBaseUrl : DevEnv.assetsBaseUrl;

  static const String apiHeaderValue = isReleaseMode ? ProdEnv.apiHeaderValue : DevEnv.apiHeaderValue;
}

@Envied(path: '.env.dev', name: 'DevEnv')
abstract class DevEnv {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _DevEnv.apiBaseUrl;

  @EnviedField(varName: 'ASSETS_BASE_URL')
  static const String assetsBaseUrl = _DevEnv.assetsBaseUrl;

  @EnviedField(varName: 'API_HEADER_VALUE')
  static const String apiHeaderValue = _DevEnv.apiHeaderValue;
}

@Envied(path: '.env.prod', name: 'ProdEnv')
abstract class ProdEnv {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _ProdEnv.apiBaseUrl;

  @EnviedField(varName: 'ASSETS_BASE_URL')
  static const String assetsBaseUrl = _ProdEnv.assetsBaseUrl;

  @EnviedField(varName: 'API_HEADER_VALUE')
  static const String apiHeaderValue = _ProdEnv.apiHeaderValue;
}

@Envied(path: '.env.common', name: 'CommonEnv')
abstract class CommonEnv {
  @EnviedField(varName: 'ANDROID_PURCHASES_KEY')
  static const String androidPurchasesKey = _CommonEnv.androidPurchasesKey;
  @EnviedField(varName: 'IOS_PURCHASES_KEY')
  static const String iosPurchasesKey = _CommonEnv.iosPurchasesKey;

  @EnviedField(varName: 'COMMON_HEADER_NAME')
  static const String commonHeaderName = _CommonEnv.commonHeaderName;
  @EnviedField(varName: 'API_HEADER_NAME')
  static const String apiHeaderName = _CommonEnv.apiHeaderName;

  @EnviedField(varName: 'PUBLIC_KEY')
  static const String publicKey = _CommonEnv.publicKey;
  @EnviedField(varName: 'PRIVATE_KEY')
  static const String privateKey = _CommonEnv.privateKey;
  @EnviedField(varName: 'LETS_ENCRYPT_KEY')
  static const String letsEncryptKey = _CommonEnv.letsEncryptKey;
}
