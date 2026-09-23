part of devlearning_roles;

class RoleProfileScreen extends StatefulWidget {
  const RoleProfileScreen({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<RoleProfileScreen> createState() => _RoleProfileScreenState();
}

class _RoleProfileScreenState extends State<RoleProfileScreen> {
  late Map<String, dynamic> _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _reloadUser() async {
    final email = _user['email'] as String?;
    if (email == null || email.isEmpty) return;

    final refreshed = await DatabaseHelper.instance.getUserByEmail(email);
    if (refreshed != null && mounted) {
      setState(() => _user = refreshed);
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => RoleProfileEditScreen(profile: _user)),
    );

    if (result != null && mounted) {
      setState(() => _user = result);
      await _reloadUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = UserRoleX.fromValue(_user['role'] as String?);
    final profilePhoto = _user['profile_photo'] as String? ?? '';
    final avatarImage = profilePhoto.isNotEmpty ? FileImage(File(profilePhoto)) : null;
    final name = _user['name'] as String? ?? 'Pengguna';
    final email = _user['email'] as String? ?? '';
    final city = _user['city'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFE6F5DA),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Color(0xFF3F7D27),
                    )
                  : null,
            ),
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
                  onTap: _editProfile,
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
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Peran'),
                  trailing: Text(role.label),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Nomor HP'),
                  trailing: Text(_user['phone'] as String? ?? '-'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.location_city_outlined),
                  title: const Text('Asal kota'),
                  trailing: Text(_user['city'] as String? ?? '-'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoleProfileEditScreen extends StatefulWidget {
  const RoleProfileEditScreen({super.key, required this.profile});

  final Map<String, dynamic> profile;

  @override
  State<RoleProfileEditScreen> createState() => _RoleProfileEditScreenState();
}

class _RoleProfileEditScreenState extends State<RoleProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile['name'] as String? ?? '');
    _email = TextEditingController(text: widget.profile['email'] as String? ?? '');
    _phone = TextEditingController(text: widget.profile['phone'] as String? ?? '');
    _city = TextEditingController(text: widget.profile['city'] as String? ?? '');

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

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final profilePhoto = _selectedImage?.path ??
          (widget.profile['profile_photo'] as String? ?? '');
      final safeEmail = widget.profile['email'] as String? ?? _email.text;

      final updated = Map<String, dynamic>.from(widget.profile);
      updated['name'] = _name.text;
      updated['email'] = safeEmail;
      updated['phone'] = _phone.text;
      updated['city'] = _city.text;
      updated['profile_photo'] = profilePhoto;

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
        Navigator.pop(context, updated);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is FormatException
                  ? error.message
                  : 'Profil gagal disimpan. Pastikan email belum dipakai user lain.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _selectedImage != null ? FileImage(_selectedImage!) : null;

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
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(Icons.person_rounded, size: 50, color: Color(0xFF3F7D27))
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
                        icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
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
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Nomor HP',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _city,
              decoration: const InputDecoration(
                labelText: 'Asal kota',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
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
}
