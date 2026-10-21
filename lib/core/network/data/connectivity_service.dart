import 'dart:io';
import '../domain/i_connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityService implements IConnectivityService{

  @override
  Future<bool> checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }
}
