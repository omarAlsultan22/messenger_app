class ValidateInput {
  static String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter Your name';
    }
    return null;
  }
}