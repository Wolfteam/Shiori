import 'dart:async';
import 'dart:io';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shiori/domain/services/network_service.dart';

const Duration _timeout = Duration(seconds: 5);
final List<InternetCheckOption> _address = [
  Uri.parse('https://8.8.8.8'), // Google
  Uri.parse('https://lenta.ru'),
  Uri.parse('https://www.gazeta.ru'),
].map((e) => InternetCheckOption(uri: e, timeout: _timeout)).toList();

class NetworkServiceImpl implements NetworkService {
  final InternetConnection _checker;

  NetworkServiceImpl() : _checker = InternetConnection.createInstance(checkInterval: _timeout, customCheckOptions: _address);

  @override
  Future<bool> isInternetAvailable() async {
    try {
      //we use this address since it should be available on most of the world (including china)
      const lookUpAddress = 'www.example.com';
      final result = await InternetAddress.lookup(lookUpAddress).timeout(_timeout);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      //ignore
    }
    return _checker.hasInternetAccess;
  }
}
