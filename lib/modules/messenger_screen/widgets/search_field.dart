import 'package:flutter/material.dart';
import '../../../shared/components/components.dart';


class SearchField extends StatelessWidget {
  final TextEditingController controller;

  const SearchField({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: buildInputField(
        context: context,
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Search for friends...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}