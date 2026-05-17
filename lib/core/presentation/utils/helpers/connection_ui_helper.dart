import 'dart:ui';
import '../../../constants/app_colors.dart';
import '../../../data/models/message_result_model.dart';


class ConnectionUIHelper {
  const ConnectionUIHelper._();

  static Color getStatusColor(bool isConnected) {
    return isConnected ? AppColors.green_800 : AppColors.red_800;
  }

  static String getStatusMessage(bool isConnected) {
    return isConnected ? 'Updated Successfully' : 'No Internet Connection';
  }

  static MessageResult getStatus(bool isConnected) {
    return MessageResult(
        isLoading: false,
        color: getStatusColor(isConnected),
        message: getStatusMessage(isConnected)
    );
  }
}
