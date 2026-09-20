part of '../home_screen.dart';

class _ExplorePage extends StatefulWidget {
  const _ExplorePage({super.key});

  @override
  State<_ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<_ExplorePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final isSearching = query.isNotEmpty;
    final matchingCourses = _coursesByCategory.values
        .expand((courses) => courses)
        .where(
          (course) =>
              course.title.toLowerCase().contains(query) ||
              course.subtitle.toLowerCase().contains(query),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        const Text(
          'Temukan materi yang cocok untukmu.',
          style: TextStyle(color: Color(0xFF68736F), fontSize: 15),
        ),

        const SizedBox(height: 18),

        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari kelas atau topik',

            prefixIcon: const Icon(Icons.search_rounded),

            suffixIcon: isSearching
                ? IconButton(
                    tooltip: 'Hapus pencarian',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,

            filled: true,

            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 24),

        const _SectionTitle(title: 'Kategori populer'),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CategoryChip(
              label: 'Programming',
              icon: Icons.code_rounded,
              onTap: () => _openCategory(context, 'Programming'),
            ),

            _CategoryChip(
              label: 'Design',
              icon: Icons.palette_outlined,
              onTap: () => _openCategory(context, 'Design'),
            ),

            _CategoryChip(
              label: 'Bisnis',
              icon: Icons.insights_rounded,
              onTap: () => _openCategory(context, 'Bisnis'),
            ),

            _CategoryChip(
              label: 'Soft skill',
              icon: Icons.groups_rounded,
              onTap: () => _openCategory(context, 'Soft skill'),
            ),
          ],
        ),

        const SizedBox(height: 28),

        _SectionTitle(
          title: isSearching ? 'Hasil pencarian' : 'Kelas pilihan',
        ),

        const SizedBox(height: 12),

        if (isSearching && matchingCourses.isEmpty)
          const Text(
            'Kelas atau topik tidak ditemukan.',
            style: TextStyle(color: Color(0xFF68736F)),
          ),

        if (isSearching) ...matchingCourses.map(
          (course) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CourseTile(
              icon: course.icon,
              title: course.title,
              subtitle: course.subtitle,
              color: course.color,
              onTap: () => _openCourse(context, course.title),
            ),
          ),
        ),

        if (!isSearching) _CourseTile(
          icon: Icons.phone_android_rounded,
          title: 'Membangun Aplikasi Mobile',
          subtitle: '8 materi Â· Pemula',
          color: const Color(0xFFE6F5DA),
          onTap: () => _openCourse(context, 'Membangun Aplikasi Mobile'),
        ),

        if (!isSearching) const SizedBox(height: 10),

        if (!isSearching) _CourseTile(
          icon: Icons.data_object_rounded,
          title: 'Logika dan Algoritma',
          subtitle: '8 materi Â· Dasar',
          color: const Color(0xFFFFE8C9),
          onTap: () => _openCourse(context, 'Logika dan Algoritma'),
        ),
      ],
    );
  }

  void _openCourse(BuildContext context, String title) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CourseDetailScreen(title: title)),
  );

  void _openCategory(BuildContext context, String category) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CategoryCoursesScreen(category: category),
    ),
  );
}

class CategoryCoursesScreen extends StatelessWidget {
  const CategoryCoursesScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final courses = _coursesByCategory[category] ?? const <_CourseInfo>[];

    return Scaffold(
      appBar: AppBar(title: Text('Materi $category')),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Text(
            'Pilih materi ${category.toLowerCase()} yang ingin dipelajari.',
            style: const TextStyle(color: Color(0xFF68736F)),
          ),

          const SizedBox(height: 18),

          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 10),

              child: _CourseTile(
                icon: course.icon,

                title: course.title,

                subtitle: course.subtitle,

                color: course.color,

                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(title: course.title),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseInfo {
  const _CourseInfo(this.title, this.subtitle, this.icon, this.color);

  final String title;

  final String subtitle;

  final IconData icon;

  final Color color;
}

const _coursesByCategory = <String, List<_CourseInfo>>{
  'Programming': [
    _CourseInfo(
      'Dasar Pemrograman',
      '8 materi Â· Pemula',
      Icons.code_rounded,
      Color(0xFFE8EEF9),
    ),

    _CourseInfo(
      'Membangun Aplikasi Mobile',
      '8 materi Â· Pemula',
      Icons.phone_android_rounded,
      Color(0xFFE6F5DA),
    ),

    _CourseInfo(
      'Logika dan Algoritma',
      '8 materi Â· Dasar',
      Icons.data_object_rounded,
      Color(0xFFFFE8C9),
    ),
  ],

  'Design': [
    _CourseInfo(
      'UI/UX untuk Pemula',
      '8 materi Â· Pemula',
      Icons.design_services_rounded,
      Color(0xFFFFE9E2),
    ),
  ],

  'Bisnis': [
    _CourseInfo(
      'Dasar Bisnis Digital',
      '8 materi Â· Pemula',
      Icons.storefront_rounded,
      Color(0xFFFFE8C9),
    ),
  ],

  'Soft skill': [
    _CourseInfo(
      'Komunikasi Profesional',
      '8 materi Â· Pemula',
      Icons.groups_rounded,
      Color(0xFFE6F5DA),
    ),
  ],
};
