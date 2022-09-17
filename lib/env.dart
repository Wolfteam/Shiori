import 'dart:convert';

import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify()
abstract class Env {
  static const androidAppCenterKey = _Env.androidAppCenterKey;
  static const androidPurchasesKey = _Env.androidPurchasesKey;

  static const apiBaseUrl = _Env.apiBaseUrl;
  static const assetsBaseUrl = _Env.assetsBaseUrl;
  static const commonHeaderName = _Env.commonHeaderName;
  static const apiHeaderName = _Env.apiHeaderName;
  static const apiHeaderValue = _Env.apiHeaderValue;

  static final publicKey = utf8.encode(utf8.decode(base64.decode(_Env.publicKey)));
  static final privateKey = utf8.encode(utf8.decode(base64.decode(_Env.privateKey)));
}
