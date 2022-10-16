import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

class Env {
  static const androidAppCenterKey = CommonEnv.androidAppCenterKey;
  static const androidPurchasesKey = CommonEnv.androidPurchasesKey;

  static const commonHeaderName = CommonEnv.commonHeaderName;
  static const apiHeaderName = CommonEnv.apiHeaderName;

  static const publicKey = CommonEnv.publicKey;
  static const privateKey = CommonEnv.privateKey;
  static const letsEncryptKey = CommonEnv.letsEncryptKey;

  static const bool isReleaseMode = kReleaseMode;

  static const String apiBaseUrl = isReleaseMode ? ProdEnv.apiBaseUrl : DevEnv.apiBaseUrl;

  static const String assetsBaseUrl = isReleaseMode ? ProdEnv.assetsBaseUrl : DevEnv.assetsBaseUrl;

  static const String apiHeaderValue = isReleaseMode ? ProdEnv.apiHeaderValue : DevEnv.apiHeaderValue;
}

@Envify(path: '.env.dev')
abstract class DevEnv {
  static const apiBaseUrl = _DevEnv.apiBaseUrl;
  static const assetsBaseUrl = _DevEnv.assetsBaseUrl;
  static const apiHeaderValue = _DevEnv.apiHeaderValue;
}

@Envify(path: '.env.prod')
abstract class ProdEnv {
  static const apiBaseUrl = _ProdEnv.apiBaseUrl;
  static const assetsBaseUrl = _ProdEnv.assetsBaseUrl;
  static const apiHeaderValue = _ProdEnv.apiHeaderValue;
}

@Envify(path: '.env.common')
abstract class CommonEnv {
  static const androidAppCenterKey = _CommonEnv.androidAppCenterKey;
  static const androidPurchasesKey = _CommonEnv.androidPurchasesKey;

  static const commonHeaderName = _CommonEnv.commonHeaderName;
  static const apiHeaderName = _CommonEnv.apiHeaderName;

  static const publicKey = _CommonEnv.publicKey;
  static const privateKey = _CommonEnv.privateKey;
  static const letsEncryptKey = _CommonEnv.letsEncryptKey;
}
