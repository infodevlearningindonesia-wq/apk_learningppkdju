part of '../home_screen.dart';

class _LearningPage extends StatefulWidget {
  const _LearningPage({super.key});

  @override
  State<_LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<_LearningPage> {
  late Future<_LearningProgress> _progressFuture;

  @override
  void initState() {
    super.initState();

    _progressFuture = _loadProgress();
  }

  Future<_LearningProgress> _loadProgress() async {
    var completed = 0;

    var started = 0;

    var certificates = 0;

    final courseProgress = <String, int>{};

    for (final entry in _materials.entries) {
      final lessonIds = entry.value.map((lesson) => lesson.id).toSet();

      final count = _safeCompletedLessons(entry.key)
          .where(lessonIds.contains)
          .toSet()
          .length;

      courseProgress[entry.key] = count;

      completed += count;

      if (count > 0) started++;

      if (count == entry.value.length) certificates++;
    }

    final attendance = _safeAttendanceDates();

    final today = DateTime.now().toIso8601String().substring(0, 10);

    return _LearningProgress(
      completed,
      started,
      certificates,
      courseProgress,
      attendance,
      _attendanceStreak(attendance),
      attendance.contains(today),
    );
  }

  Future<void> reload() async {
    setState(() {
      _progressFuture = _loadProgress();
    });
    await _progressFuture;
  }

  int _attendanceStreak(List<String> dates) {
    final present = dates.toSet();

    var day = DateTime.now();

    if (!present.contains(day.toIso8601String().substring(0, 10))) {
      day = day.subtract(const Duration(days: 1));
    }

    var streak = 0;

    while (present.contains(day.toIso8601String().substring(0, 10))) {
      streak++;

      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> _markAttendance({
    required String status,
    required String note,
  }) async {
    await PreferenceHandler.markAttendanceToday(
      status: status,
      note: note,
    );
    await PreferenceHandler.addLearningNotification(
      title: 'Kehadiran dicatat',
      message: 'Kehadiran belajarmu hari ini berhasil dicatat.',
    );

    if (!mounted) return;

    setState(() {
      _progressFuture = _loadProgress();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kehadiran hari ini berhasil dicatat.')),
    );
  }

  Future<void> _showAttendanceForm() async {
    final noteController = TextEditingController();
    var selectedStatus = 'Hadir';

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            4,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Form absensi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text('Tanggal: ${DateTime.now().toIso8601String().substring(0, 10)}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status kehadiran',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                    DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                    DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, {
                    'status': selectedStatus,
                    'note': noteController.text.trim(),
                  }),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan absensi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    noteController.dispose();

    if (!mounted || result == null) return;
    await _markAttendance(
      status: result['status'] ?? 'Hadir',
      note: result['note'] ?? '',
    );
  }

  void _showAttendanceHistory() {
    final records = PreferenceHandler.attendanceRecords();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          children: [
            const Text(
              'Riwayat kehadiran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              const Text('Belum ada kehadiran tercatat.')
            else
              ...records.reversed.map(
                (record) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.event_available_rounded,
                    color: Color(0xFF3F7D27),
                  ),
                  title: Text(record['date']!),
                  subtitle: Text(
                    record['note']!.isEmpty
                        ? record['status']!
                        : '${record['status']} - ${record['note']}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCourse(String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(title: title)),
    );

    if (mounted) {
      setState(() {
        _progressFuture = _loadProgress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LearningProgress>(
      future: _progressFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final progress =
            snapshot.data ??
            const _LearningProgress(
              0,
              0,
              0,
              <String, int>{},
              <String>[],
              0,
              false,
            );

        return ListView(
          padding: const EdgeInsets.all(20),

          children: [
            const Text(
              'Pantau perjalanan belajarmu di sini.',
              style: TextStyle(color: Color(0xFF68736F), fontSize: 15),
            ),

            const SizedBox(height: 20),

            Card(
              margin: EdgeInsets.zero,

              color: const Color(0xFFE6F5DA),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kehadiran belajar',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${progress.attendance.length} kali hadir Â· ${progress.streak} hari streak',
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: progress.attendedToday
                              ? null
                              : _showAttendanceForm,
                            icon: Icon(
                              progress.attendedToday
                                  ? Icons.check_circle_rounded
                                  : Icons.how_to_reg_rounded,
                            ),
                            label: Text(
                              progress.attendedToday
                                  ? 'Sudah hadir'
                                  : 'Hadir hari ini',
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        IconButton(
                          tooltip: 'Riwayat kehadiran',
                            onPressed: _showAttendanceHistory,
                          icon: const Icon(Icons.history_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _StatCard(
              icon: Icons.play_lesson_rounded,
              value: '${progress.started} kelas',
              label: 'Kelas dimulai',
              color: const Color(0xFFFFE8C9),
            ),

            const SizedBox(height: 12),

            _StatCard(
              icon: Icons.check_circle_outline_rounded,
              value: '${progress.completed} materi',
              label: 'Materi selesai',
              color: const Color(0xFFE6F5DA),
            ),

            const SizedBox(height: 12),

            _StatCard(
              icon: Icons.workspace_premium_outlined,
              value: '${progress.certificates} kelas',
              label: 'Kelas tuntas',
              color: const Color(0xFFE8EEF9),
            ),

            const SizedBox(height: 28),

            const _SectionTitle(title: 'Lanjutkan belajar'),

            const SizedBox(height: 12),

            ..._materials.entries.map((entry) {
              final count = (progress.courseProgress[entry.key] ?? 0)
                  .clamp(0, entry.value.length)
                  .toInt();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),

                child: Card(
                  child: ListTile(
                    onTap: () => _openCourse(entry.key),

                    leading: CircleAvatar(
                      child: Text(
                        '$count/${entry.value.length}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),

                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),

                    subtitle: LinearProgressIndicator(
                      value: count / entry.value.length,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _LearningProgress {
  const _LearningProgress(
    this.completed,
    this.started,
    this.certificates,
    this.courseProgress,
    this.attendance,
    this.streak,
    this.attendedToday,
  );

  final int completed;

  final int started;

  final int certificates;

  final Map<String, int> courseProgress;

  final List<String> attendance;

  final int streak;

  final bool attendedToday;
}
