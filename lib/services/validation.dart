String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email wajib diisi';

  final isValid = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  ).hasMatch(email);
  return isValid ? null : 'Masukkan email yang valid';
}