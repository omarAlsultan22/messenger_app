import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../utils/validate/form_validation.dart';
import '../../utils/validate/email_validation.dart';
import '../../../../../core/constants/app_spaces.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_paddings.dart';
import '../../../../../core/presentation/utils/ui_utils.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:test_app/features/auth/constants/auth_strings.dart';
import '../../../../../core/presentation/widgets/text_form_field.dart';


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
  State<ForgetPasswordLayout> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgetPasswordLayout> with AuthMixin<ForgetPasswordLayout> {

  bool _isPressed = true;

  final _formKey = GlobalKey<FormState>();

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
    handleMessageResult(
      messageResult: widget.messageResult,
      onNavigate: () => Navigator.pop(context),
    );
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
            decoration: buildBackgroundDecoration(),
            child: Padding(
                padding: AppPaddings.xLarge,
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BuildInputField(
                          controller: _emailController,
                          labelText: AuthStrings.emailLabel,
                          hintText: AuthStrings.emailHint,
                          prefixIcon: const Icon(
                              Icons.email, color: AppColors.white),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: (value) =>
                              EmailValidation.validator(value),
                        ),
                        AppSpaces.vertical_24,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: buttonStyle(),
                            onPressed: widget.messageResult.isLoading ? () =>
                                _submitForm() : null,
                            child: buildButtonContent(
                                text: 'Send reset link',
                                isLoading: widget.messageResult.isLoading
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            )
        )
    );
  }

  void _updateLockButton(bool value) {
    setState(() => _isPressed = value);
  }

  Future<void> _submitForm() async {
    if (FormValidation.validator(_formKey)) {
      _updateLockButton(false);
      UiUtils.hideKeyboard(context);
      final email = _emailController.text.trim();
      widget.onUpdate(
        userEmail: email,
      );
      _updateLockButton(true);
    }
  }
}

