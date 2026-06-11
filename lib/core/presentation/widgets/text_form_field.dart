import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_borders.dart';


class BuildInputField extends StatelessWidget {
  bool enabled;
  bool obscureText;
  final String? hintText;
  final String? labelText;
  final Widget? suffixIcon;
  final double borderRadius;
  final Widget? prefixIcon;
  final InputDecoration? decoration;
  final List<String>? autofillHints;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String? Function(dynamic value)? validator;

  BuildInputField({
    super.key,
    this.labelText,
    this.suffixIcon,
    this.autofillHints,
    this.keyboardType,
    this.hintText,
    this.prefixIcon,
    this.decoration,
    this.enabled = true,
    this.obscureText = false,
    this.borderRadius = 50.0,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      cursorRadius: const Radius.circular(100.0),
      validator: validator,
      enabled: enabled,
      decoration: decoration ?? InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          borderSide: BorderSide(
            color: Theme
                .of(context)
                .brightness == Brightness.light
                ? AppColors.black
                : AppColors.white,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppBorders.borderRadius_50,
          borderSide: BorderSide(color: AppColors.bluePrimaryValue),
        ),
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
    );
  }
}