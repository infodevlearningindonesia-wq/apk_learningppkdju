part of devlearning_roles;

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
              decoration: BoxDecoration(
                color: Color(0xFF3F7D27),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE6F5DA),
                    backgroundImage: AssetImage('assets/icon_app/icon-logo.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menu Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
