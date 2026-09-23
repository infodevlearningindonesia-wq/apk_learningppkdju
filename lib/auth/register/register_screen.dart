import 'package:flutter/material.dart';
import 'package:devlearning_indonesia/about/about_screen.dart';
import 'package:devlearning_indonesia/auth/confirmation_screen.dart';
import 'package:devlearning_indonesia/database/database_helper.dart';
import 'package:devlearning_indonesia/models/user.dart';
import 'package:devlearning_indonesia/services/validation.dart';
import 'package:sqflite/sqflite.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.isAdminCreate = false});

  /// Hanya panel admin yang boleh membuat akun dengan role selain peserta.
  final bool isAdminCreate;

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
  UserRole _selectedRole = UserRole.peserta;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        actions: [
          IconButton(
            tooltip: 'Tentang aplikasi',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Buat akun baru',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Data pendaftaran disimpan di perangkat.',
                style: TextStyle(color: Color(0xFF68736F)),
              ),
              const SizedBox(height: 24),
              _field(
                _nameController,
                'Nama',
                Icons.person_outline_rounded,
                validator: (value) => _required(value, 'Nama'),
              ),
              const SizedBox(height: 12),
              _field(
                _emailController,
                'Email',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              _field(
                _phoneController,
                'Nomor HP',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor HP wajib diisi';
                  }
                  if (value.trim().length < 10) {
                    return 'Nomor HP minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _field(
                _passwordController,
                'Password',
                Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (value.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Tampilkan password'
                      : 'Sembunyikan password',
                  onPressed: () =>
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _field(
                _cityController,
                'Asal Kota',
                Icons.location_city_outlined,
                validator: (value) => _required(value, 'Asal kota'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: widget.isAdminCreate ? _selectedRole : UserRole.peserta,
                decoration: InputDecoration(
                  labelText: 'Role akun',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: const OutlineInputBorder(),
                  helperText: widget.isAdminCreate
                      ? null
                      : 'Role default untuk user baru adalah Peserta',
                ),
                items: UserRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.label),
                      ),
                    )
                    .toList(),
                onChanged: widget.isAdminCreate
                    ? (role) {
                        if (role != null) setState(() => _selectedRole = role);
                      }
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _saveUser(formKey: _formKey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF126B5B),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Daftar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
          ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF126B5B)),
        ),
      ),
    );
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty ? '$label wajib diisi' : null;
  }
  Future<void> _saveUser({required GlobalKey<FormState> formKey}) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final city = _cityController.text.trim();

    try {
      await DatabaseHelper.instance.insertUser(
        User(
          name: name,
          email: email,
          phone: phone,
          password: password,
          city: city,
          role: widget.isAdminCreate ? _selectedRole : UserRole.peserta,
        ),
      );
      if (!mounted) return;

      if (widget.isAdminCreate) {
        Navigator.pop(context, true);
      } else {
        await _showRegistrationDetail(name: name, city: city);
        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmationScreen(name: name, city: city),
          ),
        );
      }
    } on DatabaseException catch (error) {
      if (mounted) {
        final errorMessage = error.toString().toUpperCase();
        final message = errorMessage.contains('USERS.ROLE')
          ? 'Admin hanya boleh satu akun'
          : errorMessage.contains('UNIQUE')
            ? 'Email sudah terdaftar'
            : 'Gagal menyimpan data: ${error.toString()}';
          _showMessage(message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showRegistrationDetail({
    required String name,
    required String city,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Detail pendaftaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nama: $name'),
          const SizedBox(height: 8),
          Text('Asal kota: $city'),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Lanjutkan'),
        ),
      ],
    ),
  );
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
