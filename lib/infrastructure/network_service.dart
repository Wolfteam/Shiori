import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:genshindb/domain/services/network_service.dart';

class NetworkServiceImpl implements NetworkService {
  @override
  Future<bool> isInternetAvailable() {
    final checker = DataConnectionChecker();
    return checker.hasConnection;
  }
}
