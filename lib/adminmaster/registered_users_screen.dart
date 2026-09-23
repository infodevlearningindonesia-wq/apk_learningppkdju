import 'package:flutter/material.dart';
import 'package:devlearning_indonesia/auth/register/register_screen.dart';
import 'package:devlearning_indonesia/database/database_helper.dart';
import 'package:devlearning_indonesia/models/user.dart';
import 'package:sqflite/sqflite.dart';

class RegisteredUsersScreen extends StatefulWidget {
  const RegisteredUsersScreen({super.key});

  @override
  State<RegisteredUsersScreen> createState() => _RegisteredUsersScreenState();
}

class _RegisteredUsersScreenState extends State<RegisteredUsersScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseHelper.instance.getUsers();
  }

  Future<void> _reload() async {
    setState(() {
      _usersFuture = DatabaseHelper.instance.getUsers();
    });
    await _usersFuture;
  }

  Future<void> _editUser(User user) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: user.name);
    final email = TextEditingController(text: user.email);
    final phone = TextEditingController(text: user.phone);
    final city = TextEditingController(text: user.city);
    final password = TextEditingController();
    var role = user.role;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Edit akun', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  _editField(name, 'Nama', Icons.person_outline, requiredField: true),
                  _editField(email, 'Email', Icons.email_outlined, requiredField: true),
                  _editField(phone, 'Nomor HP', Icons.phone_outlined, requiredField: true),
                  _editField(city, 'Asal Kota', Icons.location_city_outlined, requiredField: true),
                  _editField(password, 'Password baru (opsional)', Icons.lock_outline),
                  DropdownButtonFormField<UserRole>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_outlined)),
                    items: UserRole.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => role = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false) || user.id == null) return;
                      try {
                        await DatabaseHelper.instance.updateUser(
                          id: user.id!,
                          name: name.text,
                          email: email.text,
                          phone: phone.text,
                          city: city.text,
                          password: password.text,
                          role: role,
                        );
                        if (context.mounted) Navigator.pop(context, true);
                      } on DatabaseException {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sudah digunakan atau admin sudah ada.')));
                        }
                      }
                    },
                    child: const Text('Simpan perubahan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    name.dispose();
    email.dispose();
    phone.dispose();
    city.dispose();
    password.dispose();
    if (saved == true) await _reload();
  }

  Widget _editField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: label.startsWith('Password'),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
        validator: requiredField && controller.text.trim().isEmpty
            ? (_) => '$label wajib diisi'
            : null,
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    if (user.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus akun?'),
        content: Text('Akun ${user.name} akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;
    await DatabaseHelper.instance.deleteUser(user.id!);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun terdaftar'),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Data akun gagal dimuat: ${snapshot.error}'),
            );
          }
          final users = snapshot.data ?? <User>[];
          if (users.isEmpty) {
            return const Center(child: Text('Belum ada akun terdaftar.'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${user.email}\n${user.city} - ${user.role.label}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () => _editUser(user), icon: const Icon(Icons.edit_outlined)),
                        IconButton(onPressed: () => _deleteUser(user), icon: const Icon(Icons.delete_outline)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterScreen(isAdminCreate: true),
          ),
        ).then((_) => _reload()),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah'),
      ),
    );
  }
}
