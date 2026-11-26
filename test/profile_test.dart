import 'dart:convert';

import 'package:carbon_sense_mobile/modules/profil/profil_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('Profile dashboard loads and updates the signed-in account', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var deleteRequests = 0;
    final profile = <String, Object>{
      'username': 'naufal',
      'email': 'naufal@contoh.id',
      'bio': 'Pengguna KRL setia.',
      'city_name': 'Depok',
      'challenge_stats': {
        'poin': 128,
        'diikuti': 1,
        'selesai': 5,
        'lencana': 2,
        'total_lencana': 8,
        'streak': 3,
      },
    };

    http.Response json(Object data) => http.Response(
      jsonEncode(data),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/auth/login/') {
        if (jsonDecode(request.body)['password'] == 'salah') {
          return http.Response(
            jsonEncode({
              'non_field_errors': ['Nama pengguna atau kata sandi salah.'],
            }),
            400,
          );
        }
        expect(jsonDecode(request.body), {
          'username': 'naufal',
          'password': 'kata-sandi-tes',
        });
        return json({'token': 'token-tes'});
      }
      if (path == '/api/v1/profile/cities/') {
        expect(request.url.queryParameters, {'q': 'bogor'});
        return json({
          'results': [
            {'label': 'Bogor, Jawa Barat', 'token': 'token-kota'},
          ],
        });
      }
      expect(request.headers['authorization'], 'Token token-tes');
      switch ((request.method, path)) {
        case ('GET', '/api/v1/profile/'):
          return json(profile);
        case ('GET', '/api/v1/profile/environment/'):
          return json({
            'city_name': profile['city_name'],
            'snapshot': {
              'temperature_2m': 31,
              'relative_humidity_2m': 72,
              'wind_speed_10m': 9,
              'us_aqi': 68,
            },
          });
        case ('PUT', '/api/v1/profile/'):
          final update = jsonDecode(request.body) as Map<String, dynamic>;
          expect(update['bio'], 'Naik kereta setiap hari.');
          profile['bio'] = update['bio'] as String;
          return json(profile);
        case ('PUT', '/api/v1/profile/city/'):
          expect(jsonDecode(request.body), {'city': 'token-kota'});
          profile['city_name'] = 'Bogor';
          return json({'city_name': 'Bogor'});
        case ('DELETE', '/api/v1/profile/'):
          expect(jsonDecode(request.body), {
            'password': 'kata-sandi-tes',
            'confirm': true,
          });
          deleteRequests++;
          return http.Response('', 204);
      }
      fail('Unexpected request ${request.method} $path');
    });
    addTearDown(client.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProfilPage(client: client)),
      ),
    );
    expect(find.text('Profil kamu'), findsOneWidget);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke Carbon Sense'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    Finder field(String label) => find.widgetWithText(TextFormField, label);

    final submit = find.widgetWithText(FilledButton, 'Masuk');
    await tester.enterText(field('Nama pengguna'), 'naufal');
    await tester.enterText(field('Kata sandi'), 'salah');
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Nama pengguna atau kata sandi salah.'), findsOneWidget);
    expect(find.text('naufal'), findsOneWidget);

    await tester.enterText(field('Kata sandi'), 'kata-sandi-tes');
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Pengguna KRL setia.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cuaca dan udara di Depok'), findsOneWidget);
    expect(find.text('Kualitas udara sedang'), findsOneWidget);

    Future<void> show(Finder finder) async {
      await tester.scrollUntilVisible(
        finder,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    final city = find.widgetWithText(OutlinedButton, 'Depok');
    await show(city);
    await tester.tap(city);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Cari nama kota'),
      'bogor',
    );
    await tester.tap(find.byTooltip('Cari'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bogor, Jawa Barat'));
    await tester.pumpAndSettle();

    final bio = find.widgetWithText(TextFormField, 'Pengguna KRL setia.');
    await tester.enterText(bio, 'Naik kereta setiap hari.');
    final save = find.widgetWithText(FilledButton, 'Simpan perubahan');
    await show(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Perubahan disimpan.'), findsOneWidget);
    expect(profile['city_name'], 'Bogor');

    final delete = find.widgetWithText(OutlinedButton, 'Hapus akun');
    await show(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(deleteRequests, 0);

    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.enterText(field('Kata sandi saat ini'), 'kata-sandi-tes');
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus akun'));
    await tester.pumpAndSettle();
    expect(deleteRequests, 1);
    expect(find.text('Akun dihapus.'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(delete).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Register on the same auth page and return signed into Profile', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var registerRequests = 0;
    final client = MockClient((request) async {
      switch ((request.method, request.url.path)) {
        case ('GET', '/api/v1/profile/cities/'):
          expect(request.url.queryParameters, {'q': 'bogor'});
          return http.Response(
            jsonEncode({
              'results': [
                {'label': 'Bogor, Jawa Barat', 'token': 'kota-tes'},
              ],
            }),
            200,
          );
        case ('POST', '/api/v1/auth/register/'):
          registerRequests++;
          expect(jsonDecode(request.body), {
            'username': 'rani',
            'email': 'rani@contoh.id',
            'city': 'kota-tes',
            'password1': 'KataSandiTes123!',
            'password2': 'KataSandiTes123!',
          });
          return http.Response(jsonEncode({'token': 'token-rani'}), 201);
        case ('GET', '/api/v1/profile/'):
          expect(request.headers['authorization'], 'Token token-rani');
          return http.Response(
            jsonEncode({
              'username': 'rani',
              'city_name': 'Bogor',
              'email': 'rani@contoh.id',
              'bio': '',
            }),
            200,
          );
        case ('GET', '/api/v1/profile/environment/'):
          return http.Response(jsonEncode({'snapshot': null}), 200);
      }
      fail('Unexpected request ${request.method} ${request.url.path}');
    });
    addTearDown(client.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProfilPage(client: client)),
      ),
    );
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> enter(String label, String value) async {
      final input = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(input);
      await tester.enterText(input, value);
    }

    await enter('Nama pengguna', 'rani');
    final showRegister = find.text('Belum punya akun? Daftar');
    await tap(showRegister);
    expect(find.text('Daftar akun'), findsOneWidget);
    await tap(find.text('Sudah punya akun? Masuk'));
    expect(find.text('Masuk ke Carbon Sense'), findsOneWidget);
    expect(find.text('rani'), findsOneWidget);
    await tap(showRegister);

    await enter('Email', 'rani@contoh.id');
    await enter('Kata sandi', 'KataSandiTes123!');
    await enter('Konfirmasi kata sandi', 'salah');
    final register = find.widgetWithText(FilledButton, 'Daftar');
    await tap(register);
    expect(find.text('Pilih kota domisili.'), findsOneWidget);
    expect(find.text('Kata sandi belum cocok.'), findsOneWidget);
    expect(registerRequests, 0);

    await tap(find.widgetWithText(OutlinedButton, 'Pilih kota'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Cari nama kota'),
      'bogor',
    );
    await tap(find.byTooltip('Cari'));
    await tap(find.text('Bogor, Jawa Barat'));
    await enter('Konfirmasi kata sandi', 'KataSandiTes123!');
    await tap(register);

    expect(registerRequests, 1);
    expect(find.text('Daftar akun'), findsNothing);
    expect(find.text('@rani'), findsOneWidget);
    expect(find.text('Cuaca dan udara di Bogor'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });
}
