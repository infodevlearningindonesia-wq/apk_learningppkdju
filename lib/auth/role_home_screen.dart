import 'package:flutter/material.dart';
import 'package:devlearning_indonesia/about/about_screen.dart';
import 'package:devlearning_indonesia/auth/login_screen.dart';
import 'package:devlearning_indonesia/auth/register_screen.dart';
import 'package:devlearning_indonesia/database/database_helper.dart';
import 'package:devlearning_indonesia/home/peserta_home_screen.dart';
import 'package:devlearning_indonesia/models/user.dart';
import 'package:devlearning_indonesia/models/attendance_record.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';
import 'package:sqflite/sqflite.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        switch (UserRoleX.fromValue(user['role'] as String?)) {
          case UserRole.admin:
            return AdminHomeScreen(user: user);
          case UserRole.pengajar:
            return PengajarHomeScreen(user: user);
          case UserRole.peserta:
            return const PesertaHomeScreen();
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _loadCurrentUser() async {
    if (!PreferenceHandler.isLogin) return null;
    final email = PreferenceHandler.userEmail;
    if (email == null || email.isEmpty) return null;
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    if (user == null) {
      await PreferenceHandler.clearSession();
    }
    return user;
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<List<User>> _usersFuture;
  int _selectedAdminIndex = 0;
  DateTime? _lastUpdated;
  int _visitCount = 0;
  int _attendanceCount = 0;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseHelper.instance.getUsers();
    _lastUpdated = DateTime.now();
    _visitCount = PreferenceHandler.appVisitCount;
    _refreshAttendanceCount();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _reload() async {
    if (_isReloading || !mounted) return;
    _isReloading = true;
    setState(() {
      _usersFuture = DatabaseHelper.instance.getUsers();
      _lastUpdated = DateTime.now();
      _visitCount = PreferenceHandler.appVisitCount;
    });
    try {
      await Future.wait([_usersFuture, _refreshAttendanceCount()]);
    } finally {
      _isReloading = false;
    }
  }

  Future<void> _refreshAttendanceCount() async {
    final records = await DatabaseHelper.instance.getAllAttendance();
    if (mounted) {
      setState(() => _attendanceCount = records.length);
    }
  }

  Future<void> _logout() async {
    await PreferenceHandler.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(showLogoutMessage: true),
      ),
      (_) => false,
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.admin_panel_settings_outlined, size: 32),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menu Admin',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            ListTile(
              selected: _selectedAdminIndex == 0,
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Beranda Admin'),
              onTap: () {
                setState(() => _selectedAdminIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Aksi administrasi'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Profil Admin'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleProfileScreen(user: widget.user),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Tentang aplikasi'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Keluar'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        actions: [
          IconButton(
            tooltip: 'Profil admin',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RoleProfileScreen(user: widget.user),
              ),
            ),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Tentang aplikasi',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: _buildAdminDrawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedAdminIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            setState(() => _selectedAdminIndex = 0);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RoleProfileScreen(user: widget.user),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            label: 'Admin',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            label: 'User',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
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
                  const Icon(Icons.cloud_off_rounded, size: 48),
                  const SizedBox(height: 12),
                  const Center(child: Text('Data administrasi gagal dimuat.')),
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
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _RoleHeader(
                  title: 'Beranda Admin',
                  subtitle:
                      'Ringkasan data operasional dan administrasi kantor.',
                  icon: Icons.admin_panel_settings_outlined,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ringkasan data umum',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _AdminStat(
                        value:
                            '${users.where((user) => user.role == UserRole.admin).length}',
                        label: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminStat(
                        value: '${users.length}',
                        label: 'Total user',
                        icon: Icons.people_alt_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminStat(
                        value:
                            '${users.where((user) => user.role == UserRole.pengajar).length}',
                        label: 'Pengajar',
                        icon: Icons.school_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminStat(
                        value:
                            '${users.where((user) => user.role == UserRole.peserta).length}',
                        label: 'Peserta',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _AdminStat(
                        value: '$_visitCount',
                        label: 'Kunjungan aplikasi',
                        icon: Icons.visibility_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminStat(
                        value: '$_attendanceCount',
                        label: 'Catatan absensi',
                        icon: Icons.event_available_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aktivitas terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.insights_outlined),
                    ),
                    title: const Text(
                      'Aktivitas operasional',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '$_visitCount kunjungan aplikasi dan $_attendanceCount catatan kehadiran.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminActivityScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _lastUpdated == null
                      ? 'Memuat data terbaru...'
                      : 'Data terbaru diperbarui ${_formatTime(_lastUpdated!)}',
                  style: const TextStyle(
                    color: Color(0xFF68736F),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: const Text(
                      'Buka Users',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Kelola seluruh data akun, role, pencarian, dan penghapusan user.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminUsersScreen(),
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

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  late Future<(List<User>, List<AttendanceRecord>)> _activityFuture;

  @override
  void initState() {
    super.initState();
    _activityFuture = _loadActivityData();
  }

  Future<void> _reload() async {
    setState(() {
      _activityFuture = _loadActivityData();
    });
    await _activityFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas operasional'),
        actions: [
          IconButton(
            tooltip: 'Muat data terbaru',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<(List<User>, List<AttendanceRecord>)>(
        future: _activityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Aktivitas gagal dimuat.'));
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Aktivitas tidak tersedia.'));
          }
          final users = data.$1;
          final attendance = data.$2;
          final attendanceCount = attendance.length;
          final attendanceUsers = users
              .where(
                (user) =>
                    attendance.any((record) => record.email == user.email),
              )
              .toList();

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _RoleHeader(
                  title: 'Data aktivitas kantor',
                  subtitle: 'Ringkasan kunjungan, akun, dan kehadiran terbaru.',
                  icon: Icons.insights_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AdminStat(
                        value: '${PreferenceHandler.appVisitCount}',
                        label: 'Kunjungan',
                        icon: Icons.visibility_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminStat(
                        value: '$attendanceCount',
                        label: 'Absensi',
                        icon: Icons.event_available_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'User terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (users.isEmpty)
                  const Text('Belum ada user terdaftar.')
                else
                  ...users
                      .take(5)
                      .map(
                        (user) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_outline_rounded),
                          ),
                          title: Text(user.name),
                          subtitle: Text('${user.email} - ${user.role.label}'),
                        ),
                      ),
                const SizedBox(height: 16),
                const Text(
                  'Peserta dengan aktivitas absensi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (attendanceUsers.isEmpty)
                  const Text('Belum ada data absensi peserta.')
                else
                  ...attendanceUsers.map(
                    (user) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_available_outlined),
                        title: Text(user.name),
                        subtitle: Text(
                          '${attendance.where((record) => record.email == user.email).length} catatan kehadiran',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<(List<User>, List<AttendanceRecord>)> _loadActivityData() async {
    final users = await DatabaseHelper.instance.getUsers();
    final attendance = await DatabaseHelper.instance.getAllAttendance();
    return (users, attendance);
  }
}

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
    final isCurrentUser =
        user.email.trim().toLowerCase() == PreferenceHandler.userEmail;
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
      if (isCurrentUser) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RoleHomeScreen()),
          (_) => false,
        );
      } else {
        await _reload();
        if (mounted) _message('${user.name} sekarang menjadi ${role.label}.');
      }
    } on DatabaseException {
      if (mounted) _message('Admin hanya boleh satu akun.');
      await _reload();
    }
  }

  Future<void> _deleteUser(User user) async {
    if (user.id == null) return;
    final isCurrentUser =
        user.email.trim().toLowerCase() == PreferenceHandler.userEmail;
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
    await DatabaseHelper.instance.deleteUser(user.id!);
    if (isCurrentUser) {
      await PreferenceHandler.clearSession();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
      return;
    }
    await _reload();
    if (mounted) _message('Akun berhasil dihapus.');
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
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
                        children: [
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

class PengajarHomeScreen extends StatelessWidget {
  const PengajarHomeScreen({super.key, required this.user});

  final Map<String, dynamic> user;

  Future<void> _logout(BuildContext context) async {
    await PreferenceHandler.clearSession();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(showLogoutMessage: true),
      ),
      (_) => false,
    );
  }

  Widget _buildPengajarDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.school_outlined, size: 32),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menu Pengajar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Beranda Pengajar'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Materi pembelajaran'),
              onTap: () {
                Navigator.pop(context);
                _openMaterials(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline_rounded),
              title: const Text('Peserta belajar'),
              onTap: () {
                Navigator.pop(context);
                _openParticipants(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available_outlined),
              title: const Text('Rekap kehadiran'),
              onTap: () {
                Navigator.pop(context);
                _openAttendance(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Profil Pengajar'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleProfileScreen(user: user),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Tentang aplikasi'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Keluar'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = user['name'] as String? ?? 'Pengajar';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Pengajar'),
        actions: [
          IconButton(
            tooltip: 'Profil pengajar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RoleProfileScreen(user: user)),
            ),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Tentang aplikasi',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: _buildPengajarDrawer(context),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Materi',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            label: 'Peserta',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            _openMaterials(context);
          } else if (index == 2) {
            _openParticipants(context);
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _RoleHeader(
            title: 'Halo, $name',
            subtitle: 'Kelola materi dan pantau perkembangan peserta.',
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 20),
          _ActionCard(
            icon: Icons.menu_book_outlined,
            title: 'Materi pembelajaran',
            subtitle: 'Siapkan materi untuk kelas peserta.',
            onTap: () => _openMaterials(context),
          ),
          _ActionCard(
            icon: Icons.people_outline_rounded,
            title: 'Peserta belajar',
            subtitle: 'Pantau daftar peserta yang mengikuti pembelajaran.',
            onTap: () => _openParticipants(context),
          ),
          _ActionCard(
            icon: Icons.event_available_outlined,
            title: 'Rekap kehadiran',
            subtitle: 'Lihat ringkasan kehadiran peserta.',
            onTap: () => _openAttendance(context),
          ),
        ],
      ),
    );
  }

  void _openMaterials(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TeacherMaterialsScreen()),
    );
  }

  void _openParticipants(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TeacherParticipantsScreen()),
    );
  }

  void _openAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TeacherAttendanceScreen()),
    );
  }
}

class TeacherMaterialsScreen extends StatelessWidget {
  const TeacherMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const courses = [
      ('Membangun Aplikasi Mobile', Icons.phone_android_rounded),
      ('Logika dan Algoritma', Icons.data_object_rounded),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Materi pembelajaran')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Kelola dan buka materi kelas yang tersedia.',
            style: TextStyle(color: Color(0xFF68736F)),
          ),
          const SizedBox(height: 16),
          ...courses.map(
            (course) => Card(
              child: ListTile(
                leading: Icon(course.$2, color: const Color(0xFF126B5B)),
                title: Text(course.$1),
                subtitle: const Text('Materi khusus pengajar'),
                trailing: IconButton(
                  tooltip: 'Kelola materi',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Materi ${course.$1} siap dikelola.'),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherParticipantsScreen extends StatelessWidget {
  const TeacherParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peserta belajar')),
      body: FutureBuilder<List<User>>(
        future: DatabaseHelper.instance.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final participants = (snapshot.data ?? <User>[])
              .where((user) => user.role == UserRole.peserta)
              .toList();
          if (participants.isEmpty) {
            return const Center(child: Text('Belum ada peserta terdaftar.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(participant.name),
                  subtitle: Text('${participant.email}\n${participant.city}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TeacherAttendanceScreen extends StatelessWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap kehadiran')),
      body: FutureBuilder<(List<User>, List<AttendanceRecord>)>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Data tidak tersedia.'));
          }
          final attendance = data.$2;
          final participants = data.$1
              .where((user) => user.role == UserRole.peserta)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: participants.map((participant) {
              final records = attendance
                  .where((record) => record.email == participant.email)
                  .toList();
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(participant.name),
                  subtitle: Text('${records.length} catatan kehadiran'),
                  trailing: Text(records.isEmpty ? '-' : records.last.date),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<(List<User>, List<AttendanceRecord>)> _loadData() async {
    final users = await DatabaseHelper.instance.getUsers();
    final attendance = await DatabaseHelper.instance.getAllAttendance();
    return (users, attendance);
  }
}

class _RoleHeader extends StatelessWidget {
  const _RoleHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE6F5DA),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(icon, color: const Color(0xFF3F7D27), size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  const _AdminStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF126B5B)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class RoleProfileScreen extends StatelessWidget {
  const RoleProfileScreen({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final role = UserRoleX.fromValue(user['role'] as String?);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFE6F5DA),
            child: Icon(
              Icons.person_rounded,
              size: 46,
              color: Color(0xFF3F7D27),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              user['name'] as String? ?? 'Pengguna',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Center(child: Text(user['email'] as String? ?? '')),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Peran'),
                  trailing: Text(role.label),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Nomor HP'),
                  trailing: Text(user['phone'] as String? ?? '-'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_city_outlined),
                  title: const Text('Asal kota'),
                  trailing: Text(user['city'] as String? ?? '-'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline_rounded),
            label: const Text('Tentang aplikasi'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF126B5B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
