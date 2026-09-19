import 'dart:io';

import 'package:flutter/material.dart';

import '../auth/login_sreen.dart';
import '../auth/register_screen.dart';
import '../app_system/app_pages.dart';
import '../app_system/appbottom.dart';
import '../app_system/appdrawer.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../services/preference_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<User>> _usersFuture;
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    _usersFuture = DatabaseHelper.instance.getUsers();
  }

  Future<void> _openUserForm([User? user]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegisterScreen(user: user)),
    );
    if (saved == true && mounted) {
      setState(_refreshUsers);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user == null
                ? 'Peserta berhasil ditambahkan'
                : 'Data peserta berhasil diperbarui',
          ),
        ),
      );
    }
  }

  Future<void> _deleteUser(User user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus peserta?'),
        content: Text('Data ${user.name} akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || user.id == null || !mounted) return;
    await DatabaseHelper.instance.deleteUser(user.id!);
    if (!mounted) return;
    setState(_refreshUsers);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Peserta berhasil dihapus')),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout dari aplikasi?'),
        content: const Text(
          'Sesi Anda akan diakhiri dan aplikasi akan kembali ke halaman login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;
    await PreferenceHandler.setLogin(false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginSreen(showLogoutMessage: true),
      ),
      (route) => false,
    );
  }

  void _selectBottomTab(int index) {
    _showTab(index);
  }

  void _showTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) _refreshUsers();
    });
  }

  void _selectDrawerDestination(AppDrawerDestination destination) {
    switch (destination) {
      case AppDrawerDestination.home:
        _showTab(0);
      case AppDrawerDestination.addParticipant:
        _openUserForm();
      case AppDrawerDestination.profile:
        _showTab(2);
      case AppDrawerDestination.attendance:
        _showTab(1);
      case AppDrawerDestination.books:
        _openPage(const BooksPage());
      case AppDrawerDestination.settings:
        _openPage(const SettingsPage());
      case AppDrawerDestination.about:
        _openPage(const AboutPage());
    }
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Appdrawer(
        onDestinationSelected: _selectDrawerDestination,
        onLogout: _logout,
      ),
      appBar: AppBar(
        toolbarHeight: _selectedIndex == 0 ? 8 : null,
        automaticallyImplyLeading: false,
        leading: _selectedIndex == 0
            ? null
            : Builder(
                builder: (context) => IconButton(
                  tooltip: 'Buka menu',
                  onPressed: Scaffold.of(context).openDrawer,
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
        title: _selectedIndex == 1
            ? const Text('Absensi')
            : _selectedIndex == 2
            ? const Text('Profil')
            : null,
      ),
      body: _selectedIndex == 0
          ? RefreshIndicator(
        onRefresh: () async {
          setState(_refreshUsers);
          await _usersFuture;
        },
        child: FutureBuilder<List<User>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
            }

            final users = snapshot.data ?? [];
            final filteredUsers = users.where((user) {
              final query = _searchQuery.toLowerCase();
              return user.name.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.city.toLowerCase().contains(query);
            }).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              children: [
                _buildHeader(context),
                const SizedBox(height: 22),
                _buildSummaryCard(context, users.length),
                const SizedBox(height: 24),
                _buildQuickSectionTitle('Kategori belajar', 'Lihat semua', () => _openPage(const BooksPage())),
                const SizedBox(height: 12),
                _buildCategoryBoxes(context),
                const SizedBox(height: 24),
                _buildQuickSectionTitle('Materi terbaru', 'Buka katalog', () => _openPage(const BooksPage())),
                const SizedBox(height: 12),
                _buildMaterialBoxes(context),
                const SizedBox(height: 26),
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, atau kota',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () => setState(() => _searchQuery = ''),
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Peserta terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${filteredUsers.length} data',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filteredUsers.isEmpty)
                  _buildEmptyState(context, users.isEmpty)
                else
                  ...filteredUsers.map((user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _UserCard(
                          user: user,
                          onEdit: () => _openUserForm(user),
                          onDelete: () => _deleteUser(user),
                        ),
                      )),
              ],
            );
          },
        ),
      )
          : _selectedIndex == 1
          ? const AttendancePage()
          : const ProfilePage(),
      bottomNavigationBar: Appbottom(
        currentIndex: _selectedIndex,
        onTap: _selectBottomTab,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openUserForm,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Tambah peserta'),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            tooltip: 'Buka menu',
            onPressed: Scaffold.of(context).openDrawer,
            icon: const Icon(Icons.menu_rounded),
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(17),
          ),
          clipBehavior: Clip.antiAlias,
          child: PreferenceHandler.profilePhotoPath == null
              ? Image.asset(
                  'assets/icon_app/icon-logo.jpg',
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(PreferenceHandler.profilePhotoPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.school_outlined,
                    size: 28,
                  ),
                ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DevLearning',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              Text('Belajar dari dasar sampai siap berkarya'),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Logout',
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }

  Widget _buildQuickSectionTitle(
    String title,
    String actionLabel,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }

  Widget _buildCategoryBoxes(BuildContext context) {
    const categories = [
      (Icons.code, 'Pemrograman'),
      (Icons.phone_android_outlined, 'Flutter'),
      (Icons.storage_outlined, 'Database'),
      (Icons.design_services_outlined, 'UI/UX'),
    ];

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return SizedBox(
            width: 128,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openPage(const BooksPage()),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(category.$1, color: Theme.of(context).colorScheme.primary),
                      const Spacer(),
                      Text(category.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialBoxes(BuildContext context) {
    const materials = [
      (Icons.code, 'Logika Pemrograman', '4 materi'),
      (Icons.phone_android_outlined, 'Widget Flutter', '3 materi'),
      (Icons.storage_outlined, 'SQLite dan SQFLite', '2 materi'),
    ];

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: materials.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final material = materials[index];
          return SizedBox(
            width: 220,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openPage(const BooksPage()),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Icon(material.$1),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(material.$2, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(material.$3, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF78C943), Color(0xFFB9E85B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total peserta',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 4),
                Text(
                  'Tetap bertumbuh,\ntetap belajar.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool noUsers) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            noUsers ? Icons.groups_outlined : Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            noUsers ? 'Belum ada peserta' : 'Peserta tidak ditemukan',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            noUsers
                ? 'Tambahkan peserta pertama Anda.'
                : 'Coba kata kunci pencarian lain.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Row(
            children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            backgroundImage: user.photoPath == null
                ? null
                : FileImage(File(user.photoPath!)),
            child: user.photoPath != null
                ? null
                : Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 3),
                    Text(user.city, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
              PopupMenuButton<String>(
            tooltip: 'Aksi peserta',
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Hapus'),
                ),
              ),
            ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
