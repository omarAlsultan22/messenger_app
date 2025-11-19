import 'package:intl/intl.dart';


String date({
  required DateTime messageDate,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  String header;

  if (messageDate == today) {
    header = 'Today';
  } else if (messageDate == yesterday) {
    header = 'Yesterday';
  } else if (now
      .difference(messageDate)
      .inDays < 7) {
    header = 'Last week';
  } else {
    header = DateFormat('MMMM yyyy').format(messageDate); // "March 2023"
  }
  return header;
}