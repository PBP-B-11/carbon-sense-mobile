import 'package:flutter/material.dart';

import 'profile_api.dart';
import 'profile_dashboard.dart';
import 'profile_dialogs.dart';

class ProfileAuthPage extends StatefulWidget {
  const ProfileAuthPage({super.key, required this.api});

  final ProfileApi api;

  @override
  State<ProfileAuthPage> createState() => _ProfileAuthPageState();
}

class _ProfileAuthPageState extends State<ProfileAuthPage> {
  var _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  ProfileCity? _city;
  bool _registering = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _toggleMode() {
    FocusScope.of(context).unfocus();
    _password.clear();
    _confirmation.clear();
    setState(() {
      _registering = !_registering;
      _form = GlobalKey<FormState>();
      _error = null;
    });
  }

  Future<void> _pickCity(FormFieldState<ProfileCity> field) async {
    final city = await ProfileCityPicker.show(context, widget.api);
    if (city == null || !mounted || !field.mounted) return;
    _city = city;
    field.didChange(city);
    field.validate();
  }

  Future<void> _submit() async {
    if (_submitting || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final account = await widget.api.request(
        'POST',
        _registering ? 'auth/register/' : 'auth/login/',
        body: {
          'username': _username.text.trim(),
          if (_registering) ...{
            'email': _email.text.trim(),
            'city': _city!.token,
            'password1': _password.text,
            'password2': _confirmation.text,
          } else
            'password': _password.text,
        },
      );
      if (!mounted) return;
      final token = account['token'];
      if (token is! String || token.isEmpty) {
        throw const ProfileApiException(
          'Sesi masuk tidak dapat dibuat. Coba masuk kembali.',
        );
      }
      Navigator.of(context).pop(token);
    } on ProfileApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = _registering ? 'Daftar' : 'Masuk';

    return PopScope(
      canPop: !_submitting,
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'Figtree'),
          inputDecorationTheme: InputDecorationThemeData(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: profileInk,
          ),
          body: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: profileWidth),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    ProfileCard(
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                _registering
                                    ? 'Daftar akun'
                                    : 'Masuk ke Carbon Sense',
                                style: profileHeading(32),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _field('Nama pengguna', _username),
                            if (_registering) ...[
                              const SizedBox(height: 12),
                              _field(
                                'Email',
                                _email,
                                keyboard: TextInputType.emailAddress,
                                validate: (value) => value.contains('@')
                                    ? null
                                    : 'Masukkan alamat email yang valid.',
                              ),
                              const SizedBox(height: 12),
                              _cityField(),
                            ],
                            const SizedBox(height: 12),
                            _field(
                              'Kata sandi',
                              _password,
                              secret: true,
                              isLast: !_registering,
                            ),
                            if (_registering) ...[
                              const SizedBox(height: 12),
                              _field(
                                'Konfirmasi kata sandi',
                                _confirmation,
                                secret: true,
                                isLast: true,
                                validate: (value) => value == _password.text
                                    ? null
                                    : 'Kata sandi belum cocok.',
                              ),
                            ],
                            if (_error case final error?) ...[
                              const SizedBox(height: 12),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  error,
                                  style: const TextStyle(color: profileDanger),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            if (_submitting)
                              LinearProgressIndicator(
                                semanticsLabel: 'Sedang memproses $action',
                              ),
                            FilledButton(
                              onPressed: _submitting ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: profileGreen,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: Text(action),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: _submitting ? null : _toggleMode,
                              child: Text(
                                _registering
                                    ? 'Sudah punya akun? Masuk'
                                    : 'Belum punya akun? Daftar',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cityField() => FormField<ProfileCity>(
    initialValue: _city,
    validator: (city) => city == null ? 'Pilih kota domisili.' : null,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Kota domisili'),
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: _submitting ? null : () => _pickCity(field),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: profileInk,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(field.value?.label ?? 'Pilih kota')),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
        if (field.errorText case final error?)
          Text(error, style: const TextStyle(color: profileDanger)),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    bool secret = false,
    bool isLast = false,
    String? Function(String)? validate,
  }) => TextFormField(
    controller: controller,
    enabled: !_submitting,
    decoration: InputDecoration(labelText: label),
    keyboardType: keyboard,
    obscureText: secret,
    autocorrect: false,
    enableSuggestions: !secret,
    textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
    onFieldSubmitted: isLast ? (_) => _submit() : null,
    validator: (value) {
      final input = secret ? value ?? '' : value?.trim() ?? '';
      return input.isEmpty ? 'Wajib diisi.' : validate?.call(input);
    },
  );
}
