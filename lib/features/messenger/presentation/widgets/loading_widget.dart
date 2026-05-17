import 'package:flutter/material.dart';


class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({
    this.message = 'Loading chats...',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16).,
          Text(
            message,
            style: const TextStyle(
              fontSize: 16.,
              color: Colors.grey,.
            ),
          ),
        ],
      ),
    );
  }
}