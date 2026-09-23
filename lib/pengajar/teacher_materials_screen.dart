part of devlearning_roles;

class TeacherMaterialsScreen extends StatefulWidget {
  const TeacherMaterialsScreen({super.key});

  @override
  State<TeacherMaterialsScreen> createState() => _TeacherMaterialsScreenState();
}

class _TeacherMaterialsScreenState extends State<TeacherMaterialsScreen> {
  late Future<List<LearningMaterial>> _materials;

  @override
  void initState() {
    super.initState();
    _materials = DatabaseHelper.instance.getMaterials();
  }

  Future<void> _reload() async {
    setState(() => _materials = DatabaseHelper.instance.getMaterials());
    await _materials;
  }

  Future<void> _edit([LearningMaterial? material]) async {
    if (material != null && material.createdBy != PreferenceHandler.userEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi hanya dapat diubah oleh pembuatnya.')),
      );
      return;
    }
    final title = TextEditingController(text: material?.title ?? '');
    final description = TextEditingController(text: material?.description ?? '');
    final content = TextEditingController(text: material?.content ?? '');
    final formKey = GlobalKey<FormState>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(material == null ? 'Tambah materi' : 'Ubah materi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Judul materi'), validator: (value) => value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null),
            const SizedBox(height: 12),
            TextFormField(controller: description, decoration: const InputDecoration(labelText: 'Deskripsi'), validator: (value) => value == null || value.trim().isEmpty ? 'Deskripsi wajib diisi' : null),
            const SizedBox(height: 12),
            TextFormField(controller: content, minLines: 4, maxLines: 8, decoration: const InputDecoration(labelText: 'Isi materi'), validator: (value) => value == null || value.trim().isEmpty ? 'Isi materi wajib diisi' : null),
            const SizedBox(height: 16),
            FilledButton(onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final value = LearningMaterial(id: material?.id, title: title.text, description: description.text, content: content.text, createdBy: PreferenceHandler.userEmail ?? 'pengajar', createdAt: material?.createdAt);
              if (material == null) { await DatabaseHelper.instance.insertMaterial(value); } else { await DatabaseHelper.instance.updateMaterial(value); }
              if (context.mounted) Navigator.pop(context, true);
            }, child: const Text('Simpan')),
          ])),
        ),
      ),
    );
    title.dispose(); description.dispose(); content.dispose();
    if (saved == true) _reload();
  }

  Future<void> _delete(LearningMaterial material) async {
    if (material.id == null) return;
    if (material.createdBy != PreferenceHandler.userEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi hanya dapat dihapus oleh pembuatnya.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus materi?'),
        content: Text('Materi ${material.title} tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DatabaseHelper.instance.deleteMaterial(material.id!);
      await _reload();
    } on DatabaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materi gagal dihapus. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materi pembelajaran'), actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _edit, icon: const Icon(Icons.add), label: const Text('Tambah')),
      body: FutureBuilder<List<LearningMaterial>>(future: _materials, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final materials = snapshot.data ?? [];
        if (materials.isEmpty) return const Center(child: Text('Belum ada materi. Tambahkan materi untuk peserta.'));
        return ListView(padding: const EdgeInsets.all(20), children: materials.map((material) {
          final canManage = material.createdBy == PreferenceHandler.userEmail;
          return Card(child: ListTile(
            leading: const Icon(Icons.menu_book_outlined), title: Text(material.title), subtitle: Text(material.description),
            onTap: canManage ? () => _edit(material) : null,
            trailing: canManage
                ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(material))
                : const Icon(Icons.lock_outline),
          ));
        }).toList());
      }),
    );
  }
}
