import 'package:flutter/material.dart';

enum AppDrawerDestination {
  home,
  addParticipant,
  profile,
  attendance,
  books,
  settings,
  about,
}

class Appdrawer extends StatelessWidget {
  const Appdrawer({
    super.key,
    required this.onDestinationSelected,
    required this.onLogout,
  });

  final ValueChanged<AppDrawerDestination> onDestinationSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF78C943), Color(0xFFB9E85B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/icon_app/icon-logo.jpg',
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DevLearning',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Menu aplikasi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _item(context, Icons.home_outlined, 'Beranda', AppDrawerDestination.home),
                    _item(context, Icons.person_add_alt_1, 'Tambah Peserta', AppDrawerDestination.addParticipant),
                    _item(context, Icons.person_outline, 'Profil', AppDrawerDestination.profile),
                    _item(context, Icons.event_available_outlined, 'Absensi', AppDrawerDestination.attendance),
                    _item(context, Icons.menu_book_outlined, 'Buku Belajar', AppDrawerDestination.books),
                    const Divider(height: 24, indent: 20, endIndent: 20),
                    _item(context, Icons.settings_outlined, 'Pengaturan', AppDrawerDestination.settings),
                    _item(context, Icons.info_outline, 'Tentang Aplikasi', AppDrawerDestination.about),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  onLogout();
                },
              ),
            ],
          ),
        ),
      );
  }

  void _select(BuildContext context, AppDrawerDestination destination) {
    Navigator.of(context).pop();
    onDestinationSelected(destination);
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    AppDrawerDestination destination,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () => _select(context, destination),
    );
  }
}