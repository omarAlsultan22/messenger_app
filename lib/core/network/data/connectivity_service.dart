import 'dart:io';
import '../domain/i_connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityService implements IConnectivityService {
  final Connectivity _connectivity;
  final Future<List<InternetAddress>> Function(String host) _lookup;

  ConnectivityService({
    Connectivity? connectivity,
    Future<List<InternetAddress>> Function(String host)? lookup,
  })  : _connectivity = connectivity ?? Connectivity(),
        _lookup = lookup ?? InternetAddress.lookup;

  @override
  Future<bool> checkInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) return false;

      final result = await _lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}