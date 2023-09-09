import 'dart:async';
import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shiori/domain/services/network_service.dart';

class NetworkServiceImpl implements NetworkService {
  late final InternetConnectionChecker _checker;

  @override
  void init() {
    const timeout = Duration(seconds: 5);
    final address = [
      InternetAddress('8.8.8.8', type: InternetAddressType.IPv4), // Google
      InternetAddress('180.76.76.76', type: InternetAddressType.IPv4), // Baidu
      InternetAddress('2400:da00::6666', type: InternetAddressType.IPv6), // Baidu
    ].map((e) => AddressCheckOptions(address: e, timeout: timeout)).toList();

    _checker = InternetConnectionChecker.createInstance(
      checkTimeout: timeout,
      addresses: [...InternetConnectionChecker.DEFAULT_ADDRESSES] + address,
    );
  }

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
