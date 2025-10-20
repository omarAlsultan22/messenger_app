import 'package:flutter/material.dart';


class DateHeaderWidget extends StatelessWidget {
  final String date;

  const DateHeaderWidget({
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.shade400,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade200
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade400,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}