part of '../home_screen.dart';

class _LearningPage extends StatefulWidget {
  const _LearningPage({super.key});

  @override
  State<_LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<_LearningPage> {
  late Future<_LearningProgress> _progressFuture;

  bool _isSavingAttendance = false;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgress();
  }

  // ============================================================
  // LOAD PROGRESS
  // ============================================================

  Future<_LearningProgress> _loadProgress() async {
    var completed = 0;
    var started = 0;
    var certificates = 0;

    final courseProgress = <String, int>{};

    for (final entry in _materials.entries) {
      final lessons = entry.value;

      final lessonIds = lessons
          .map((lesson) => lesson.id)
          .toSet();

      final completedLessons = _safeCompletedLessons(
        entry.key,
      );

      final count = completedLessons
          .where(lessonIds.contains)
          .toSet()
          .length;

      courseProgress[entry.key] = count;

      completed += count;

      if (count > 0) {
        started++;
      }

      if (lessons.isNotEmpty &&
          count >= lessons.length) {
        certificates++;
      }
    }

    // ==========================================================
    // LOAD ATTENDANCE
    // ==========================================================

    final email = PreferenceHandler.userEmail;

    List<String> attendance = <String>[];

    if (email != null && email.trim().isNotEmpty) {
      try {
        final records = await DatabaseHelper.instance
            .getAttendanceForUser(email);

        attendance = records
            .map((record) => record.date)
            .where((date) => date.isNotEmpty)
            .toSet()
            .toList();
      } catch (error, stackTrace) {
        debugPrint(
          'Gagal mengambil data kehadiran: $error',
        );
        debugPrintStack(
          stackTrace: stackTrace,
        );
      }
    }

    final today = _todayString();

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

  // ============================================================
  // TODAY
  // ============================================================

  String _todayString() {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // RELOAD
  // ============================================================

  Future<void> reload() async {
    if (!mounted) return;

    setState(() {
      _progressFuture = _loadProgress();
    });

    try {
      await _progressFuture;
    } catch (error, stackTrace) {
      debugPrint(
        'Gagal reload Learning Page: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // ATTENDANCE STREAK
  // ============================================================

  int _attendanceStreak(List<String> dates) {
    final present = dates
        .where((date) => date.isNotEmpty)
        .toSet();

    if (present.isEmpty) {
      return 0;
    }

    var day = DateTime.now();

    final today = _formatDate(day);

    // Kalau hari ini belum hadir,
    // streak dihitung mulai dari kemarin.
    if (!present.contains(today)) {
      day = day.subtract(
        const Duration(days: 1),
      );
    }

    var streak = 0;

    while (present.contains(_formatDate(day))) {
      streak++;

      day = day.subtract(
        const Duration(days: 1),
      );
    }

    return streak;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // SAVE ATTENDANCE
  // ============================================================

  Future<void> _markAttendance({
    required String status,
    required String note,
  }) async {
    if (_isSavingAttendance) {
      return;
    }

    final email = PreferenceHandler.userEmail;

    if (email == null || email.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email pengguna tidak ditemukan. Silakan login kembali.',
          ),
        ),
      );

      return;
    }

    final normalizedEmail =
        email.trim().toLowerCase();

    setState(() {
      _isSavingAttendance = true;
    });

    try {
      debugPrint(
        '========================================',
      );
      debugPrint('MENYIMPAN KEHADIRAN');
      debugPrint('Email  : $normalizedEmail');
      debugPrint('Status : $status');
      debugPrint('Catatan: $note');
      debugPrint(
        '========================================',
      );

      final result = await DatabaseHelper.instance
          .saveAttendance(
            email: normalizedEmail,
            status: status.trim().isEmpty
                ? 'Hadir'
                : status.trim(),
            note: note.trim(),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        'Kehadiran berhasil disimpan. ID: $result',
      );

      await PreferenceHandler.addLearningNotification(
        title: 'Kehadiran dicatat',
        message:
            'Kehadiran belajarmu hari ini berhasil dicatat.',
      );

      if (!mounted) return;

      setState(() {
        _progressFuture = _loadProgress();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kehadiran hari ini berhasil dicatat.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on TimeoutException {
      debugPrint(
        'Penyimpanan kehadiran mengalami timeout.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Penyimpanan terlalu lama. Coba lagi.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );
      debugPrint('GAGAL SIMPAN KEHADIRAN');
      debugPrint('Email  : $normalizedEmail');
      debugPrint('Status : $status');
      debugPrint('Catatan: $note');
      debugPrint('ERROR  : $error');
      debugPrint(
        '========================================',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kehadiran gagal disimpan.\n$error',
          ),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAttendance = false;
        });
      }
    }
  }

  // ============================================================
  // ATTENDANCE FORM
  // ============================================================

  Future<void> _showAttendanceForm() async {
    if (_isSavingAttendance) {
      return;
    }

    final result =
        await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) {
        return const _AttendanceFormSheet();
      },
    );

    if (!mounted || result == null) {
      return;
    }

    final status =
        result['status']?.trim() ?? 'Hadir';

    final note =
        result['note']?.trim() ?? '';

    await _markAttendance(
      status: status.isEmpty ? 'Hadir' : status,
      note: note,
    );
  }

  // ============================================================
  // ATTENDANCE HISTORY
  // ============================================================

  Future<void> _showAttendanceHistory() async {
    final email = PreferenceHandler.userEmail;

    if (email == null || email.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email pengguna tidak ditemukan.',
          ),
        ),
      );

      return;
    }

    try {
      final records = await DatabaseHelper.instance
          .getAttendanceForUser(
            email.trim().toLowerCase(),
          );

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (
              context,
              scrollController,
            ) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  24,
                  4,
                  24,
                  28,
                ),
                children: [
                  const Text(
                    'Riwayat kehadiran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    email.trim().toLowerCase(),
                    style: const TextStyle(
                      color: Color(0xFF68736F),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (records.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 30,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 48,
                            color: Color(0xFF8A9490),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada kehadiran tercatat.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...records.reversed.map(
                      (record) {
                        final hasNote =
                            record.note.trim().isNotEmpty;

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  const Color(0xFFE6F5DA),
                              child: Icon(
                                record.status == 'Hadir'
                                    ? Icons
                                        .check_circle_rounded
                                    : Icons
                                        .event_note_rounded,
                                color:
                                    const Color(0xFF3F7D27),
                              ),
                            ),
                            title: Text(
                              record.date,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              hasNote
                                  ? '${record.status} · ${record.note}'
                                  : record.status,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Gagal mengambil riwayat kehadiran: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Riwayat kehadiran gagal dimuat.\n$error',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  // ============================================================
  // OPEN COURSE
  // ============================================================

  Future<void> _openCourse(String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(
          title: title,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _progressFuture = _loadProgress();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LearningProgress>(
      future: _progressFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Data pembelajaran gagal dimuat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF68736F),
                    ),
                  ),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: reload,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Coba lagi',
                    ),
                  ),
                ],
              ),
            ),
          );
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

        return RefreshIndicator(
          onRefresh: reload,

          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.all(20),

            children: [
              const Text(
                'Pantau perjalanan belajarmu di sini.',
                style: TextStyle(
                  color: Color(0xFF68736F),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // KEHADIRAN
              // ==================================================

              Card(
                margin: EdgeInsets.zero,
                color: const Color(0xFFE6F5DA),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

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
                        '${progress.attendance.length} kali hadir · '
                        '${progress.streak} hari streak',
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed:
                                  progress.attendedToday ||
                                          _isSavingAttendance
                                      ? null
                                      : _showAttendanceForm,

                              icon: _isSavingAttendance
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      progress.attendedToday
                                          ? Icons
                                              .check_circle_rounded
                                          : Icons
                                              .how_to_reg_rounded,
                                    ),

                              label: Text(
                                _isSavingAttendance
                                    ? 'Menyimpan...'
                                    : progress.attendedToday
                                        ? 'Sudah hadir'
                                        : 'Hadir hari ini',
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          IconButton(
                            tooltip:
                                'Riwayat kehadiran',
                            onPressed:
                                _showAttendanceHistory,
                            icon: const Icon(
                              Icons.history_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // STAT KELAS
              // ==================================================

              _StatCard(
                icon: Icons.play_lesson_rounded,
                value:
                    '${progress.started} kelas',
                label: 'Kelas dimulai',
                color:
                    const Color(0xFFFFE8C9),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // STAT MATERI
              // ==================================================

              _StatCard(
                icon:
                    Icons.check_circle_outline_rounded,
                value:
                    '${progress.completed} materi',
                label: 'Materi selesai',
                color:
                    const Color(0xFFE6F5DA),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // STAT KELAS TUNTAS
              // ==================================================

              _StatCard(
                icon:
                    Icons.workspace_premium_outlined,
                value:
                    '${progress.certificates} kelas',
                label: 'Kelas tuntas',
                color:
                    const Color(0xFFE8EEF9),
              ),

              const SizedBox(height: 28),

              const _SectionTitle(
                title: 'Lanjutkan belajar',
              ),

              const SizedBox(height: 12),

              // ==================================================
              // COURSE LIST
              // ==================================================

              ..._materials.entries.map(
                (entry) {
                  final lessons = entry.value;

                  final count =
                      (progress.courseProgress[
                                  entry.key] ??
                              0)
                          .clamp(
                            0,
                            lessons.length,
                          )
                          .toInt();

                  final progressValue =
                      lessons.isEmpty
                          ? 0.0
                          : count /
                              lessons.length;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),

                    child: Card(
                      child: ListTile(
                        onTap: () =>
                            _openCourse(
                          entry.key,
                        ),

                        leading: CircleAvatar(
                          child: Text(
                            '$count/${lessons.length}',
                            style:
                                const TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),

                        title: Text(
                          entry.key,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                          ),
                          child:
                              LinearProgressIndicator(
                            value:
                                progressValue,
                            minHeight: 6,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                          ),
                        ),

                        trailing:
                            const Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          size: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================================================================
// ATTENDANCE FORM
// ================================================================

class _AttendanceFormSheet
    extends StatefulWidget {
  const _AttendanceFormSheet();

  @override
  State<_AttendanceFormSheet>
      createState() =>
          _AttendanceFormSheetState();
}

class _AttendanceFormSheetState
    extends State<_AttendanceFormSheet> {
  final _formKey =
      GlobalKey<FormState>();

  final _noteController =
      TextEditingController();

  String _selectedStatus = 'Hadir';

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    if (!(_formKey.currentState
            ?.validate() ??
        false)) {
      return;
    }

    FocusManager.instance.primaryFocus
        ?.unfocus();

    Navigator.of(context).pop(
      {
        'status': _selectedStatus,
        'note':
            _noteController.text.trim(),
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        MediaQuery.viewInsetsOf(
              context,
            ).bottom +
            24,
      ),

      child: SafeArea(
        top: false,

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [
                const Text(
                  'Form absensi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Tanggal: ${DateTime.now().toIso8601String().substring(0, 10)}',
                  style: const TextStyle(
                    color: Color(0xFF68736F),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // STATUS
                // ==================================================

                DropdownButtonFormField<String>(
                  initialValue:
                      _selectedStatus,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Status kehadiran',
                    border:
                        OutlineInputBorder(),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: 'Hadir',
                      child:
                          Text('Hadir'),
                    ),
                    DropdownMenuItem(
                      value: 'Izin',
                      child:
                          Text('Izin'),
                    ),
                    DropdownMenuItem(
                      value: 'Sakit',
                      child:
                          Text('Sakit'),
                    ),
                  ],

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedStatus =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // ==================================================
                // NOTE
                // ==================================================

                TextFormField(
                  controller:
                      _noteController,

                  maxLines: 3,

                  textInputAction:
                      TextInputAction.done,

                  decoration:
                      InputDecoration(
                    labelText:
                        _selectedStatus ==
                                'Hadir'
                            ? 'Catatan (opsional)'
                            : 'Keterangan ${_selectedStatus.toLowerCase()}',

                    alignLabelWithHint:
                        true,

                    border:
                        const OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (_selectedStatus !=
                            'Hadir' &&
                        (value == null ||
                            value
                                .trim()
                                .isEmpty)) {
                      return 'Keterangan ${_selectedStatus.toLowerCase()} wajib diisi';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // SAVE
                // ==================================================

                FilledButton.icon(
                  onPressed: _submit,

                  icon: const Icon(
                    Icons.save_outlined,
                  ),

                  label: const Text(
                    'Simpan absensi',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LEARNING PROGRESS
// ================================================================

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

  final Map<String, int>
      courseProgress;

  final List<String> attendance;

  final int streak;

  final bool attendedToday;
}
