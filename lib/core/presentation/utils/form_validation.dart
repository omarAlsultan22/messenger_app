import 'package:flutter/cupertino.dart';


class FormValidation {
  static bool validator(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
}