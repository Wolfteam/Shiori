import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

class Env {
  static const int minResourceVersion = 44;

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
