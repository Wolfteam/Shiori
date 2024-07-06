import 'dart:async';
import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shiori/domain/services/network_service.dart';

const Duration _timeout = Duration(seconds: 5);
final List<AddressCheckOptions> _address = [
  InternetAddress('8.8.8.8', type: InternetAddressType.IPv4), // Google
  InternetAddress('180.76.76.76', type: InternetAddressType.IPv4), // Baidu
  InternetAddress('2400:da00::6666', type: InternetAddressType.IPv6), // Baidu
].map((e) => AddressCheckOptions(address: e, timeout: _timeout)).toList();

class NetworkServiceImpl implements NetworkService {
  final InternetConnectionChecker _checker;

  NetworkServiceImpl()
      : _checker = InternetConnectionChecker.createInstance(
          checkTimeout: _timeout,
          addresses: [...InternetConnectionChecker.DEFAULT_ADDRESSES] + _address,
        );

  @override
  Future<bool> isInternetAvailable() async {
    try {
      //we use this address since it should be available on most of the world (including china)
      const lookUpAddress = 'www.example.com';
      final result = await InternetAddress.lookup(lookUpAddress).timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      //ignore
    }
    return _checker.hasConnection;
  }
}
