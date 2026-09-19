import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/user.dart';
import '../services/preference_handler.dart';
import 'confirmation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.user});

  final User? user;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSaving = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _passwordController.text = user.password;
      _cityController.text = user.city;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final user = User(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      city: _cityController.text.trim(),
    );

    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updateUser(
          User(
            id: widget.user!.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            password: user.password,
            city: user.city,
            photoPath: widget.user!.photoPath,
          ),
        );
        await PreferenceHandler.setCurrentEmail(user.email);
      } else {
        await DatabaseHelper.instance.insertUser(user);
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (_isEditing) {
        Navigator.of(context).pop(true);
      } else {
        await _showSummary(user);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pendaftaran gagal: $error')),
      );
    }
  }

  Future<void> _showSummary(User user) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ringkasan Pendaftaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(label: 'Nama', value: user.name),
              _SummaryRow(label: 'Email', value: user.email),
              _SummaryRow(
                label: 'Nomor HP',
                value: user.phone.isEmpty ? '-' : user.phone,
              ),
              _SummaryRow(label: 'Kota', value: user.city),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ConfirmationScreen(
                      name: user.name,
                      city: user.city,
                    ),
                  ),
                );
              },
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Peserta' : 'Pendaftaran Peserta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Lengkapi data diri Anda',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Data akan disimpan di perangkat untuk daftar peserta.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            _label('Nama Lengkap'),
            _field(
              controller: _nameController,
              hint: 'Masukkan nama lengkap',
              icon: Icons.person_outline,
              validator: (value) => _required(value, 'Nama lengkap'),
            ),
            const SizedBox(height: 14),
            _label('Email'),
            _field(
              controller: _emailController,
              hint: 'nama@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final requiredError = _required(value, 'Email');
                if (requiredError != null) return requiredError;
                if (!value!.contains('@')) return 'Email harus mengandung @';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _label('Nomor HP (opsional)'),
            _field(
              controller: _phoneController,
              hint: '08xxxxxxxxxx',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _label('Password'),
            _field(
              controller: _passwordController,
              hint: 'Minimal 6 karakter',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              validator: (value) {
                final requiredError = _required(value, 'Password');
                if (requiredError != null) return requiredError;
                if (value!.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _label('Asal Kota'),
            _field(
              controller: _cityController,
              hint: 'Contoh: Bandung',
              icon: Icons.location_on_outlined,
              validator: (value) => _required(value, 'Asal kota'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _register,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1),
                label: Text(
                  _isSaving
                      ? 'Menyimpan...'
                      : (_isEditing ? 'Simpan Perubahan' : 'Daftar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}