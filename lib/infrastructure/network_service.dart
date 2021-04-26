import 'package:genshindb/domain/services/network_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkServiceImpl implements NetworkService {
  @override
  Future<bool> isInternetAvailable() {
    final checker = InternetConnectionChecker();
    return checker.hasConnection;
  }
}
