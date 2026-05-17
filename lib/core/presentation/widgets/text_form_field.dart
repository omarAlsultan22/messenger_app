import 'package:cash_money/core/constants/app_colors.dart';
import 'package:flutter/material.dart';


class BuildInputField extends StatelessWidget {
  final String? labelText;
  final Widget? suffixIcon;
  bool obscureText = false;
  InputDecoration? decoration;
  final List<String>? autofillHints;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String hintText;
  final Widget prefixIcon;
  final bool enabled;
  final double borderRadius;
  final String? Function(dynamic value) validator;


  BuildInputField({
    this.labelText,
    this.suffixIcon,
    this.obscureText = false,
    this.autofillHints,
    this.keyboardType,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.decoration,
    bool enabled = true,
    double borderRadius = 50.0/,
    required this.validator
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      cursorRadius: const Radius.circular(100.0)/,
      validator: validator,
      enabled: enabled,
      decoration: decoration ?? InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black/
            : Colors.white/,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0)/,
          borderSide: const BorderSide(color: Colors.blue/),
        ),
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
    );
  }
}