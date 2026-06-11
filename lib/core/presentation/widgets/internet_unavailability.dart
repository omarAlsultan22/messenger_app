import 'package:flutter/material.dart';
import '../../constants/app_spaces.dart';
import '../../data/network/connectivity_service.dart';


class InternetUnavailability extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final ConnectivityService? connectivityService;

  const InternetUnavailability({
    super.key,
    this.onRetry,
    this.message,
    this.connectivityService
  });

  @override
  Widget build(BuildContext context) {
    Future<void> isInternetAvailable() async {
      final isConnected = await connectivityService!.checkInternetConnection();
      if (isConnected) {
        onRetry?.call();
      }
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 80.0,
            color: Color(0xFF757575),
          ),
          const SizedBox(height: 20.0),
          Text(message!,
              style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242)
              )
          ),
          AppSpaces.vertical_30,
          ElevatedButton(
            onPressed: isInternetAvailable,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
