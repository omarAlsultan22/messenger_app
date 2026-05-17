import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool _showOnlineMessage = false;
  String _connectionType = 'Unknown';
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _onlineMessageTimer;
  Timer? _checkTimer;

  bool get isConnected => _isConnected;

  bool get showOnlineMessage => _showOnlineMessage;

  String get connectionType => _connectionType;

  final Connectivity _connectivity = Connectivity();

  static const _none = 'None';

  ConnectivityProvider() {
    _initConnectivity();
    _startPeriodicCheck();
  }

  void _initConnectivity() async {
    try {
      // الحالة الأولية
      await _checkConnectivity();

      // الاستماع للتغيرات
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          print('Connectivity error: $error');
          _updateConnectionStatus([ConnectivityResult.none]);
        },
      );
    } catch (e) {
      print('Error initializing connectivity: $e');
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  void _startPeriodicCheck() {
    // فحص دوري كل 10 ثوان للتأكد من الاتصال
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkConnectivity();
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool newStatus = _hasConnection(results);
    final String newType = _getConnectionType(results);

    print('Connection status: $newStatus, Type: $newType');

    if (_isConnected != newStatus || _connectionType != newType) {
      final bool wasConnected = _isConnected;
      _isConnected = newStatus;
      _connectionType = newType;

      if (wasConnected && !newStatus) {
        // فقدان الاتصال
        print('Connection lost');
        _hideOnlineMessage();

        // إشعار بفقدان الاتصال
        _notifyWithDelay();
      } else if (!wasConnected && newStatus) {
        // استعادة الاتصال
        print('Connection restored');
        _showTemporaryOnlineMessage();

        // إشعار فوري
        notifyListeners();

        // محاولة إعادة تحميل البيانات
        _tryReloadData();
      } else {
        // تغيير في نوع الاتصال فقط
        notifyListeners();
      }
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    for (var result in results) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.other) {
        return true;
      }
    }
    return false;
  }

  String _getConnectionType(List<ConnectivityResult> results) {
    if (results.isEmpty) return _none;

    if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (results.contains(ConnectivityResult.mobile)) return 'Mobile Data';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    if (results.contains(ConnectivityResult.other)) return 'Other';

    return _none;
  }

  void _showTemporaryOnlineMessage() {
    _onlineMessageTimer?.cancel();
    _showOnlineMessage = true;
    notifyListeners();

    _onlineMessageTimer = Timer(const Duration(seconds: 5), () {
      _showOnlineMessage = false;
      notifyListeners();
    });
  }

  void _hideOnlineMessage() {
    _onlineMessageTimer?.cancel();
    _showOnlineMessage = false;
  }

  void _notifyWithDelay() {
    // تأخير صغير للتأكد من أن UI قد استقبل التحديث
    Future.delayed(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
  }

  void _tryReloadData() {
    // محاولة إعادة تحميل البيانات بعد استعادة الاتصال
    Future.delayed(const Duration(seconds: 2), () {
      // يمكنك هنا استدعاء دالة لإعادة تحميل البيانات
      print('Attempting to reload data...');

      // مثال: إذا كان لديك Cubit أو Provider للبيانات
      // context.read<TodaysNewsCubit>().loadData();
    });
  }

  Future<void> refreshConnection() async {
    // تحديث يدوي لحالة الاتصال
    await _checkConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _onlineMessageTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }
}
