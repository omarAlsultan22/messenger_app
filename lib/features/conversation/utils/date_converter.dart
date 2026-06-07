import 'package:intl/intl.dart';


class DateConverter {
  DateConverter._();

  static String getDateHeader(DateTime messageDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
    } else if (now.difference(messageDateOnly).inDays < 7) {
      return DateFormat('EEEE').format(messageDate); // Monday, Tuesday, etc.
    } else {
      return DateFormat('MMMM yyyy').format(messageDate); // March 2023
    }
  }
}