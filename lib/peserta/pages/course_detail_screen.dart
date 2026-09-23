part of '../home_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.title, this.content});

  final String title;
  final String? content;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final List<_Lesson> _lessons;

  Set<String> _completed = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _lessons = widget.content?.trim().isNotEmpty == true
        ? [_Lesson('materi-${widget.title}', widget.title, widget.content!)]
        : _materials[widget.title] ?? _defaultMaterials;

    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final saved = _safeCompletedLessons(widget.title);

    final lessonIds = _lessons.map((lesson) => lesson.id).toSet();

    if (mounted) {
      setState(() {
        _completed = saved.where(lessonIds.contains).toSet();

        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLesson(_Lesson lesson, bool isComplete) async {
    setState(() {
      if (isComplete) {
        _completed.add(lesson.id);
      } else {
        _completed.remove(lesson.id);
      }
    });

    await PreferenceHandler.setCompletedLessons(
      widget.title,
      _completed.toList(),
    );

    if (isComplete) {
      await PreferenceHandler.addLearningNotification(
        title: 'Modul selesai',
        message: '${lesson.title} di kelas ${widget.title} telah selesai.',
      );
    }
  }

  Future<void> _openLesson(_Lesson lesson) async {
    final completed = await Navigator.push<bool>(
      context,

      MaterialPageRoute(
        builder: (_) => _MaterialReadingScreen(
          courseTitle: widget.title,

          lesson: lesson,

          isComplete: _completed.contains(lesson.id),
        ),
      ),
    );

    if (completed != null && completed != _completed.contains(lesson.id)) {
      await _toggleLesson(lesson, completed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _lessons.isEmpty
        ? 0.0
        : _completed.length / _lessons.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Muat ulang progres',
            onPressed: _loadProgress,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          Text(
            '${(progress * 100).round()}% selesai',
            style: const TextStyle(color: Color(0xFF68736F)),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(8),
          ),

          const SizedBox(height: 24),

          const Text(
            'Materi kelas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ...List.generate(_lessons.length, (index) {
              final lesson = _lessons[index];

              final completed = _completed.contains(lesson.id);

              return Card(
                child: ListTile(
                  onTap: () => _openLesson(lesson),

                  leading: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_outline_rounded,
                    color: completed ? const Color(0xFF3F7D27) : null,
                  ),

                  title: Text('${index + 1}. ${lesson.title}'),

                  subtitle: Text(completed ? 'Selesai' : 'Buka materi'),

                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MaterialReadingScreen extends StatefulWidget {
  const _MaterialReadingScreen({
    required this.courseTitle,

    required this.lesson,

    required this.isComplete,
  });

  final String courseTitle;

  final _Lesson lesson;

  final bool isComplete;

  @override
  State<_MaterialReadingScreen> createState() => _MaterialReadingScreenState();
}

class _MaterialReadingScreenState extends State<_MaterialReadingScreen> {
  late final bool _isComplete = widget.isComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),

        actions: [
          if (_isComplete)
            TextButton(
              onPressed: () => Navigator.pop(context, false),

              child: const Text('Batalkan'),
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),

                children: [
                  Text(
                    widget.lesson.title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Bacaan modul',
                    style: TextStyle(
                      color: Color(0xFF3F7D27),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Pengertian',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.lesson.content,
                    style: const TextStyle(fontSize: 17, height: 1.7),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Akar konsep',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _courseRoots[widget.courseTitle] ??
                        _courseRoots['default']!,
                    style: const TextStyle(fontSize: 16, height: 1.65),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Contoh penerapan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Saat belajar ${widget.courseTitle}, gunakan konsep â€œ${widget.lesson.title}â€ untuk mengamati masalah nyata, menuliskan langkah yang akan dilakukan, lalu mengevaluasi hasilnya.',
                    style: const TextStyle(fontSize: 16, height: 1.65),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F5DA),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Catatan belajar',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Coba jelaskan kembali inti modul ini dengan bahasamu sendiri sebelum melanjutkan ke materi berikutnya.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),

              child: SizedBox(
                width: double.infinity,

                height: 52,

                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),

                  icon: const Icon(Icons.check_rounded),

                  label: const Text('Tandai modul selesai'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _courseRoots = <String, String>{
  'Dasar Pemrograman': 'Pemrograman berakar pada logika dan cara berpikir komputasional: masalah dipecah menjadi langkah kecil, dicari polanya, lalu ditulis sebagai instruksi yang tepat untuk komputer.',

  'UI/UX untuk Pemula': 'UI/UX berakar pada desain yang berpusat pada manusia. Tujuannya bukan sekadar tampilan menarik, melainkan membantu pengguna menyelesaikan tujuan dengan jelas, mudah, dan konsisten.',

  'Membangun Aplikasi Mobile': 'Aplikasi mobile berakar pada pemecahan masalah pengguna melalui perangkat genggam. Struktur antarmuka, data, dan interaksi harus bekerja bersama secara cepat dan mudah dipahami.',

  'Logika dan Algoritma': 'Algoritma berakar pada penalaran runtut: setiap masalah membutuhkan input yang jelas, langkah terbatas, keputusan yang tepat, serta keluaran yang dapat diperiksa.',

  'Dasar Bisnis Digital': 'Bisnis digital berakar pada penciptaan nilai. Produk perlu menyelesaikan masalah yang nyata, menjangkau pelanggan yang tepat, dan memiliki cara berkelanjutan untuk menghasilkan pendapatan.',

  'Komunikasi Profesional': 'Komunikasi profesional berakar pada kejelasan, empati, dan tanggung jawab. Pesan yang baik membantu orang lain memahami konteks, tindakan yang dibutuhkan, serta alasannya.',

  'default': 'Setiap keterampilan dibangun dari memahami konsep, menghubungkannya dengan masalah nyata, berlatih secara bertahap, dan merefleksikan hasilnya.',
};

class _Lesson {
  const _Lesson(this.id, this.title, this.content);

  final String id;

  final String title;

  final String content;
}

const _defaultMaterials = [
  _Lesson(
    'intro',
    'Pengenalan kelas',
    'Kenali tujuan kelas dan hasil belajar yang akan kamu capai.',
  ),

  _Lesson(
    'concept',
    'Konsep dasar',
    'Pelajari istilah penting dan contoh penerapannya secara bertahap.',
  ),

  _Lesson(
    'practice',
    'Latihan praktik',
    'Coba terapkan konsep yang baru dipelajari pada latihan sederhana.',
  ),
];

const _materials = <String, List<_Lesson>>{
  'Dasar Pemrograman': [
    _Lesson(
      'mindset',
      'Cara berpikir komputasional',
      'Program dibuat dengan memecah masalah, mengenali pola, menyusun langkah, lalu menguji hasilnya.',
    ),

    _Lesson(
      'variables',
      'Variabel dan tipe data',
      'Variabel menyimpan nilai yang bisa digunakan kembali. Mulailah dengan String, int, double, dan bool.',
    ),

    _Lesson(
      'operators',
      'Operator',
      'Operator aritmetika, perbandingan, dan logika digunakan untuk menghitung serta membentuk kondisi.',
    ),

    _Lesson(
      'conditions',
      'Percabangan',
      'Gunakan if, else if, dan else untuk menentukan alur program berdasarkan sebuah kondisi.',
    ),

    _Lesson(
      'loops',
      'Perulangan',
      'Perulangan for dan while membantu menjalankan instruksi berulang tanpa menulis kode yang sama.',
    ),

    _Lesson(
      'function',
      'Fungsi',
      'Fungsi mengelompokkan instruksi yang dapat dipanggil kembali sehingga kode lebih rapi.',
    ),

    _Lesson(
      'collection',
      'List dan Map',
      'Gunakan List untuk kumpulan data berurutan dan Map untuk data yang disimpan dalam pasangan kunci dan nilai.',
    ),

    _Lesson(
      'debug',
      'Debugging dan latihan',
      'Baca pesan error, uji satu bagian kode dalam satu waktu, lalu buat program kecil untuk menggabungkan semua konsep.',
    ),
  ],

  'UI/UX untuk Pemula': [
    _Lesson(
      'user',
      'Memahami pengguna',
      'Tentukan siapa pengguna, masalah yang mereka hadapi, serta tujuan yang ingin mereka capai.',
    ),

    _Lesson(
      'research',
      'Riset pengguna',
      'Kumpulkan temuan melalui wawancara, survei singkat, dan pengamatan agar keputusan desain tidak berdasarkan asumsi.',
    ),

    _Lesson(
      'journey',
      'User journey',
      'Petakan langkah pengguna dari awal sampai tujuan agar hambatan dan peluang perbaikan terlihat jelas.',
    ),

    _Lesson(
      'wireframe',
      'Membuat wireframe',
      'Susun struktur layar sederhana sebelum memilih warna, gambar, atau komponen visual.',
    ),

    _Lesson(
      'hierarchy',
      'Hierarki visual',
      'Gunakan ukuran, kontras, dan jarak untuk mengarahkan perhatian pengguna ke informasi utama.',
    ),

    _Lesson(
      'design-system',
      'Komponen dan konsistensi',
      'Buat komponen berulang seperti tombol, input, dan kartu agar tampilan konsisten serta mudah dikembangkan.',
    ),

    _Lesson(
      'testing',
      'Uji desain',
      'Minta pengguna mencoba tugas singkat lalu catat bagian yang membuat mereka ragu atau berhenti.',
    ),

    _Lesson(
      'handoff',
      'Handoff ke developer',
      'Sertakan ukuran, perilaku komponen, status kosong/error, serta aset agar implementasi sesuai rancangan.',
    ),
  ],

  'Membangun Aplikasi Mobile': [
    _Lesson(
      'setup',
      'Menyiapkan proyek',
      'Buat proyek Flutter, pahami struktur folder lib, dan jalankan aplikasi pada emulator atau perangkat.',
    ),

    _Lesson(
      'widgets',
      'Mengenal widget',
      'Flutter membangun antarmuka dari widget. Bedakan widget statis dengan widget yang dapat berubah karena state.',
    ),

    _Lesson(
      'layout',
      'Menyusun tampilan',
      'Gunakan Scaffold, Column, Row, dan ListView untuk menyusun antarmuka yang responsif.',
    ),

    _Lesson(
      'state',
      'Mengelola state',
      'Gunakan StatefulWidget untuk memperbarui tampilan ketika pengguna berinteraksi dengan aplikasi.',
    ),

    _Lesson(
      'navigation',
      'Navigasi antarhalaman',
      'Gunakan Navigator untuk membuka halaman baru, kembali, dan mengirim hasil dari satu halaman ke halaman lain.',
    ),

    _Lesson(
      'storage',
      'Menyimpan data lokal',
      'Simpan data sederhana dengan SharedPreferences dan data terstruktur menggunakan SQLite.',
    ),

    _Lesson(
      'form',
      'Form dan validasi',
      'Gunakan Form serta validator untuk memastikan pengguna mengisi data yang dibutuhkan sebelum disimpan.',
    ),

    _Lesson(
      'release',
      'Menguji dan merilis',
      'Uji di beberapa ukuran layar, periksa error, lalu siapkan build rilis setelah fungsi utama stabil.',
    ),
  ],

  'Logika dan Algoritma': [
    _Lesson(
      'problem',
      'Memecah masalah',
      'Ubah masalah besar menjadi langkah-langkah kecil yang jelas dan dapat diuji.',
    ),

    _Lesson(
      'flowchart',
      'Flowchart',
      'Gunakan simbol proses, keputusan, dan input-output untuk menggambarkan alur solusi.',
    ),

    _Lesson(
      'pseudocode',
      'Pseudocode',
      'Tuliskan solusi dengan bahasa sederhana dan terstruktur sebelum mengubahnya menjadi kode program.',
    ),

    _Lesson(
      'search',
      'Pencarian data',
      'Bandingkan pencarian linear dengan pencarian biner dan pahami kapan data harus diurutkan terlebih dahulu.',
    ),

    _Lesson(
      'sorting',
      'Pengurutan data',
      'Pelajari ide dasar membandingkan dan menukar data untuk menghasilkan urutan yang benar.',
    ),

    _Lesson(
      'recursion',
      'Rekursi',
      'Rekursi adalah fungsi yang memanggil dirinya sendiri dengan kondisi berhenti yang jelas.',
    ),

    _Lesson(
      'complexity',
      'Efisiensi algoritma',
      'Bandingkan jumlah langkah yang dibutuhkan solusi agar kamu dapat memilih pendekatan yang lebih efisien.',
    ),

    _Lesson(
      'challenge',
      'Tantangan algoritma',
      'Terapkan pemecahan masalah, pseudocode, pencarian, dan pengurutan dalam satu latihan kasus.',
    ),
  ],

  'Dasar Bisnis Digital': [
    _Lesson(
      'idea',
      'Validasi ide',
      'Mulailah dari masalah pelanggan. Wawancarai calon pengguna untuk memastikan solusi yang dibuat benar-benar dibutuhkan.',
    ),

    _Lesson(
      'persona',
      'Persona pelanggan',
      'Rangkum kebutuhan, tujuan, hambatan, dan kebiasaan calon pelanggan dalam persona yang mudah digunakan tim.',
    ),

    _Lesson(
      'value',
      'Proposisi nilai',
      'Jelaskan manfaat utama produk dalam satu kalimat yang mudah dipahami dan membedakannya dari alternatif lain.',
    ),

    _Lesson(
      'market',
      'Mengenal pasar',
      'Tentukan segmen pelanggan, pelajari kebiasaan mereka, lalu pilih kanal yang paling tepat untuk menjangkau mereka.',
    ),

    _Lesson(
      'model',
      'Model bisnis',
      'Tentukan cara produk memberi nilai, memperoleh pendapatan, serta biaya utama yang perlu dikelola.',
    ),

    _Lesson(
      'marketing',
      'Pemasaran digital',
      'Gunakan konten yang relevan, halaman produk yang jelas, dan ajakan bertindak yang dapat diukur hasilnya.',
    ),

    _Lesson(
      'metrics',
      'Mengukur hasil',
      'Pantau metrik sederhana seperti jumlah pelanggan, biaya akuisisi, dan tingkat pelanggan yang kembali menggunakan produk.',
    ),

    _Lesson(
      'pitch',
      'Presentasi bisnis',
      'Sampaikan masalah, solusi, pasar, model bisnis, bukti awal, dan langkah berikutnya secara ringkas.',
    ),
  ],

  'Komunikasi Profesional': [
    _Lesson(
      'listen',
      'Mendengar aktif',
      'Dengarkan sampai selesai, rangkum inti pembicaraan, lalu ajukan pertanyaan untuk memastikan pemahamanmu tepat.',
    ),

    _Lesson(
      'message',
      'Menyusun pesan jelas',
      'Gunakan struktur tujuan, konteks, dan tindakan yang diharapkan agar pesan kerja mudah ditindaklanjuti.',
    ),

    _Lesson(
      'email',
      'Email profesional',
      'Tuliskan subjek yang spesifik, pembuka singkat, informasi inti, tindakan yang diminta, dan penutup yang sopan.',
    ),

    _Lesson(
      'presentation',
      'Presentasi efektif',
      'Susun satu pesan utama, gunakan bukti pendukung, dan akhiri dengan kesimpulan atau keputusan yang jelas.',
    ),

    _Lesson(
      'feedback',
      'Memberi umpan balik',
      'Sampaikan observasi yang spesifik, dampaknya, dan saran perbaikan tanpa menyerang pribadi penerima.',
    ),

    _Lesson(
      'conflict',
      'Mengelola perbedaan',
      'Fokus pada masalah, dengarkan sudut pandang lain, dan cari pilihan solusi yang dapat disepakati bersama.',
    ),

    _Lesson(
      'meeting',
      'Komunikasi rapat',
      'Siapkan agenda, jaga pembahasan tetap fokus, dan tutup rapat dengan keputusan serta penanggung jawab yang jelas.',
    ),

    _Lesson(
      'practice',
      'Simulasi komunikasi',
      'Latih menyampaikan pembaruan pekerjaan, meminta bantuan, dan memberi umpan balik melalui contoh situasi kerja.',
    ),
  ],
};
