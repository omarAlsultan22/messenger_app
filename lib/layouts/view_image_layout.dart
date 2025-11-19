import 'package:flutter/material.dart';

class ViewImageLayout extends StatelessWidget {
  final String userImage;

  const ViewImageLayout({required this.userImage, super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.network(userImage),
      ),
    );
  }
}
