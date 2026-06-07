import 'package:flutter/cupertino.dart';
import 'package:test_app/core/constants/app_colors.dart';


class BuildAppIcon extends StatelessWidget {
  const BuildAppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.chat_bubble_2_fill,
      size: 150,
      color: AppColors.white,
    );
  }
}
