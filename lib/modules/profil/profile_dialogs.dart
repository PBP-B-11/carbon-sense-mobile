import 'package:flutter/material.dart';

import 'profile_api.dart';

Future<List<String>?> promptProfileFields(
  BuildContext context, {
  required String title,
  required String action,
  required List<(String, bool)> fields,
  String? description,
  bool destructive = false,
}) {
  final form = GlobalKey<FormState>();
  final values = List.filled(fields.length, '');
  return showDialog<List<String>>(
    context: context,
    builder: (context) {
      void submit() {
        if (form.currentState!.validate()) Navigator.pop(context, values);
      }

      return AlertDialog(
        title: Text(title),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (description != null) Text(description),
                for (final (index, (label, secret)) in fields.indexed)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: label),
                      obscureText: secret,
                      autocorrect: false,
                      enableSuggestions: !secret,
                      autofocus: index == 0 && !destructive,
                      textInputAction: index == fields.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      validator: (value) =>
                          (secret ? value : value?.trim())?.isNotEmpty == true
                          ? null
                          : 'Wajib diisi',
                      onChanged: (value) =>
                          values[index] = secret ? value : value.trim(),
                      onFieldSubmitted:
                          index == fields.length - 1 && !destructive
                          ? (_) => submit()
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: submit,
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(action),
          ),
        ],
      );
    },
  );
}

typedef ProfileCity = ({String label, String token});

class ProfileCityPicker extends StatefulWidget {
  const ProfileCityPicker({super.key, required this.search});

  final Future<List<ProfileCity>> Function(String) search;

  @override
  State<ProfileCityPicker> createState() => _ProfileCityPickerState();
}

class _ProfileCityPickerState extends State<ProfileCityPicker> {
  final _query = TextEditingController();
  Future<List<ProfileCity>>? _results;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search() {
    final query = _query.text.trim();
    final results = query.length < 2 ? null : widget.search(query);
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Kota domisili'),
    content: SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _query,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Cari nama kota',
              suffixIcon: IconButton(
                tooltip: 'Cari',
                onPressed: _search,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: FutureBuilder<List<ProfileCity>>(
              future: _results,
              builder: (context, snapshot) {
                if (_results == null) {
                  return const Text('Ketik minimal 2 karakter.');
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator(
                    semanticsLabel: 'Mencari kota',
                  );
                }
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  return Text(
                    error is ProfileApiException
                        ? error.message
                        : 'Pencarian gagal.',
                  );
                }
                final cities = snapshot.data!;
                if (cities.isEmpty) return const Text('Kota tidak ditemukan.');
                return ListView(
                  shrinkWrap: true,
                  children: [
                    for (final city in cities)
                      ListTile(
                        title: Text(city.label),
                        onTap: () => Navigator.pop(context, city),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
    ],
  );
}
