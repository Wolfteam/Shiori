import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify()
abstract class Env {
  static const androidAppCenterKey = _Env.androidAppCenterKey;
  static const iosAppCenterKey = _Env.iosAppCenterKey;
  static const androidPurchasesKey = _Env.androidPurchasesKey;

  static const apiBaseUrl = _Env.apiBaseUrl;
  static const assetsBaseUrl = _Env.assetsBaseUrl;
  static const commonHeaderName = _Env.commonHeaderName;
  static const apiHeaderName = _Env.apiHeaderName;
  static const apiHeaderValue = _Env.apiHeaderValue;

  static const publicKey = _Env.publicKey;
  static const privateKey = _Env.privateKey;
}
