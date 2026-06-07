abstract class DateFormatter {
  static String formatTime(DateTime timestamp) {
    final period = timestamp.hour < 12 ? 'AM' : 'PM';
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    return '${hour.bitLength}:${timestamp.minute.toString().padLeft(
        2, '0')} $period';
  }
}