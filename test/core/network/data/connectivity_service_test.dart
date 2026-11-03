import 'dart:io';
import '../../../fakes/fake_connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:test_app/core/network/data/connectivity_service.dart';


void main() {
  group('ConnectivityService - Success cases', () {
    test('returns true when wifi is on and DNS lookup succeeds', () async {
      final service = ConnectivityService(
        connectivity: FakeConnectivity(ConnectivityResult.wifi),
        lookup: (_) async =>
        [
          InternetAddress('142.250.200.46', type: InternetAddressType.IPv4),
        ],
      );

      expect(await service.checkInternetConnection(), true);
    });

    test('returns true when mobile data is on and DNS succeeds', () async {
      final service = ConnectivityService(
        connectivity: FakeConnectivity(ConnectivityResult.mobile),
        lookup: (_) async =>
        [
          InternetAddress('142.250.200.46', type: InternetAddressType.IPv4),
        ],
      );

      expect(await service.checkInternetConnection(), true);
    });
  });

  group('ConnectivityService - Failure cases', () {
    test('returns false when connectivity is none', () async {
      final service = ConnectivityService(
        connectivity: FakeConnectivity(ConnectivityResult.none),
        lookup: (_) async => [],
      );

      expect(await service.checkInternetConnection(), false);
    });

    test('returns false when DNS lookup returns empty', () async {
      final service = ConnectivityService(
        connectivity: FakeConnectivity(ConnectivityResult.wifi),
        lookup: (_) async => [],
      );

      expect(await service.checkInternetConnection(), false);
    });

    test('returns false when DNS lookup throws', () async {
      final service = ConnectivityService(
        connectivity: FakeConnectivity(ConnectivityResult.wifi),
        lookup: (_) async => throw const SocketException('No internet'),
      );

      expect(await service.checkInternetConnection(), false);
    });
  });
}