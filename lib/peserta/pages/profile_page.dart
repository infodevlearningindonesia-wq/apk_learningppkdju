part of '../home_screen.dart';

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({super.key});

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();

    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final email = PreferenceHandler.userEmail;

    return email == null ? null : DatabaseHelper.instance.getUserByEmail(email);
  }

  Future<void> reload() async {
    setState(() {
      _profileFuture = _loadProfile();
    });
    await _profileFuture;
  }

  Future<void> _editProfile(Map<String, dynamic> profile) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProfileEditScreen(profile: profile)),
    );

    if (changed == true && mounted) {
      setState(() {
        _profileFuture = _loadProfile();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data;

        if (profile == null) {
          return const Center(child: Text('Data profil tidak ditemukan.'));
        }

        return _profileContent(context, profile);
      },
    );
  }

  Widget _profileContent(BuildContext context, Map<String, dynamic> profile) {
    final name = profile['name'] as String? ?? 'Peserta DevLearning';

    final email = profile['email'] as String? ?? '';

    final city = profile['city'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        const CircleAvatar(
          radius: 44,
          backgroundColor: Color(0xFFE6F5DA),
          child: Icon(Icons.person_rounded, size: 48, color: Color(0xFF3F7D27)),
        ),

        const SizedBox(height: 14),

        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 4),

        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF68736F)),
        ),

        if (city.isNotEmpty)
          Text(
            city,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF68736F)),
          ),

        const SizedBox(height: 28),

        Card(
          margin: EdgeInsets.zero,

          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit profil'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _editProfile(profile),
              ),

              const Divider(height: 1, indent: 56),

              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Tentang aplikasi'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.profile});

  final Map<String, dynamic> profile;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;

  late final TextEditingController _email;

  late final TextEditingController _phone;

  late final TextEditingController _city;

  final _picker = ImagePicker();
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(
      text: widget.profile['name'] as String? ?? '',
    );

    _email = TextEditingController(
      text: widget.profile['email'] as String? ?? '',
    );

    _phone = TextEditingController(
      text: widget.profile['phone'] as String? ?? '',
    );

    _city = TextEditingController(
      text: widget.profile['city'] as String? ?? '',
    );

    final imagePath = widget.profile['profile_photo'] as String? ?? '';
    if (imagePath.isNotEmpty) {
      _selectedImage = File(imagePath);
    }
  }

  @override
  void dispose() {
    _name.dispose();

    _email.dispose();

    _phone.dispose();

    _city.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final profilePhoto = _selectedImage?.path ??
          (widget.profile['profile_photo'] as String? ?? '');
      final safeEmail = widget.profile['email'] as String? ?? _email.text;

      await DatabaseHelper.instance.updateUser(
        id: widget.profile['id'] as int,
        name: _name.text,
        email: safeEmail,
        phone: _phone.text,
        city: _city.text,
        profilePhoto: profilePhoto,
      );

      await PreferenceHandler.setUserEmail(safeEmail);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is FormatException
                  ? error.message
                  : 'Email sudah digunakan atau profil gagal disimpan.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profil')),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: const Color(0xFFE6F5DA),
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Color(0xFF3F7D27),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF3F7D27),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _field(_name, 'Nama', Icons.person_outline_rounded),

            const SizedBox(height: 14),

            TextFormField(
              controller: _email,
              readOnly: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                helperText: 'Email tidak dapat diubah',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 14),

            _field(
              _phone,
              'Nomor HP',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 14),

            _field(_city, 'Asal kota', Icons.location_city_outlined),

            const SizedBox(height: 26),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Simpan perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty
              ? '$label wajib diisi'
              : null,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
