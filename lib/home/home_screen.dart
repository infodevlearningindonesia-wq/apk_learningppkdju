import 'dart:async';

import 'package:flutter/material.dart';

import 'package:devlearning_indonesia/auth/login_screen.dart';
import 'package:devlearning_indonesia/database/database_helper.dart';
import 'package:devlearning_indonesia/about/about_screen.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';

part 'pages/dashboard_page.dart';
part 'pages/explore_page.dart';
part 'pages/learning_page.dart';
part 'pages/profile_page.dart';
part 'widgets/home_widgets.dart';
part 'pages/course_detail_screen.dart';

// ============================================================
// SAFE PREFERENCE HELPERS
// ============================================================
//
// Mencegah halaman Home/Belajar crash jika data SharedPreferences
// lama masih mengandung null atau tipe data yang tidak sesuai.

List<String> _safeCompletedLessons(String courseTitle) {
  try {
    final value = PreferenceHandler.completedLessons(courseTitle);
    return List<String>.from(value);
  } catch (_) {
    return <String>[];
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _dashboardKey = GlobalKey<_DashboardPageState>();
  final _exploreKey = GlobalKey<_ExplorePageState>();
  final _learningKey = GlobalKey<_LearningPageState>();
  final _profileKey = GlobalKey<_ProfilePageState>();
  bool _isReloading = false;

  static const _pageTitles = ['Beranda', 'Jelajah', 'Belajar', 'Profil'];

  Future<void> _reloadAllFeatures() async {
    if (_isReloading) return;

    setState(() {
      _isReloading = true;
    });
    try {
      await Future.wait([
        _dashboardKey.currentState?.reload() ?? Future<void>.value(),
        _exploreKey.currentState?.reload() ?? Future<void>.value(),
        _learningKey.currentState?.reload() ?? Future<void>.value(),
        _profileKey.currentState?.reload() ?? Future<void>.value(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isReloading = false;
        });
      }
    }
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _reloadAllFeatures();
  }

  Future<void> _logout() async {
    await PreferenceHandler.clearSession();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,

      MaterialPageRoute(
        builder: (_) => const LoginScreen(showLogoutMessage: true),
      ),
    );
  }

  void _showNotifications() {
    final notifications = PreferenceHandler.learningNotifications();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(Icons.school_rounded)),
                title: Text('Selamat datang!'),
                subtitle: Text(
                  'Pilih kelas untuk memulai perjalanan belajarmu.',
                ),
              )
            else
              ...notifications.map(_buildNotificationTile),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(String notification) {
    final values = notification.split('|');
    final title = values.length > 1 ? values[1] : 'Aktivitas belajar';
    final message = values.length > 2
        ? values.sublist(2).join('|')
        : 'Ada pembaruan pada pembelajaranmu.';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.school_rounded)),
      title: Text(title),
      subtitle: Text(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),

        actions: [
          IconButton(
            tooltip: 'Muat ulang semua fitur',
            onPressed: _isReloading ? null : _reloadAllFeatures,
            icon: _isReloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Notifikasi',

            onPressed: _showNotifications,

            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),

      drawer: _buildDrawer(),

      body: IndexedStack(
        index: _selectedIndex,

        children: [
          _DashboardPage(key: _dashboardKey),
          _ExplorePage(key: _exploreKey),
          _LearningPage(key: _learningKey),
          _ProfilePage(key: _profileKey),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: _selectDestination,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda Peserta',
          ),

          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Jelajah',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Belajar',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),

              color: const Color(0xFF3F7D27),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE6F5DA),
                    backgroundImage: AssetImage(
                      'assets/icon_app/icon-logo.jpg',
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'DevLearning Indonesia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Belajar. Tumbuh. Berkarya.',
                    style: TextStyle(color: Color(0xFFDDF3C9)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _drawerItem(0, Icons.home_outlined, 'Beranda'),

            _drawerItem(1, Icons.explore_outlined, 'Jelajah materi'),

            _drawerItem(2, Icons.menu_book_outlined, 'Belajar saya'),

            _drawerItem(3, Icons.person_outline_rounded, 'Profil'),

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

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(int index, IconData icon, String label) {
    return ListTile(
      selected: _selectedIndex == index,

      leading: Icon(icon),

      title: Text(label),

      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        Navigator.pop(context);
      },
    );
  }
}
