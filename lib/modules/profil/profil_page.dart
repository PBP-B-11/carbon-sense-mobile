import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'profile_api.dart';
import 'profile_auth_page.dart';
import 'profile_dashboard.dart';
import 'profile_dialogs.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key, this.client});

  final http.Client? client;

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late final _api = ProfileApi(widget.client ?? http.Client());
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _bio = TextEditingController();
  final _password = TextEditingController();

  // shortcut: sesi bertahan selama aplikasi terbuka, gunakan penyimpanan aman untuk sesi lintas peluncuran.
  String? _token;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _weather;
  ProfileCity? _pendingCity;
  bool _weatherFailed = false;
  bool _busy = false;

  String get _city => _profile?['city_name'] as String? ?? '';

  @override
  void dispose() {
    if (widget.client == null) _api.client.close();
    _email.dispose();
    _bio.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object>? body,
  }) => _api.request(method, path, token: _token, body: body);

  Future<void> _run(Future<void> Function() action) async {
    if (!mounted || _busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on ProfileApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) _clearSession();
      _notify(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notify(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _login() async {
    final token = await Navigator.of(context).push(
      MaterialPageRoute<String>(builder: (_) => ProfileAuthPage(api: _api)),
    );
    if (token == null || !mounted) return;
    await _run(() async {
      setState(() => _token = token);
      await _loadProfile();
    });
  }

  Future<void> _logout() => _run(() async {
    await _request('POST', 'auth/logout/');
    if (mounted) _clearSession();
  });

  void _clearSession() {
    FocusManager.instance.primaryFocus?.unfocus();
    _email.clear();
    _bio.clear();
    _password.clear();
    setState(() {
      _token = null;
      _profile = null;
      _weather = null;
      _pendingCity = null;
      _weatherFailed = false;
    });
  }

  Future<void> _loadProfile() async {
    final profile = await _request('GET', 'profile/');
    if (!mounted) return;
    _email.text = profile['email'] as String? ?? '';
    _bio.text = profile['bio'] as String? ?? '';
    setState(() => _profile = profile);
    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    if (_city.isEmpty) return;
    try {
      final response = await _request('GET', 'profile/environment/');
      if (!mounted) return;
      setState(() {
        _weather = response['snapshot'] as Map<String, dynamic>?;
        _weatherFailed = false;
      });
    } on ProfileApiException catch (error) {
      if (error.statusCode == 401) rethrow;
      if (mounted) setState(() => _weatherFailed = true);
    }
  }

  Future<void> _pickCity() async {
    final city = await ProfileCityPicker.show(context, _api);
    if (city != null && mounted) setState(() => _pendingCity = city);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _email.text.trim();
    final bio = _bio.text.trim();
    final newPassword = _password.text;
    final city = _pendingCity;
    final profileChanged =
        email != (_profile?['email'] ?? '') || bio != (_profile?['bio'] ?? '');
    if (!profileChanged && city == null && newPassword.isEmpty) {
      _notify('Belum ada perubahan.');
      return;
    }

    List<String>? credentials;
    if (newPassword.isNotEmpty) {
      credentials = await promptProfileFields(
        context,
        title: 'Konfirmasi kata sandi baru',
        description: 'Kamu perlu masuk kembali setelah kata sandi berubah.',
        action: 'Lanjutkan',
        fields: const [
          ('Kata sandi saat ini', true),
          ('Ulangi kata sandi baru', true),
        ],
      );
      if (credentials == null) return;
      if (credentials[1] != newPassword) {
        _notify('Ulangan kata sandi baru belum cocok.');
        return;
      }
    }

    await _run(() async {
      if (profileChanged) {
        final profile = await _request(
          'PUT',
          'profile/',
          body: {'email': email, 'bio': bio},
        );
        if (!mounted) return;
        _email.text = profile['email'] as String? ?? '';
        _bio.text = profile['bio'] as String? ?? '';
        setState(() => _profile = profile);
      }
      if (city != null) {
        final updated = await _request(
          'PUT',
          'profile/city/',
          body: {'city': city.token},
        );
        if (!mounted) return;
        setState(() {
          _profile = {...?_profile, ...updated};
          _pendingCity = null;
          _weather = null;
          _weatherFailed = false;
        });
        await _loadWeather();
        if (!mounted) return;
      }
      if (credentials != null) {
        await _request(
          'POST',
          'profile/password/',
          body: {
            'old_password': credentials[0],
            'new_password1': newPassword,
            'new_password2': credentials[1],
          },
        );
        if (!mounted) return;
        _clearSession();
        _notify('Kata sandi diubah. Silakan masuk kembali.');
      } else {
        _notify('Perubahan disimpan.');
      }
    });
  }

  Future<void> _delete() async {
    final fields = await promptProfileFields(
      context,
      title: 'Hapus akun?',
      description: 'Masukkan kata sandi untuk menghapus akun dan seluruh datanya secara permanen.',
      action: 'Hapus akun',
      fields: const [('Kata sandi saat ini', true)],
      destructive: true,
    );
    if (fields == null) return;
    await _run(() async {
      await _request(
        'DELETE',
        'profile/',
        body: {'password': fields[0], 'confirm': true},
      );
      if (!mounted) return;
      _clearSession();
      _notify('Akun dihapus.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _profile != null && !_busy;
    final weatherStatus = switch ((_token, _city, _weatherFailed, _busy)) {
      (null, _, _, _) => 'Masuk untuk melihat cuaca dan udara di kotamu.',
      (_, '', _, _) => 'Pilih kota domisili untuk melihat data lingkungan.',
      (_, _, true, _) => 'Data lingkungan gagal dimuat.',
      (_, _, _, true) => 'Memuat data lingkungan…',
      _ => 'Data kualitas udara belum tersedia.',
    };

    return SafeArea(
      bottom: false,
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontFamily: 'Figtree',
          fontSize: 15,
          color: profileInk,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: profileWidth),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Stack(
                children: [
                  Positioned(
                    right: -152,
                    top: -162,
                    child: Container(
                      width: 368,
                      height: 366,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6EAEF),
                        borderRadius: BorderRadius.circular(160),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -188,
                    top: 590,
                    child: Container(
                      width: 268,
                      height: 350,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6DCC6),
                        borderRadius: BorderRadius.circular(160),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(),
                        const SizedBox(height: 28),
                        const Text(
                          'Modul 2, Profil dan Udara',
                          style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF0D5267),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Semantics(
                          header: true,
                          // Keep the line break visual so the heading is read as one phrase.
                          label: 'Profil dan lingkungan',
                          excludeSemantics: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Profil dan', style: profileHeading(42)),
                              Stack(
                                children: [
                                  const Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 5,
                                    height: 6,
                                    child: ColoredBox(color: Color(0xFF118DC8)),
                                  ),
                                  Text('lingkungan', style: profileHeading(42)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_busy)
                          const LinearProgressIndicator(
                            semanticsLabel: 'Memuat profil',
                          ),
                        if (_profile == null && _token != null && !_busy)
                          TextButton(
                            onPressed: () => _run(_loadProfile),
                            child: const Text('Muat ulang profil'),
                          ),
                        ProfileSummary(profile: _profile),
                        const SizedBox(height: 18),
                        ProfileWeather(
                          city: _city,
                          snapshot: _weather,
                          status: weatherStatus,
                          onRetry: !_busy && _weatherFailed
                              ? () => _run(_loadWeather)
                              : null,
                        ),
                        const SizedBox(height: 18),
                        _editCard(canEdit),
                        const SizedBox(height: 18),
                        _dangerCard(canEdit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
    children: [
      Container(
        width: 41,
        height: 41,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: profileGreen,
          border: Border.all(color: profileInk, width: 2),
        ),
        child: const Icon(Icons.eco_outlined, size: 20, color: profilePaper),
      ),
      const SizedBox(width: 11),
      Expanded(child: Text('Carbon Sense', style: profileHeading(22))),
      const SizedBox(width: 8),
      OutlinedButton(
        onPressed: _busy
            ? null
            : _token == null
            ? _login
            : _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: profileInk,
          backgroundColor: profilePaper,
          side: const BorderSide(color: profileInk, width: 2),
        ),
        child: Text(_token == null ? 'Masuk' : 'Keluar'),
      ),
    ],
  );

  Widget _editCard(bool canEdit) => ProfileCard(
    radius: const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(48),
      bottomRight: Radius.circular(34),
      bottomLeft: Radius.circular(38),
    ),
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Ubah profil', style: profileHeading(23)),
          ),
          const SizedBox(height: 16),
          _field(
            'Email',
            _email,
            enabled: canEdit,
            keyboard: TextInputType.emailAddress,
            hint: 'nama@contoh.id',
            validator: (value) =>
                value != null &&
                    value.trim().isNotEmpty &&
                    !value.trim().contains('@')
                ? 'Masukkan alamat email yang valid.'
                : null,
          ),
          const SizedBox(height: 12),
          _label('Kota domisili'),
          OutlinedButton(
            onPressed: canEdit ? _pickCity : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              side: const BorderSide(color: Color(0xFF8A7D60)),
              foregroundColor: profileInk,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _pendingCity?.label ??
                        (_city.isEmpty ? 'Pilih kota' : _city),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, size: 19),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _field(
            'Bio',
            _bio,
            enabled: canEdit,
            lines: 3,
            hint: 'Ceritakan sedikit tentang dirimu',
          ),
          const SizedBox(height: 12),
          _field(
            'Kata sandi baru',
            _password,
            enabled: canEdit,
            secret: true,
            hint: 'Kosongkan bila tidak diubah',
          ),
          const SizedBox(height: 15),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: canEdit
                  ? const [BoxShadow(color: profileInk, offset: Offset(0, 4))]
                  : null,
            ),
            child: FilledButton(
              onPressed: canEdit ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: profileGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(49),
                side: BorderSide(
                  color: canEdit ? profileInk : profileLine,
                  width: 2,
                ),
              ),
              child: const Text(
                'Simpan perubahan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    ),
  );

  Widget _dangerCard(bool canEdit) => ProfileCard(
    border: const Color(0xFFF5B7AD),
    radius: BorderRadius.circular(31),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Zona berbahaya',
            style: profileHeading(23, color: profileDanger),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Menghapus akun akan menghapus semua log, tantangan, dan postinganmu secara permanen.',
          style: TextStyle(color: profileMuted, height: 1.5),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: canEdit ? _delete : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: profileDanger,
            side: BorderSide(
              color: canEdit ? profileDanger : const Color(0xFFF5B7AD),
              width: 1.5,
            ),
          ),
          child: const Text(
            'Hapus akun',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Widget _label(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    required bool enabled,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    int lines = 1,
    bool secret = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(child: _label(label)),
      Semantics(
        label: label,
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboard,
          maxLines: lines,
          obscureText: secret,
          enableSuggestions: !secret,
          autocorrect: !secret && keyboard != TextInputType.emailAddress,
          style: const TextStyle(
            fontFamily: 'Figtree',
            color: profileInk,
            fontSize: 15,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: profileMuted),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFF8A7D60)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: profileLine),
            ),
          ),
        ),
      ),
    ],
  );
}
