import 'package:intl/intl.dart';


class DateConverter {
  DateConverter._();

  static String getDateHeader(
      DateTime messageDate, {
        DateTime? now,
      }) {
    final currentNow = now ?? DateTime.now();
    final today = DateTime(currentNow.year, currentNow.month, currentNow.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final messageDateOnly = DateTime(
        messageDate.year,
        messageDate.month,
        messageDate.day
    );

    if (messageDateOnly == today) {
      return 'Today';
    } else if (messageDateOnly == yesterday) {
      return 'Yesterday';
    } else if (currentNow.difference(messageDateOnly).inDays < 7) {
      return DateFormat('EEEE').format(messageDate);
    } else {
      return DateFormat('MMMM yyyy').format(messageDate);
    }
  }
}