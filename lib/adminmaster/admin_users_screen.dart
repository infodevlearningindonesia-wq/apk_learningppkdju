part of devlearning_roles;

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<User>> _usersFuture;
  final _searchController = TextEditingController();
  String _roleFilter = 'Semua';
  DateTime _lastUpdated = DateTime.now();
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseHelper.instance.getUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    if (_isReloading || !mounted) return;
    _isReloading = true;
    setState(() {
      _usersFuture = DatabaseHelper.instance.getUsers();
      _lastUpdated = DateTime.now();
    });
    try {
      await _usersFuture;
    } finally {
      _isReloading = false;
    }
  }

  Future<void> _changeRole(User user, UserRole role) async {
    if (user.id == null || user.role == role) return;
    if (user.role == UserRole.admin || role == UserRole.admin) {
      _message('Akun admin tidak dapat diubah role-nya dari panel manajemen.');
      return;
    }
    final currentEmail = (PreferenceHandler.userEmail ?? '').trim().toLowerCase();
    if (AdminAccountPolicy.canManageAccount(
      currentEmail: currentEmail,
      targetEmail: user.email,
    ) == false) {
      _message('Akun admin yang sedang aktif tidak dapat diubah dari panel manajemen.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah role akun?'),
        content: Text('${user.name} akan menjadi ${role.label}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DatabaseHelper.instance.updateUser(
        id: user.id!,
        name: user.name,
        email: user.email,
        phone: user.phone,
        city: user.city,
        role: role,
      );
      if (!mounted) return;
      await _reload();
      if (mounted) _message('${user.name} sekarang menjadi ${role.label}.');
    } on DatabaseException {
      if (mounted) _message('Admin hanya boleh satu akun.');
      await _reload();
    }
  }

  Future<void> _editUser(User user) async {
    if (user.role == UserRole.admin) {
      _message('Akun admin tidak dapat diedit dari panel manajemen.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: user.name);
    final email = TextEditingController(text: user.email);
    final phone = TextEditingController(text: user.phone);
    final city = TextEditingController(text: user.city);
    final password = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.60,
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 8,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit akun',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                _editField(name, 'Nama', Icons.person_outline_rounded, requiredField: true),
                _editField(email, 'Email', Icons.email_outlined, requiredField: true),
                _editField(phone, 'Nomor HP', Icons.phone_outlined, requiredField: true),
                _editField(city, 'Asal Kota', Icons.location_city_outlined, requiredField: true),
                _editField(password, 'Password baru (opsional)', Icons.lock_outline_rounded),
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
                      );
                      if (context.mounted) Navigator.pop(context, true);
                    } on DatabaseException {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email sudah digunakan atau data tidak valid.')),
                        );
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
    );

    name.dispose();
    email.dispose();
    phone.dispose();
    city.dispose();
    password.dispose();

    if (saved == true) {
      await _reload();
    }
  }

  Future<void> _deleteUser(User user) async {
    if (user.id == null) return;
    if (user.role == UserRole.admin) {
      _message('Akun admin tidak dapat dihapus dari panel manajemen.');
      return;
    }
    final currentEmail = (PreferenceHandler.userEmail ?? '').trim().toLowerCase();
    if (AdminAccountPolicy.canManageAccount(
      currentEmail: currentEmail,
      targetEmail: user.email,
    ) == false) {
      _message('Akun admin yang sedang aktif tidak dapat dihapus dari panel manajemen.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus akun?'),
        content: Text('Akun ${user.name} akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DatabaseHelper.instance.deleteUser(user.id!);
      await _reload();
      if (mounted) _message('Akun berhasil dihapus.');
    } on DatabaseException {
      if (mounted) _message('Akun gagal dihapus. Coba lagi.');
    }
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
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: requiredField
            ? (value) => (value == null || value.trim().isEmpty) ? '$label wajib diisi' : null
            : null,
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Muat data terbaru',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<User>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const Center(child: Text('Data users gagal dimuat.')),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba lagi'),
                  ),
                ],
              );
            }
            final users = snapshot.data ?? <User>[];
            final query = _searchController.text.trim().toLowerCase();
            final filteredUsers = users.where((user) {
              final matchesRole =
                  _roleFilter == 'Semua' || user.role.label == _roleFilter;
              final matchesQuery =
                  query.isEmpty ||
                  user.name.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query);
              return matchesRole && matchesQuery;
            }).toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _RoleHeader(
                  title: 'Manajemen akun',
                  subtitle:
                      'Kelola semua data user dan role dari halaman Users.',
                  icon: Icons.manage_accounts_outlined,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(isAdminCreate: true),
                    ),
                  ).then((_) => _reload()),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Tambah akun'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Cari user',
                    hintText: 'Nama atau email',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ['Semua', ...UserRole.values.map((role) => role.label)]
                            .map(
                              (filter) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(filter),
                                  selected: _roleFilter == filter,
                                  onSelected: (_) =>
                                      setState(() => _roleFilter = filter),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data terbaru diperbarui ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Color(0xFF68736F),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                if (filteredUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: Text('Data user tidak ditemukan.')),
                  ),
                ...filteredUsers.map(
                  (user) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                        '${user.email}\n${user.phone} - ${user.role.label}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: user.role == UserRole.admin
                            ? [
                                const Tooltip(
                                  message: 'Akun admin tidak bisa diubah dari panel ini',
                                  child: Icon(Icons.lock_outline_rounded),
                                ),
                              ]
                            : [
                                IconButton(
                                  tooltip: 'Edit akun',
                                  onPressed: () => _editUser(user),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                DropdownButton<UserRole>(
                                  value: user.role,
                                  items: UserRole.values
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role.label),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (role) {
                                    if (role != null) _changeRole(user, role);
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Hapus akun',
                                  onPressed: () => _deleteUser(user),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
