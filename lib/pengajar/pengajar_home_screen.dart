part of devlearning_roles;

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
                    'Menu Pengajar',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
