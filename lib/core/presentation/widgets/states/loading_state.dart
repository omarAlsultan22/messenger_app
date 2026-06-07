import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_colors.dart';


class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.white)),
    );
  }
}
