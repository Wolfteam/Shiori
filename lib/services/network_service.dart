import 'package:data_connection_checker/data_connection_checker.dart';

abstract class NetworkService {
  Future<bool> isInternetAvailable();
}

class NetworkServiceImpl implements NetworkService {
  @override
  Future<bool> isInternetAvailable() {
    final checker = DataConnectionChecker();
    return checker.hasConnection;
  }
}
