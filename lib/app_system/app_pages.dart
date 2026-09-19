import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../auth/register_screen.dart';
import '../database/database_helper.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../services/preference_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User?> _userFuture;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _photoPath = PreferenceHandler.profilePhotoPath;
    _loadUser();
  }

  Future<void> _pickProfilePhoto(User? user) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (image == null || !mounted) return;

    await PreferenceHandler.setProfilePhotoPath(image.path);
    if (user != null) {
      await DatabaseHelper.instance.updateUser(
        User(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          password: user.password,
          city: user.city,
          photoPath: image.path,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _photoPath = image.path;
      _loadUser();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto profil berhasil diperbarui')),
    );
  }

  void _loadUser() {
    _userFuture = DatabaseHelper.instance.getUserByEmail(
      PreferenceHandler.currentEmail,
    );
  }

  Future<void> _editProfile(User user) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegisterScreen(user: user)),
    );
    if (!mounted || saved != true) return;
    setState(_loadUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF78C943), Color(0xFFB9E85B)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickProfilePhoto(user),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white,
                            backgroundImage: _photoPath == null
                                ? null
                                : FileImage(File(_photoPath!)),
                            child: _photoPath != null
                                ? null
                                : Text(
                                    user?.name.isNotEmpty == true
                                        ? user!.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Color(0xFF5EAE32),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: Color(0xFF5EAE32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Profil belum lengkap',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? PreferenceHandler.currentEmail,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ketuk foto untuk mengganti',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (user == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Data profil belum ditemukan. Daftarkan peserta dengan email ini terlebih dahulu.',
                    ),
                  ),
                )
              else ...[
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Nomor HP',
                  value: user.phone.isEmpty ? 'Belum diisi' : user.phone,
                ),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Asal Kota',
                  value: user.city,
                ),
                _InfoTile(
                  icon: Icons.verified_outlined,
                  label: 'Status',
                  value: 'Peserta aktif',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _editProfile(user),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profil'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  static const _subjects = [
    'Pemrograman Dart',
    'Flutter Mobile',
    'Database SQLite',
    'UI/UX Design',
    'Pemrograman Web',
    'Bahasa Indonesia',
    'Matematika Terapan',
    'Pendidikan Pancasila',
    'Bahasa Inggris Dasar',
    'Ilmu Pengetahuan Alam',
    'Ilmu Pengetahuan Sosial',
    'Literasi Digital',
    'Kompetensi Kejuruan',
    'Keselamatan Kerja Teknik',
  ];

  late Future<List<Attendance>> _attendanceFuture;
  Timer? _clockTimer;
  Timer? _inactivityTimer;
  Timer? _alarmSoundTimer;
  DateTime _now = DateTime.now();
  DateTime _activityStartedAt = DateTime.now();
  String _selectedSubject = _subjects.first;
  bool _isSubmitting = false;
  bool _alarmShown = false;
  bool _checkingAlarm = false;

  String get _email => PreferenceHandler.currentEmail;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadAttendance();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _inactivityTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkInactivityAlarm();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _inactivityTimer?.cancel();
    _alarmSoundTimer?.cancel();
    super.dispose();
  }

  void _loadAttendance() {
    _attendanceFuture = DatabaseHelper.instance.getAttendanceForEmail(_email);
  }

  Future<void> _checkIn() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _stopAlarm(closeDialog: false);
    try {
      final existing = await DatabaseHelper.instance.getTodayAttendance(
        _email,
        _todayKey,
        _selectedSubject,
      );
      if (existing != null) {
        _showMessage('Anda sudah check-in hari ini.');
      } else {
        await DatabaseHelper.instance.insertAttendance(
          Attendance(
            email: _email,
            subject: _selectedSubject,
            date: _todayKey,
            checkIn: DateTime.now(),
          ),
        );
        _showMessage('Check-in berhasil dicatat.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _loadAttendance();
        });
      }
    }
  }

  Future<void> _checkOut(Attendance attendance) async {
    if (_isSubmitting || attendance.id == null) return;
    setState(() => _isSubmitting = true);
    try {
      await DatabaseHelper.instance.updateAttendanceCheckout(
        attendance.id!,
        DateTime.now(),
      );
      _showMessage('Check-out berhasil dicatat.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _loadAttendance();
        });
      }
    }
  }

  Future<void> _exportToExcel() async {
    final records = await DatabaseHelper.instance.getAttendanceForEmail(_email);
    if (records.isEmpty) {
      _showMessage('Belum ada data absensi untuk diekspor.');
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/absensi_${_email.replaceAll('@', '_at_')}.csv');
    final rows = <String>[
      'Email,Mata Pelajaran,Tanggal,Jam Check-in,Jam Check-out,Status',
      ...records.map((record) {
        final checkOut = record.checkOut == null
            ? ''
            : _formatTime(record.checkOut!);
        final status = record.checkOut == null ? 'Aktif' : 'Selesai';
        return [
          _csv(record.email),
          _csv(record.subject),
          _csv(record.date),
          _csv(_formatTime(record.checkIn)),
          _csv(checkOut),
          _csv(status),
        ].join(',');
      }),
    ];
    await file.writeAsString(rows.join('\n'));
    if (!mounted) return;
    _showMessage('Data Excel tersimpan: ${file.path}');
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _checkInactivityAlarm() async {
    if (_checkingAlarm ||
        _alarmShown ||
        !PreferenceHandler.attendanceAlarmEnabled ||
        DateTime.now().difference(_activityStartedAt).inSeconds < 30) {
      return;
    }

    _checkingAlarm = true;
    final attendance = await DatabaseHelper.instance.getTodayAttendance(
      _email,
      _todayKey,
      _selectedSubject,
    );
    _checkingAlarm = false;
    if (!mounted || attendance != null || _alarmShown) return;

    _alarmShown = true;
    _alarmSoundTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      SystemSound.play(SystemSoundType.alert);
    });
    SystemSound.play(SystemSoundType.alert);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pengingat aktivitas belajar'),
        content: Text(
          'Belum ada absensi untuk $_selectedSubject hari ini. Silakan Check-in jika sudah mulai belajar.',
        ),
        actions: [
          FilledButton.icon(
            onPressed: () {
              _stopAlarm(closeDialog: false);
              Navigator.of(dialogContext).pop();
            },
            icon: const Icon(Icons.notifications_off_outlined),
            label: const Text('Stop Alarm'),
          ),
        ],
      ),
    );
  }

  void _stopAlarm({required bool closeDialog}) {
    _alarmSoundTimer?.cancel();
    _alarmSoundTimer = null;
    _alarmShown = false;
    if (closeDialog && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:${value.second.toString().padLeft(2, '0')}';
  }

  String _formatDate(String value) {
    final parts = value.split('-');
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Pribadi')),
      body: FutureBuilder<List<Attendance>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat absensi: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];
          Attendance? today;
          for (final item in history) {
            if (item.date == _todayKey && item.subject == _selectedSubject) {
              today = item;
              break;
            }
          }
          final currentAttendance = today;
            final selectedHistory = history
              .where((item) => item.subject == _selectedSubject)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(_loadAttendance);
              await _attendanceFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _buildStatusCard(context, currentAttendance),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Riwayat $_selectedSubject',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Simpan ke Excel',
                      onPressed: _exportToExcel,
                      icon: const Icon(Icons.file_download_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (selectedHistory.isEmpty)
                  const _AttendanceEmptyState()
                else
                  ...selectedHistory.map((item) => _AttendanceTile(
                        attendance: item,
                        formatDate: _formatDate,
                        formatTime: _formatTime,
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Attendance? today) {
    final hasCheckedIn = today != null;
    final hasCheckedOut = today?.checkOut != null;
    final status = !hasCheckedIn
        ? 'Belum absen hari ini'
        : hasCheckedOut
        ? 'Absensi hari ini selesai'
        : 'Sedang belajar';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF78C943), Color(0xFFB9E85B)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Absensi pribadi',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(_email, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              labelText: 'Mata pelajaran / mata kuliah',
              prefixIcon: const Icon(Icons.menu_book_outlined),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.18),
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIconColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _subjects
                .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedSubject = value;
                _activityStartedAt = DateTime.now();
                _alarmShown = false;
                _loadAttendance();
              });
            },
          ),
          const SizedBox(height: 8),
          _buildLiveField(
            label: 'Tanggal',
            value: _formatDate(_todayKey),
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 8),
          _buildLiveField(
            label: 'Jam realtime',
            value: _formatTime(_now),
            icon: Icons.access_time,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: hasCheckedIn || _isSubmitting ? null : _checkIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Check-in'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5EAE32),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: !hasCheckedIn || hasCheckedOut || _isSubmitting
                      ? null
                      : () => _checkOut(today),
                  icon: const Icon(Icons.logout),
                  label: const Text('Check-out'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0x55FFFFFF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.18),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({
    required this.attendance,
    required this.formatDate,
    required this.formatTime,
  });

  final Attendance attendance;
  final String Function(String) formatDate;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    final isComplete = attendance.checkOut != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isComplete
              ? const Color(0xFFDDF3CC)
              : const Color(0xFFFFF0BE),
          child: Icon(
            isComplete ? Icons.check : Icons.timelapse,
            color: isComplete ? const Color(0xFF5EAE32) : Colors.orange,
          ),
        ),
        title: Text(formatDate(attendance.date)),
        subtitle: Text(
          '${attendance.subject}\nMasuk ${formatTime(attendance.checkIn)}'
          '${attendance.checkOut == null ? '' : ' - Keluar ${formatTime(attendance.checkOut!)}'}',
        ),
        trailing: Text(isComplete ? 'Selesai' : 'Aktif'),
      ),
    );
  }
}

class _AttendanceEmptyState extends StatelessWidget {
  const _AttendanceEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined, size: 44),
            SizedBox(height: 10),
            Text('Belum ada riwayat absensi.'),
          ],
        ),
      ),
    );
  }
}

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  int _selectedCategory = 0;
  String _searchQuery = '';

  static const _categories = [
    _LearningCategory(
      title: 'Semua',
      icon: Icons.apps_outlined,
      description: 'Semua materi belajar',
      materials: [],
    ),
    _LearningCategory(
      title: 'Pemrograman',
      icon: Icons.code,
      description: 'Logika dan bahasa pemrograman',
      materials: _programmingMaterials,
    ),
    _LearningCategory(
      title: 'Flutter',
      icon: Icons.phone_android_outlined,
      description: 'Bangun aplikasi mobile',
      materials: _flutterMaterials,
    ),
    _LearningCategory(
      title: 'Database',
      icon: Icons.storage_outlined,
      description: 'Kelola data aplikasi',
      materials: _databaseMaterials,
    ),
    _LearningCategory(
      title: 'UI/UX',
      icon: Icons.design_services_outlined,
      description: 'Desain produk digital',
      materials: _uiMaterials,
    ),
    _LearningCategory(
      title: 'Web',
      icon: Icons.language_outlined,
      description: 'Teknologi web modern',
      materials: _webMaterials,
    ),
    _LearningCategory(
      title: 'Pelajaran Umum',
      icon: Icons.auto_stories_outlined,
      description: 'Bahasa, matematika, dan wawasan umum',
      materials: _generalMaterials,
    ),
    _LearningCategory(
      title: 'Kejuruan',
      icon: Icons.workspace_premium_outlined,
      description: 'Kompetensi sesuai bidang keahlian',
      materials: _vocationalMaterials,
    ),
    _LearningCategory(
      title: 'Teknik',
      icon: Icons.engineering_outlined,
      description: 'Dasar teknik dan praktik kerja',
      materials: _technicalMaterials,
    ),
  ];

  void _openCategory(_LearningCategory category) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          children: [
            Row(
              children: [
                Icon(category.icon, color: const Color(0xFF5EAE32)),
                const SizedBox(width: 12),
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(category.description),
            const SizedBox(height: 6),
            Text('${category.materials.length} materi tersedia'),
            const SizedBox(height: 20),
            ...List.generate(
              category.materials.length,
              (index) {
                final material = category.materials[index];
                return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(material.title),
                  subtitle: Text(material.introduction),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _MaterialDetailPage(material: material),
                      ),
                    );
                  },
                ),
              );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(sheetContext).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategories = _selectedCategory == 0
        ? _categories.skip(1).toList()
        : [_categories[_selectedCategory]];
    final query = _searchQuery.trim().toLowerCase();
    final categories = selectedCategories
        .map((category) {
          final materials = category.materials.where((material) {
            return query.isEmpty ||
                material.title.toLowerCase().contains(query) ||
                material.introduction.toLowerCase().contains(query) ||
                material.summary.toLowerCase().contains(query);
          }).toList();
          return _LearningCategory(
            title: category.title,
            icon: category.icon,
            description: category.description,
            materials: materials,
          );
        })
        .where((category) => category.materials.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Belajar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
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
                      'DevLearning Indonesia',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 3),
                    Text('Belajar dari dasar sampai siap membangun aplikasi.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Cari materi dan pilih kategori sesuai tujuan belajar Anda.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Cari judul atau penjelasan materi',
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
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ChoiceChip(
                label: Text(_categories[index].title),
                avatar: Icon(_categories[index].icon, size: 17),
                selected: _selectedCategory == index,
                onSelected: (_) => setState(() => _selectedCategory = index),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Materi tidak ditemukan.')),
              ),
            )
          else
            ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryCard(
                category: category,
                onTap: () => _openCategory(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCategory {
  const _LearningCategory({
    required this.title,
    required this.icon,
    required this.description,
    required this.materials,
  });

  final String title;
  final IconData icon;
  final String description;
  final List<_LearningMaterial> materials;
}

class _LearningMaterial {
  const _LearningMaterial({
    required this.title,
    required this.introduction,
    required this.objectives,
    required this.sections,
    required this.exercise,
    required this.summary,
  });

  final String title;
  final String introduction;
  final List<String> objectives;
  final List<_MaterialSection> sections;
  final String exercise;
  final String summary;
}

class _MaterialSection {
  const _MaterialSection({required this.title, required this.content});

  final String title;
  final String content;
}

const _programmingMaterials = [
  _LearningMaterial(
    title: 'Logika Pemrograman',
    introduction: 'Pelajari cara berpikir sistematis sebelum menulis kode.',
    objectives: ['Memahami algoritma', 'Membuat pseudocode', 'Memecah masalah besar'],
    sections: [
      _MaterialSection(title: '1. Algoritma', content: 'Algoritma adalah urutan langkah terstruktur untuk menyelesaikan masalah. Tuliskan input, proses, dan output sebelum memilih bahasa pemrograman.'),
      _MaterialSection(title: '2. Percabangan', content: 'Gunakan if, else if, dan else ketika program harus memilih aksi berdasarkan kondisi tertentu.'),
      _MaterialSection(title: '3. Perulangan', content: 'Gunakan for atau while untuk menjalankan proses berulang. Pastikan kondisi berhenti selalu dapat tercapai.'),
    ],
    exercise: 'Buat pseudocode untuk menghitung nilai rata-rata lima angka dan menentukan apakah hasilnya lulus.',
    summary: 'Program yang baik dimulai dari masalah yang jelas, langkah terurut, kondisi yang tepat, dan hasil yang dapat diuji.',
  ),
  _LearningMaterial(
    title: 'Dart Dasar',
    introduction: 'Kenali sintaks Dart sebagai fondasi pengembangan Flutter.',
    objectives: ['Membuat variabel', 'Menggunakan fungsi', 'Memahami null safety'],
    sections: [
      _MaterialSection(title: '1. Variabel dan Tipe Data', content: 'Gunakan String untuk teks, int/double untuk angka, bool untuk nilai benar-salah, dan final atau const untuk nilai yang tidak berubah.'),
      _MaterialSection(title: '2. Fungsi', content: 'Fungsi mengelompokkan instruksi yang dapat digunakan kembali. Parameter menerima data dan return mengembalikan hasil.'),
      _MaterialSection(title: '3. Null Safety', content: 'Dart membedakan tipe nullable dengan tanda ?. Gunakan pemeriksaan null agar aplikasi lebih aman.'),
    ],
    exercise: 'Buat fungsi Dart yang menerima nama dan nilai ujian, lalu mengembalikan pesan kelulusan.',
    summary: 'Dart menyediakan tipe data jelas, fungsi reusable, dan null safety untuk mencegah kesalahan runtime.',
  ),
  _LearningMaterial(
    title: 'Object-Oriented Programming',
    introduction: 'Bangun program yang rapi dengan class dan object.',
    objectives: ['Membuat class', 'Memakai constructor', 'Memahami inheritance'],
    sections: [
      _MaterialSection(title: '1. Class dan Object', content: 'Class adalah cetak biru, sedangkan object adalah hasil nyata dari class tersebut. Gabungkan data dan perilaku dalam satu unit.'),
      _MaterialSection(title: '2. Encapsulation', content: 'Sembunyikan detail internal dan sediakan method yang aman untuk mengubah data.'),
      _MaterialSection(title: '3. Inheritance', content: 'Class turunan dapat menggunakan kembali perilaku class induk dan menambahkan kemampuan khusus.'),
    ],
    exercise: 'Buat class Student dengan nama, email, dan method untuk menampilkan biodata.',
    summary: 'OOP membantu aplikasi tumbuh dengan struktur yang mudah dipelihara dan digunakan kembali.',
  ),
  _LearningMaterial(
    title: 'Debugging dan Testing',
    introduction: 'Temukan kesalahan dan buktikan kode bekerja sesuai harapan.',
    objectives: ['Membaca error', 'Menggunakan breakpoint', 'Menulis test sederhana'],
    sections: [
      _MaterialSection(title: '1. Membaca Error', content: 'Mulai dari pesan error paling bawah lalu telusuri stack trace menuju kode yang Anda tulis.'),
      _MaterialSection(title: '2. Debugging', content: 'Gunakan log, breakpoint, dan pemeriksaan nilai untuk mengetahui alur eksekusi program.'),
      _MaterialSection(title: '3. Testing', content: 'Test mengunci perilaku penting sehingga perubahan berikutnya tidak merusak fitur lama.'),
    ],
    exercise: 'Tulis satu test yang memeriksa fungsi validasi email dan satu test untuk kondisi email kosong.',
    summary: 'Debugging menjelaskan penyebab masalah, sedangkan testing mencegah masalah yang sama terulang.',
  ),
];

const _flutterMaterials = [
  _LearningMaterial(
    title: 'Widget dan Layout Flutter',
    introduction: 'Pahami fondasi UI Flutter dari widget terkecil sampai layout kompleks.',
    objectives: ['Mengenali widget', 'Menyusun layout', 'Mengatur constraint'],
    sections: [
      _MaterialSection(title: '1. Widget', content: 'Semua tampilan Flutter adalah widget. Text, Icon, Container, dan Button dapat disusun menjadi widget yang lebih besar.'),
      _MaterialSection(title: '2. Row dan Column', content: 'Row menyusun anak secara horizontal, Column secara vertikal. Gunakan Expanded untuk membagi ruang yang tersedia.'),
      _MaterialSection(title: '3. Scrolling', content: 'Gunakan ListView untuk konten panjang dan pastikan hanya satu parent yang mengatur scroll pada satu arah.'),
    ],
    exercise: 'Buat halaman kartu profil dengan foto, nama, email, dan tombol aksi menggunakan Row serta Column.',
    summary: 'UI Flutter dibangun dari widget yang tersusun dalam tree dan mengikuti constraint dari parent.',
  ),
  _LearningMaterial(
    title: 'State Management',
    introduction: 'Kelola perubahan data agar UI selalu mencerminkan kondisi terbaru.',
    objectives: ['Memahami state', 'Menggunakan setState', 'Mengelola async state'],
    sections: [
      _MaterialSection(title: '1. Stateless dan Stateful', content: 'Stateless cocok untuk UI yang tidak berubah. Stateful digunakan ketika interaksi atau data membuat tampilan perlu dibangun ulang.'),
      _MaterialSection(title: '2. setState', content: 'Panggil setState setelah data berubah agar Flutter menjadwalkan rebuild pada bagian widget terkait.'),
      _MaterialSection(title: '3. FutureBuilder', content: 'FutureBuilder membantu menampilkan loading, data berhasil, dan error saat mengambil data asynchronous.'),
    ],
    exercise: 'Buat counter dan ubah labelnya berdasarkan nilai counter dengan setState.',
    summary: 'State yang terkelola baik membuat UI responsif dan alur data mudah dipahami.',
  ),
  _LearningMaterial(
    title: 'Navigasi Flutter',
    introduction: 'Bangun alur antarhalaman dengan route dan Navigator.',
    objectives: ['Membuka halaman', 'Mengirim data', 'Mengembalikan hasil'],
    sections: [
      _MaterialSection(title: '1. Push dan Pop', content: 'Navigator.push membuka halaman baru, sedangkan pop kembali ke halaman sebelumnya.'),
      _MaterialSection(title: '2. pushReplacement', content: 'Gunakan pushReplacement untuk alur seperti splash ke login agar pengguna tidak kembali ke splash dengan tombol Back.'),
      _MaterialSection(title: '3. Hasil Halaman', content: 'Halaman dapat mengembalikan nilai melalui Navigator.pop dan halaman pemanggil dapat menunggu hasil tersebut.'),
    ],
    exercise: 'Buat halaman form yang mengembalikan true setelah data berhasil disimpan.',
    summary: 'Navigasi yang jelas menjaga pengguna tetap memahami posisi dan alur aplikasi.',
  ),
];

const _databaseMaterials = [
  _LearningMaterial(
    title: 'SQLite dan SQFLite',
    introduction: 'Simpan data aplikasi secara permanen di perangkat.',
    objectives: ['Membuat tabel', 'Insert dan query', 'Memahami migrasi'],
    sections: [
      _MaterialSection(title: '1. Database dan Tabel', content: 'Database menyimpan tabel. Setiap tabel memiliki kolom, tipe data, dan primary key sebagai identitas baris.'),
      _MaterialSection(title: '2. CRUD', content: 'Create menggunakan insert, Read menggunakan query, Update menggunakan update, dan Delete menggunakan delete.'),
      _MaterialSection(title: '3. Migrasi', content: 'Naikkan versi database ketika skema berubah dan tambahkan kolom dengan aman agar data lama tetap ada.'),
    ],
    exercise: 'Buat tabel tasks dengan id, title, description, dan is_done lalu tampilkan datanya dengan FutureBuilder.',
    summary: 'SQLite cocok untuk data lokal yang perlu bertahan meski aplikasi ditutup atau offline.',
  ),
  _LearningMaterial(
    title: 'Model dan Mapping Data',
    introduction: 'Jembatani baris database dengan object Dart yang rapi.',
    objectives: ['Membuat model', 'toMap dan fromMap', 'Memisahkan data dan UI'],
    sections: [
      _MaterialSection(title: '1. Model Class', content: 'Model mewakili satu entitas domain, misalnya User atau Attendance, dengan properti yang jelas.'),
      _MaterialSection(title: '2. toMap', content: 'toMap mengubah object menjadi Map agar dapat dikirim ke database saat insert atau update.'),
      _MaterialSection(title: '3. fromMap', content: 'fromMap membaca hasil query lalu membentuk object yang aman digunakan oleh widget.'),
    ],
    exercise: 'Buat model Product dan implementasikan mapping dua arah untuk tabel products.',
    summary: 'Model membuat kontrak data konsisten dan mencegah UI bergantung langsung pada Map mentah.',
  ),
];

const _uiMaterials = [
  _LearningMaterial(
    title: 'Prinsip UI/UX',
    introduction: 'Rancang antarmuka yang jelas, nyaman, dan mudah dipakai.',
    objectives: ['Membuat hierarchy', 'Mengatur spacing', 'Mendesain feedback'],
    sections: [
      _MaterialSection(title: '1. Visual Hierarchy', content: 'Ukuran, warna, dan posisi membantu pengguna mengetahui informasi mana yang paling penting.'),
      _MaterialSection(title: '2. Konsistensi', content: 'Gunakan komponen, jarak, warna, dan label yang konsisten di seluruh halaman.'),
      _MaterialSection(title: '3. Feedback', content: 'Berikan loading, snackbar, dialog, atau perubahan state agar setiap aksi terasa mendapat respons.'),
    ],
    exercise: 'Evaluasi satu halaman aplikasi dan catat tiga elemen yang perlu diperbaiki agar lebih mudah dipindai.',
    summary: 'UI yang baik terlihat rapi, UX yang baik membuat pengguna berhasil mencapai tujuan tanpa kebingungan.',
  ),
  _LearningMaterial(
    title: 'Responsive Design',
    introduction: 'Buat tampilan yang tetap nyaman pada berbagai ukuran layar.',
    objectives: ['Memahami constraint', 'Mencegah overflow', 'Menguji layar kecil'],
    sections: [
      _MaterialSection(title: '1. Ukuran Fleksibel', content: 'Gunakan Expanded, Flexible, constraints, dan padding adaptif daripada ukuran tetap yang terlalu besar.'),
      _MaterialSection(title: '2. Konten Panjang', content: 'Gunakan scroll yang tepat dan hindari Column panjang tanpa parent yang dapat menggulir.'),
      _MaterialSection(title: '3. Pengujian', content: 'Uji portrait, landscape, layar kecil, dan teks panjang untuk menemukan overflow sejak awal.'),
    ],
    exercise: 'Uji halaman form pada layar sempit dan perbaiki setiap overflow yang muncul.',
    summary: 'Responsive design memastikan fitur tetap dapat digunakan, bukan hanya terlihat bagus di satu perangkat.',
  ),
];

const _webMaterials = [
  _LearningMaterial(
    title: 'Dasar Web Modern',
    introduction: 'Kenali fondasi HTML, CSS, JavaScript, dan komunikasi web.',
    objectives: ['Memahami struktur HTML', 'Mengatur CSS', 'Mengenal HTTP'],
    sections: [
      _MaterialSection(title: '1. HTML', content: 'HTML menyusun struktur dokumen melalui elemen seperti heading, paragraph, link, form, dan semantic section.'),
      _MaterialSection(title: '2. CSS', content: 'CSS mengatur warna, layout, spacing, typography, dan responsive breakpoint pada halaman.'),
      _MaterialSection(title: '3. HTTP dan API', content: 'Client mengirim request ke server melalui HTTP dan menerima response yang dapat berupa JSON.'),
    ],
    exercise: 'Buat halaman profil sederhana dengan HTML semantic dan layout responsif menggunakan CSS.',
    summary: 'Web modern menggabungkan struktur HTML, presentasi CSS, perilaku JavaScript, dan komunikasi API.',
  ),
];

const _generalMaterials = [
  _LearningMaterial(
    title: 'Bahasa Indonesia Profesional',
    introduction: 'Pelajari komunikasi tertulis yang jelas untuk sekolah dan dunia kerja.',
    objectives: ['Menyusun gagasan', 'Menulis laporan', 'Berkomunikasi formal'],
    sections: [
      _MaterialSection(title: '1. Struktur Gagasan', content: 'Tuliskan ide utama terlebih dahulu, lalu susun penjelasan dan bukti pendukung secara runtut.'),
      _MaterialSection(title: '2. Laporan', content: 'Laporan yang baik memiliki tujuan, metode, hasil, pembahasan, dan kesimpulan yang mudah ditelusuri.'),
      _MaterialSection(title: '3. Komunikasi Kerja', content: 'Gunakan bahasa ringkas, sopan, dan spesifik ketika menulis email atau dokumentasi.'),
    ],
    exercise: 'Tulis laporan satu halaman tentang proyek belajar Anda dengan struktur pembuka, isi, dan kesimpulan.',
    summary: 'Komunikasi yang terstruktur membantu ide dipahami dan pekerjaan berjalan lebih efektif.',
  ),
  _LearningMaterial(
    title: 'Matematika Terapan',
    introduction: 'Gunakan konsep matematika untuk memecahkan masalah sehari-hari dan teknis.',
    objectives: ['Memahami persentase', 'Mengolah data', 'Membaca grafik'],
    sections: [
      _MaterialSection(title: '1. Persentase', content: 'Persentase membandingkan bagian dengan keseluruhan dan sering digunakan untuk menghitung diskon, pertumbuhan, dan capaian.'),
      _MaterialSection(title: '2. Data', content: 'Gunakan rata-rata, nilai minimum, dan maksimum untuk membaca kumpulan data secara sederhana.'),
      _MaterialSection(title: '3. Grafik', content: 'Pilih grafik batang untuk perbandingan, garis untuk perubahan waktu, dan pie untuk proporsi.'),
    ],
    exercise: 'Hitung persentase kehadiran peserta dan tampilkan hasilnya dalam grafik sederhana.',
    summary: 'Matematika terapan membantu mengambil keputusan berdasarkan angka dan pola yang terlihat.',
  ),
  _LearningMaterial(
    title: 'Pendidikan Pancasila',
    introduction: 'Pahami nilai Pancasila dan penerapannya dalam kehidupan bersama.',
    objectives: ['Memahami nilai dasar', 'Menghargai keberagaman', 'Bertanggung jawab sebagai warga'],
    sections: [
      _MaterialSection(title: '1. Nilai Pancasila', content: 'Setiap sila menjadi pedoman untuk bersikap adil, menghargai manusia, menjaga persatuan, bermusyawarah, dan berbagi tanggung jawab.'),
      _MaterialSection(title: '2. Keberagaman', content: 'Perbedaan suku, agama, bahasa, dan budaya adalah kekuatan yang perlu dihormati melalui sikap terbuka dan tidak diskriminatif.'),
      _MaterialSection(title: '3. Praktik Sehari-hari', content: 'Terapkan nilai Pancasila melalui kerja sama, kejujuran, toleransi, gotong royong, dan penyelesaian masalah secara musyawarah.'),
    ],
    exercise: 'Tuliskan lima contoh penerapan Pancasila di sekolah, rumah, dan lingkungan digital.',
    summary: 'Pancasila menjadi dasar sikap pribadi dan kehidupan bersama yang adil serta bertanggung jawab.',
  ),
  _LearningMaterial(
    title: 'Bahasa Inggris Dasar',
    introduction: 'Bangun kemampuan komunikasi Bahasa Inggris untuk belajar dan bekerja.',
    objectives: ['Memahami kosakata', 'Menyusun kalimat', 'Berkomunikasi sederhana'],
    sections: [
      _MaterialSection(title: '1. Vocabulary', content: 'Mulai dari kosakata yang dekat dengan aktivitas harian, sekolah, pekerjaan, dan teknologi.'),
      _MaterialSection(title: '2. Sentence', content: 'Kalimat dasar dapat disusun dengan subject, verb, object, dan keterangan waktu atau tempat.'),
      _MaterialSection(title: '3. Communication', content: 'Gunakan salam, perkenalan, pertanyaan sederhana, dan ungkapan meminta bantuan dengan percaya diri.'),
    ],
    exercise: 'Buat perkenalan diri dalam Bahasa Inggris yang mencakup nama, kota, minat, dan tujuan belajar.',
    summary: 'Kemampuan Bahasa Inggris tumbuh melalui kosakata, pola kalimat, dan latihan komunikasi rutin.',
  ),
  _LearningMaterial(
    title: 'Ilmu Pengetahuan Alam',
    introduction: 'Pelajari gejala alam melalui pengamatan dan cara berpikir ilmiah.',
    objectives: ['Mengamati fenomena', 'Membuat hipotesis', 'Menarik kesimpulan'],
    sections: [
      _MaterialSection(title: '1. Metode Ilmiah', content: 'Metode ilmiah dimulai dari pertanyaan, pengamatan, hipotesis, percobaan, analisis, dan kesimpulan.'),
      _MaterialSection(title: '2. Energi', content: 'Energi dapat berubah bentuk, misalnya listrik menjadi cahaya atau energi kimia menjadi gerak.'),
      _MaterialSection(title: '3. Lingkungan', content: 'Keseimbangan lingkungan dipengaruhi hubungan antara makhluk hidup, sumber daya, dan aktivitas manusia.'),
    ],
    exercise: 'Amati perubahan suhu air pada tiga kondisi berbeda dan catat hasilnya dalam tabel.',
    summary: 'Sains melatih rasa ingin tahu, pengamatan yang teliti, dan kesimpulan berdasarkan bukti.',
  ),
  _LearningMaterial(
    title: 'Ilmu Pengetahuan Sosial',
    introduction: 'Pahami hubungan manusia, masyarakat, ekonomi, dan lingkungan.',
    objectives: ['Membaca fenomena sosial', 'Memahami kegiatan ekonomi', 'Melihat hubungan ruang'],
    sections: [
      _MaterialSection(title: '1. Masyarakat', content: 'Masyarakat terbentuk dari individu dan kelompok yang berinteraksi dengan norma serta tujuan bersama.'),
      _MaterialSection(title: '2. Ekonomi', content: 'Kegiatan ekonomi meliputi produksi, distribusi, dan konsumsi untuk memenuhi kebutuhan manusia.'),
      _MaterialSection(title: '3. Ruang', content: 'Letak dan kondisi wilayah memengaruhi pekerjaan, budaya, transportasi, dan perkembangan suatu daerah.'),
    ],
    exercise: 'Amati satu kegiatan ekonomi di sekitar rumah dan jelaskan siapa produsen, distributor, dan konsumennya.',
    summary: 'IPS membantu memahami kehidupan sosial dan keputusan manusia dalam ruang serta waktu.',
  ),
  _LearningMaterial(
    title: 'Literasi Digital',
    introduction: 'Gunakan teknologi secara aman, kritis, produktif, dan bertanggung jawab.',
    objectives: ['Menilai informasi', 'Menjaga privasi', 'Berperilaku etis'],
    sections: [
      _MaterialSection(title: '1. Informasi', content: 'Periksa sumber, tanggal, penulis, dan bukti sebelum membagikan informasi di internet.'),
      _MaterialSection(title: '2. Privasi', content: 'Gunakan password kuat, autentikasi tambahan, dan jangan membagikan data pribadi sembarangan.'),
      _MaterialSection(title: '3. Etika Digital', content: 'Berkomunikasilah dengan sopan, hormati karya orang lain, dan pikirkan dampak sebelum mengunggah sesuatu.'),
    ],
    exercise: 'Buat checklist untuk memeriksa apakah sebuah berita online dapat dipercaya.',
    summary: 'Literasi digital membuat teknologi menjadi alat belajar yang aman, kritis, dan bermanfaat.',
  ),
];

const _vocationalMaterials = [
  _LearningMaterial(
    title: 'Dasar Kompetensi Kejuruan',
    introduction: 'Pahami sikap kerja, standar kompetensi, dan budaya industri.',
    objectives: ['Mengenal SOP', 'Menjaga kualitas', 'Bekerja profesional'],
    sections: [
      _MaterialSection(title: '1. SOP', content: 'Standard Operating Procedure menjelaskan langkah kerja agar proses aman, konsisten, dan dapat diperiksa.'),
      _MaterialSection(title: '2. Kualitas', content: 'Periksa hasil kerja menggunakan kriteria yang disepakati dan catat setiap perbaikan yang diperlukan.'),
      _MaterialSection(title: '3. Sikap Industri', content: 'Disiplin, komunikasi, tanggung jawab, dan kemampuan bekerja sama adalah bagian dari kompetensi kejuruan.'),
    ],
    exercise: 'Buat SOP singkat untuk satu pekerjaan praktikum dari persiapan sampai pemeriksaan hasil.',
    summary: 'Kompetensi kejuruan menggabungkan pengetahuan, keterampilan praktik, dan sikap kerja.',
  ),
  _LearningMaterial(
    title: 'Kewirausahaan Digital',
    introduction: 'Ubah keterampilan menjadi solusi dan peluang usaha berbasis digital.',
    objectives: ['Menemukan masalah', 'Membuat nilai produk', 'Menyusun rencana usaha'],
    sections: [
      _MaterialSection(title: '1. Masalah Pengguna', content: 'Mulai dari masalah nyata yang dialami target pengguna, bukan hanya dari ide teknologi.'),
      _MaterialSection(title: '2. Nilai Produk', content: 'Jelaskan manfaat utama produk, siapa penggunanya, dan alasan mereka memilih solusi Anda.'),
      _MaterialSection(title: '3. Rencana', content: 'Tentukan biaya, cara pemasaran, sumber pendapatan, dan ukuran keberhasilan secara realistis.'),
    ],
    exercise: 'Buat satu halaman rencana aplikasi yang menyelesaikan masalah di sekolah atau lingkungan sekitar.',
    summary: 'Wirausaha digital menghubungkan kebutuhan pengguna, solusi yang bernilai, dan eksekusi berkelanjutan.',
  ),
];

const _technicalMaterials = [
  _LearningMaterial(
    title: 'Keselamatan Kerja Teknik',
    introduction: 'Kenali prosedur keselamatan sebelum melakukan pekerjaan praktik.',
    objectives: ['Mengenali risiko', 'Memakai APD', 'Menangani keadaan darurat'],
    sections: [
      _MaterialSection(title: '1. Identifikasi Risiko', content: 'Amati sumber listrik, panas, benda tajam, bahan kimia, dan kondisi lingkungan sebelum mulai bekerja.'),
      _MaterialSection(title: '2. APD', content: 'Gunakan alat pelindung sesuai risiko pekerjaan dan periksa kondisinya sebelum digunakan.'),
      _MaterialSection(title: '3. Keadaan Darurat', content: 'Ketahui lokasi kotak P3K, pemadam, jalur keluar, dan orang yang harus dihubungi.'),
    ],
    exercise: 'Buat checklist keselamatan untuk ruang praktik dan tandai risiko yang perlu diperbaiki.',
    summary: 'Keselamatan kerja adalah tanggung jawab sebelum, selama, dan sesudah pekerjaan teknik dilakukan.',
  ),
  _LearningMaterial(
    title: 'Gambar Teknik Dasar',
    introduction: 'Baca dan buat representasi teknis dengan ukuran serta simbol yang tepat.',
    objectives: ['Membaca skala', 'Memahami proyeksi', 'Menulis ukuran'],
    sections: [
      _MaterialSection(title: '1. Garis dan Simbol', content: 'Jenis garis, simbol, dan ketebalan memiliki makna berbeda dalam gambar teknik.'),
      _MaterialSection(title: '2. Proyeksi', content: 'Proyeksi membantu menggambarkan benda tiga dimensi pada bidang dua dimensi dari beberapa pandangan.'),
      _MaterialSection(title: '3. Ukuran', content: 'Cantumkan dimensi dengan jelas dan konsisten agar gambar dapat digunakan untuk membuat benda nyata.'),
    ],
    exercise: 'Gambar benda sederhana dari tampak depan, samping, dan atas lengkap dengan ukuran.',
    summary: 'Gambar teknik adalah bahasa visual yang membutuhkan ketelitian, standar, dan ukuran yang konsisten.',
  ),
];

class _MaterialDetailPage extends StatelessWidget {
  const _MaterialDetailPage({required this.material});

  final _LearningMaterial material;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(material.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          Text(material.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(material.introduction, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          const Text('Tujuan pembelajaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...material.objectives.map((objective) => ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(objective), contentPadding: EdgeInsets.zero)),
          const SizedBox(height: 16),
          ...material.sections.map((section) => Padding(padding: const EdgeInsets.only(bottom: 18), child: _MaterialContentSection(section: section))),
          _MaterialPanel(
            title: 'Contoh penerapan',
            icon: Icons.lightbulb_outline,
            content: 'Contoh: terapkan konsep ${material.title} pada proyek kecil, dokumentasikan langkahnya, lalu uji hasilnya.',
          ),
          const SizedBox(height: 14),
          _MaterialPanel(title: 'Latihan', icon: Icons.edit_note, content: material.exercise),
          const SizedBox(height: 14),
          _MaterialPanel(title: 'Rangkuman', icon: Icons.bookmark_outline, content: material.summary),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.done), label: const Text('Selesai membaca')),
        ],
      ),
    );
  }
}

class _MaterialContentSection extends StatelessWidget {
  const _MaterialContentSection({required this.section});

  final _MaterialSection section;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(section.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text(section.content, style: const TextStyle(height: 1.45)),
    ]);
  }
}

class _MaterialPanel extends StatelessWidget {
  const _MaterialPanel({required this.title, required this.icon, required this.content});

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(content, style: const TextStyle(height: 1.4))]))])));
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final _LearningCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(category.description),
                    const SizedBox(height: 4),
                    Text('${category.materials.length} materi'),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _notificationsEnabled;
  late bool _attendanceAlarmEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = PreferenceHandler.notificationsEnabled;
    _attendanceAlarmEnabled = PreferenceHandler.attendanceAlarmEnabled;
  }

  Future<void> _showThemePicker() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => _ThemeColorPicker(
        initialColor: PreferenceHandler.themeColor.value,
      ),
    );
    if (selectedColor == null) return;
    await PreferenceHandler.setThemeColor(selectedColor);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tema berhasil diterapkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Preferensi aplikasi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Card(
            child: SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                final messenger = ScaffoldMessenger.of(context);
                await PreferenceHandler.setNotificationsEnabled(value);
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notifikasi belajar diaktifkan'
                          : 'Notifikasi belajar dimatikan',
                    ),
                  ),
                );
              },
              title: const Text('Notifikasi belajar'),
              subtitle: const Text('Dapatkan pengingat untuk sesi belajar.'),
              secondary: const Icon(Icons.notifications_outlined),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: _attendanceAlarmEnabled,
              onChanged: (value) async {
                setState(() => _attendanceAlarmEnabled = value);
                final messenger = ScaffoldMessenger.of(context);
                await PreferenceHandler.setAttendanceAlarmEnabled(value);
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Alarm absensi diaktifkan' : 'Alarm absensi dimatikan',
                    ),
                  ),
                );
              },
              title: const Text('Alarm absensi'),
              subtitle: const Text('Ingatkan jika belum ada aktivitas belajar.'),
              secondary: const Icon(Icons.alarm_outlined),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Tema aplikasi'),
              subtitle: const Text('Pilih warna utama sesuka hati'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showThemePicker,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeColorPicker extends StatefulWidget {
  const _ThemeColorPicker({required this.initialColor});

  final Color initialColor;

  @override
  State<_ThemeColorPicker> createState() => _ThemeColorPickerState();
}

class _ThemeColorPickerState extends State<_ThemeColorPicker> {
  late double _red;
  late double _green;
  late double _blue;

  @override
  void initState() {
    super.initState();
    _red = widget.initialColor.r * 255;
    _green = widget.initialColor.g * 255;
    _blue = widget.initialColor.b * 255;
  }

  Color get _color => Color.fromARGB(
        255,
        _red.round(),
        _green.round(),
        _blue.round(),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah tema aplikasi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 74,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Preview tema',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _colorSlider('Merah', _red, Colors.red, (value) => setState(() => _red = value)),
            _colorSlider('Hijau', _green, Colors.green, (value) => setState(() => _green = value)),
            _colorSlider('Biru', _blue, Colors.blue, (value) => setState(() => _blue = value)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_color),
          child: const Text('Terapkan'),
        ),
      ],
    );
  }

  Widget _colorSlider(
    String label,
    double value,
    Color activeColor,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            max: 255,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 28, child: Text(value.round().toString())),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FeaturePage(
      title: 'Tentang Aplikasi',
      icon: Icons.info_outline,
      headline: 'DevLearning Indonesia',
      description: 'Ruang belajar untuk bertumbuh bersama melalui teknologi.',
      children: [
        _InfoTile(icon: Icons.verified_outlined, label: 'Versi aplikasi', value: '1.0.0'),
        _InfoTile(icon: Icons.favorite_border, label: 'Dibuat untuk', value: 'Komunitas belajar Indonesia'),
      ],
    );
  }
}

class _FeaturePage extends StatelessWidget {
  const _FeaturePage({
    required this.title,
    required this.icon,
    required this.headline,
    required this.description,
    required this.children,
  });

  final String title;
  final IconData icon;
  final String headline;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF78C943), Color(0xFFB9E85B)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: const Color(0xFF5EAE32), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: ListTile(
              leading: Icon(
                icon,
                color: Theme.of(sheetContext).colorScheme.primary,
              ),
              title: Text(label),
              subtitle: Text(value),
            ),
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(label),
          subtitle: Text(value),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
