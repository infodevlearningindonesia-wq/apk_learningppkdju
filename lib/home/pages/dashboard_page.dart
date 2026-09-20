part of '../home_screen.dart';

class _DashboardPage extends StatefulWidget {
  const _DashboardPage({super.key});

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  late Future<int> _completedFuture;

  @override
  void initState() {
    super.initState();

    _completedFuture = _completedCount();
  }

  Future<int> _completedCount() async {
    var count = 0;

    for (final entry in _materials.entries) {
      final lessonIds = entry.value.map((lesson) => lesson.id).toSet();

      count += _safeCompletedLessons(entry.key)
          .where(lessonIds.contains)
          .toSet()
          .length;
    }

    return count;
  }

  Future<void> reload() async {
    setState(() {
      _completedFuture = _completedCount();
    });
    await _completedFuture;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),

      children: [
        const Text(
          'Selamat datang kembali',
          style: TextStyle(color: Color(0xFF68736F), fontSize: 15),
        ),

        const SizedBox(height: 4),

        Text(
          'Siap belajar hari ini?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF294C1E),
          ),
        ),

        const SizedBox(height: 20),

        FutureBuilder<int>(
          future: _completedFuture,

          builder: (context, snapshot) => Container(
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: const Color(0xFF3F7D27),
              borderRadius: BorderRadius.circular(22),
            ),

            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Teruskan langkahmu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Selesaikan satu materi kecil hari ini.',
                        style: TextStyle(color: Color(0xFFDDF3C9)),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        '${snapshot.data ?? 0} dari ${_totalMaterials()} materi selesai',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.auto_stories_rounded,
                  size: 76,
                  color: Color(0xFFBDEB7E),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        const _SectionTitle(title: 'Akses cepat'),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.play_lesson_rounded,
                title: 'Mulai belajar',
                color: const Color(0xFFE6F5DA),
                onTap: () => _openCourse(context, 'Dasar Pemrograman'),
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: _QuickAction(
                icon: Icons.flag_rounded,
                title: 'Target saya',
                color: const Color(0xFFFFE8C9),
                onTap: () => _showTarget(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        const _SectionTitle(title: 'Rekomendasi untukmu'),

        const SizedBox(height: 12),

        _CourseTile(
          icon: Icons.code_rounded,
          title: 'Dasar Pemrograman',
          subtitle: 'Mulai dari konsep inti coding',
          color: const Color(0xFFE8EEF9),
          onTap: () => _openCourse(context, 'Dasar Pemrograman'),
        ),

        const SizedBox(height: 10),

        _CourseTile(
          icon: Icons.design_services_rounded,
          title: 'UI/UX untuk Pemula',
          subtitle: 'Buat antarmuka yang mudah digunakan',
          color: const Color(0xFFFFE9E2),
          onTap: () => _openCourse(context, 'UI/UX untuk Pemula'),
        ),
      ],
    );
  }

  int _totalMaterials() =>
      _materials.values.fold(0, (total, lessons) => total + lessons.length);

  Future<void> _openCourse(BuildContext context, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(title: title)),
    );

    if (mounted) {
      setState(() {
        _completedFuture = _completedCount();
      });
    }
  }

  void _showTarget(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Target belajar'),
      content: const Text(
        'Selesaikan satu materi hari ini untuk membangun kebiasaan belajar.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Siap'),
        ),
      ],
    ),
  );
}
