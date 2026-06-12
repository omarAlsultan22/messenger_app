class ValidateInput {
  static String? validator({
    required String? value,
    required String item
  }) {
    if (value == null || value.isEmpty) {
      return 'Please Enter Your name';
    }
    return null;
  }
}