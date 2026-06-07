import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_colors.dart';


abstract class ShowToast {
  static void show({
    required String msg,
    int? timeInSecForIosWeb,
    Toast? toastLength,
    ToastGravity? gravity,
    Color? backgroundColor,
    double? fontSize,
    Color? textColor
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: AppColors.white,
      fontSize: AppSizes.sm,
    );
  }
}