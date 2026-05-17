import 'package:flutter/material.dart';
import '../../../../core/components/components.dart';


class SearchField extends StatelessWidget {
  final TextEditingController controller;

  static const double _paddingValue = 5.0;
  static const double _borderRadiusValue = 50.0;

  static final BorderRadius _borderRadius =
  BorderRadius.circular(_borderRadiusValue);

  const SearchField({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_paddingValue),
      child: buildInputField(
        context: context,
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Search for friends...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: _borderRadius,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: _borderRadius,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}