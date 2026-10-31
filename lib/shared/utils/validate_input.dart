class ValidateInput {
  static String? validator({
    required String? value,
    required String text
  }) {
    if (value == null || value.isEmpty) {
      return 'Please Enter Your $text';
    }
    return null;
  }
}