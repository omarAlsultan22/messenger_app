import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:test_app/core/network/domain/i_connectivity_service.dart';


class ConnectivityService implements IConnectivityService {

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
    } catch(_) {
      return false;
    }
  }
}