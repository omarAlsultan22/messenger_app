import '../../../../../core/presentation/widgets/build_snack_bar.dart';
import 'package:test_app/features/auth/constants/auth_strings.dart';
import '../../../../../core/data/models/message_result_model.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';


class ForgetPasswordLayout extends StatefulWidget {
  final void Function({
  required String userEmail,
  }) onUpdate;
  final MessageResult messageResult;
  const ForgetPasswordLayout({
    super.key,
    required this.onUpdate,
    required this.messageResult
  });

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgetPasswordLayout> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ForgetPasswordLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageResult.message != null) {
      _showMessageResult(widget.messageResult);
      if (widget.messageResult.error == null) {
        Navigator.pop(context);
      }
      setState(() {});
    }
  }

  void _showMessageResult(MessageResult messageResult) {
    BuildSnackBar.show(
        context: context,
        message: messageResult.message!,
        backgroundColor: messageResult.color!
    );
    Navigator.pop(context);
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    widget.onUpdate(userEmail: email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Forget Password'),
            backgroundColor: AppColors.transparent
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: _buildBackgroundDecoration(),
            child: Center(
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: AuthStrings.emailLabel,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _sendResetEmail,
                    child: const Text('Send reset link'),
                  ),
                ],
              ),
            )
        )
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(AuthStrings.backgroundCover),
        fit: BoxFit.cover,
      ),
    );
  }
}

