import 'package:flutter/material.dart';
import 'package:devlearning_indonesia/auth/confirmation_screen.dart';
import 'package:devlearning_indonesia/database/database_helper.dart';
import 'package:devlearning_indonesia/models/user.dart';
import 'package:devlearning_indonesia/services/validation.dart';
import 'package:sqflite/sqflite.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  late Future<List<User>> _usersFuture;
  bool _obscurePassword = true;
  bool _isSaving = false;
  int? _editingUserId;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
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
            tooltip: 'Muat ulang peserta',
            onPressed: _reloadUsers,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadUsers,
        child: SingleChildScrollView(
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
              const SizedBox(height: 28),
              const Text(
                'Peserta terdaftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _buildUsersList(),
            ],
          ),
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
  Future<List<User>> _loadUsers() => DatabaseHelper.instance.getUsers();

  Future<void> _reloadUsers() async {
    if (!mounted) return;

    final usersFuture = _loadUsers();
    setState(() {
      _usersFuture = usersFuture;
    });
    await usersFuture;
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
    final editingUserId = _editingUserId;

    try {
      if (editingUserId == null) {
        await DatabaseHelper.instance.insertUser(
          User(
            name: name,
            email: email,
            phone: phone,
            password: password,
            city: city,
          ),
        );
      } else {
        await DatabaseHelper.instance.updateUser(
          id: editingUserId,
          name: name,
          email: email,
          phone: phone,
          city: city,
          password: password,
        );
      }
      _clearForm();
      await _reloadUsers();
      if (!mounted) return;

      if (editingUserId != null) {
        _showMessage('Data peserta berhasil diperbarui');
        if (mounted) Navigator.pop(context);
        return;
      }

      await _showRegistrationDetail(name: name, city: city);
      if (!mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(name: name, city: city),
        ),
      );
    } on DatabaseException catch (error) {
      if (mounted) {
        final errorMessage = error.toString().toUpperCase();
        final message = errorMessage.contains('UNIQUE')
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

  void _startEditing(User user) {
    _editingUserId = user.id;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _passwordController.clear();
    _cityController.text = user.city;
    _obscurePassword = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit peserta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Form(
            key: _editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  'Password baru (opsional)',
                  Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    onPressed: () => setState(() {
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
              ],
            ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isSaving
                          ? null
                          : () => _saveUser(formKey: _editFormKey),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) {
        _clearForm();
      }
    });
  }

  void _clearForm() {
    setState(() {
      _editingUserId = null;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _cityController.clear();
    });
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus peserta?'),
        content: Text('Data ${user.name} akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || user.id == null) return;

    try {
      await DatabaseHelper.instance.deleteUser(user.id!);
      if (_editingUserId == user.id) _clearForm();
      await _reloadUsers();
      if (mounted) _showMessage('Data peserta berhasil dihapus');
    } on DatabaseException catch (error) {
      if (mounted) _showMessage('Gagal menghapus data: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  Widget _buildUsersList() {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return const Text('Gagal memuat data peserta.');
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Text(
            'Belum ada peserta terdaftar.',
            style: TextStyle(color: Color(0xFF68736F)),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline_rounded),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${user.email}\n${user.phone} - ${user.city}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit peserta',
                      onPressed: () => _startEditing(user),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Hapus peserta',
                      onPressed: () => _deleteUser(user),
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
