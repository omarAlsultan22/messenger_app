import 'package:connectivity_plus/connectivity_plus.dart';


class FakeConnectivity implements Connectivity {
  final ConnectivityResult result;

  FakeConnectivity(this.result);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [result];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([result]);
}