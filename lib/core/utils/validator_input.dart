String? validator(String? value, String? item) {
  if (value!.isEmpty) {
    return 'Please Enter Your $item';
  }
  return null;
}