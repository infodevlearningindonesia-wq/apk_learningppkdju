part of devlearning_roles;

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
