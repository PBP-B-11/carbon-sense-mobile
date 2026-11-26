# Carbon Sense (Aplikasi Mobile)

**Aplikasi mobile pelacak jejak karbon harian dan gamifikasi ramah lingkungan.**

Proyek Akhir Semester Pemrograman Berbasis Platform (CSGE602022), Fakultas Ilmu Komputer Universitas Indonesia, Semester Gasal 2026/2027. Kelompok **PBP B-11**.

> **Situs web (PWS):** http://faishal-falih-carbon-sense.pws.cs.ui.ac.id/
> **Repositori situs web dan web service:** https://github.com/PBP-B-11/carbon-sense

---

## Anggota Kelompok

| Nama | NPM | Modul Tanggung Jawab |
| :--- | :---: | :--- |
| **Putu Rizki Manik Widiadnyana** | 2506621900 | Modul 1: Carbon Tracker |
| **Faishal Falih** | 2506612064 | Modul 2: Profil dan Udara |
| **M Naufal Abyaz Bawono** | 2506656993 | Modul 3: Eco-Challenges |
| **M. Fatih Danika** | 2506532100 | Modul 4: Green Community |

---

## Deskripsi Aplikasi

**Carbon Sense** membantu mahasiswa dan pekerja muda perkotaan mencatat aktivitas harian, menghitung jejak emisi karbon (kg CO₂e), lalu mengubah kebiasaan lewat tantangan harian, pemantauan kualitas udara, dan dukungan komunitas.

Aplikasi ini adalah versi mobile (Flutter) dari situs web Carbon Sense yang dibangun di Proyek Tengah Semester. **Data tetap tersimpan di situs web Django**, dan aplikasi mengaksesnya lewat web service Django REST Framework. Aplikasi tidak memakai data statis di dalam kode.

---

## Daftar Modul dan Pembagian Kerja

Setiap anggota melanjutkan modul yang sama dengan Proyek Tengah Semester.

### 1. Carbon Tracker (Putu Rizki Manik Widiadnyana)
- Mencatat aktivitas harian dengan empat jenis: **perjalanan mobil** (km), **listrik** (kWh), **daging ayam** (gram), dan **daging sapi** (gram). Berat daging adalah perkiraan berat mentah, bukan berat seluruh hidangan.
- Emisi dihitung server lewat **Climatiq API**. Pengguna dapat melihat estimasi sebelum menyimpan.
- Dashboard ringkasan emisi dengan pilihan periode (default `week`), rincian per kategori, grafik, dan riwayat aktivitas.
- **CRUD:** tambah, lihat riwayat, edit, dan hapus aktivitas milik sendiri.

### 2. Profil dan Udara (Faishal Falih)
- Daftar akun (dengan memilih kota domisili), masuk, dan keluar.
- Profil: ubah email dan bio, ganti kata sandi, ganti kota, dan hapus akun.
- Pencarian kota lewat geocoding **Open-Meteo**, dan kartu cuaca dan kualitas udara (suhu, kelembapan, angin, perkiraan US AQI) untuk kota pengguna.
- Halaman profil juga menampilkan ringkasan dari Eco-Challenges: poin, streak, tantangan diikuti dan selesai, serta lencana.

### 3. Eco-Challenges (M Naufal Abyaz Bawono)
- Katalog tantangan dengan filter kategori (transportasi, energi, makanan), pencarian, dan pengurutan.
- Pengguna **ikut** tantangan (hanya satu tantangan aktif pada satu waktu), melakukan **check-in harian** (tidak bisa dua kali sehari), atau **berhenti** di tengah jalan.
- Progres harian, **poin** (dari buku besar `PointEntry`), **streak** berturut-turut, dan **delapan lencana**, termasuk lencana otomatis "Hijau 7 hari" dan "Pejuang 30 hari" dari streak.
- Admin (superuser) dapat menambah, mengubah, dan menghapus tantangan di katalog.
- Data awal diisi dengan `python manage.py seed_tantangan` (6 tantangan dan 8 lencana).

### 4. Green Community (M. Fatih Danika)
- Feed publik dengan tiga kategori postingan: **tips**, **diskusi**, dan **berita**, dengan filter dan halaman per halaman.
- **CRUD postingan** milik sendiri, **komentar** (tambah, ubah, hapus), dan **suka**.
- Berita lingkungan dalam bahasa Indonesia dari **GNews API**, yang bisa dibagikan sebagai postingan.
- Pembatasan frekuensi aksi (cooldown) untuk mencegah spam.

### Beranda
- Menampilkan total emisi minggu ini (dari Carbon Tracker), tips hari ini, empat kartu modul, dan tiga berita terbaru dengan berita cadangan bila GNews gagal.
- Beranda sudah ada di situs web (tanggung jawab M Naufal Abyaz Bawono) dan di aplikasi mobile menjadi tab pertama di kerangka aplikasi.

---

## Peran Pengguna

| Peran | Hak akses |
| :--- | :--- |
| **Tamu** (belum login) | Melihat Beranda, katalog tantangan dan lencana, serta feed komunitas; mendaftar dan masuk. |
| **Pengguna terdaftar** | Mencatat aktivitas, mengikuti tantangan dan check-in, memposting dan berkomentar, serta mengatur profilnya. |
| **Administrator (superuser)** | Mengelola katalog tantangan melalui situs web. Aplikasi mobile mencakup alur pengguna. |

---

## Alur Integrasi Data dengan Situs Web (PWS)

```
Aplikasi Flutter  <--HTTP/JSON-->  Django REST Framework  <-->  Database situs web (PWS)
                                          |
                                          +--> Climatiq, Open-Meteo, GNews (dipanggil server)
```

1. Pengguna berinteraksi dengan halaman Flutter (misalnya membuka daftar tantangan atau menekan tombol Check-in).
2. Aplikasi mengirim request HTTP asinkron ke endpoint Django REST Framework di situs web PWS dari Proyek Tengah Semester.
3. Django memverifikasi pengguna, membaca atau menulis ke **database yang sama dengan situs web**, lalu membalas dengan JSON.
4. Aplikasi mengubah JSON menjadi objek model Dart dan menampilkannya di widget.

Karena memakai database yang sama, data yang diubah di aplikasi langsung terlihat di situs web, dan sebaliknya. Layanan pihak ketiga (Climatiq, Open-Meteo, GNews) hanya dipanggil oleh server, jadi kunci API tidak pernah ada di aplikasi.

- **URL dasar PWS:** `https://faishal-falih-carbon-sense.pws.cs.ui.ac.id/api/v1/`
- URL lokal emulator Android: `http://10.0.2.2:8000/api/v1/`. Untuk perangkat fisik, gunakan alamat IP komputer di jaringan yang sama.

### Struktur kode API di repo Django

Endpoint mobile didaftarkan di `carbon_sense/api_urls.py` dan dipasang di `/api/v1/`. View API berada di `api_views.py` pada aplikasi Django masing-masing (`home`, `profil`, `tracker`, `challenges`, dan `community`), serta memakai model dan layanan backend yang sama dengan situs web.

### Autentikasi

Flutter menggunakan token DRF. Login dan registrasi mengembalikan `token` dan `username`; request terautentikasi mengirim header `Authorization: Token <token>`. Token disimpan di penyimpanan aman perangkat, lalu dihapus saat logout, setelah perubahan kata sandi, atau ketika API membalas `401`. Token backend tidak kedaluwarsa otomatis. Gunakan HTTPS untuk PWS.

---

## Navigasi Aplikasi

Bottom navigation membuka lima halaman terpisah: **Beranda**, **Tracker**, **Profil**, **Challenges**, dan **Komunitas**. Untuk mencoba kerangkanya, jalankan `flutter run` lalu ketuk setiap tab. Halaman modul masih berupa tampilan awal dan belum terhubung ke API.

---

## Daftar Endpoint Django REST Framework

Semua path berada di bawah `/api/v1/`. Endpoint berikut sudah diimplementasikan di backend lokal; tes API ada di `carbon_sense/test_mobile_api.py`. Ketersediaan di PWS belum diverifikasi.

### Eco-Challenges (M Naufal Abyaz Bawono)

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET | `challenges/` | tidak | Daftar tantangan; filter `kategori`, `q`, `sort` | lokal |
| GET | `challenges/<uuid:id>/` | tidak | Detail tantangan | lokal |
| GET | `challenges/progress/` | ya | Progres aktif, poin, streak, dan ringkasan pengguna | lokal |
| GET | `challenges/badges/` | tidak | Lencana; `earned_at` menunjukkan perolehan untuk pengguna terautentikasi | lokal |
| POST | `challenges/<uuid:id>/join/` | ya | Ikut tantangan | lokal |
| POST | `challenges/<uuid:id>/checkin/` | ya | Check-in harian; `409` jika sudah check-in | lokal |
| POST | `challenges/<uuid:id>/leave/` | ya | Berhenti dari tantangan aktif | lokal |

Pengelolaan katalog oleh admin dilakukan melalui situs web; endpoint CRUD admin tidak tersedia di API mobile.

### Beranda (M Naufal Abyaz Bawono)

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET | `home/` | opsional | Ringkasan beranda; data emisi personal mengikuti token jika dikirim | lokal |

Bergantung pada data Carbon Tracker (total emisi) dan Green Community (berita).

### Carbon Tracker (Putu Rizki Manik Widiadnyana)

Data: `CarbonActivity` (jenis: `car_travel`, `electricity`, `chicken`, `beef`; jumlah; emisi kg; tanggal; deskripsi).

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET | `tracker/activities/` | ya | Riwayat aktivitas sendiri (berhalaman) | lokal |
| POST | `tracker/estimate/` | tidak | Estimasi emisi tanpa menyimpan | lokal |
| POST | `tracker/activities/` | ya | Simpan aktivitas baru | lokal |
| GET | `tracker/activities/<id>/` | pemilik | Detail aktivitas sendiri | lokal |
| PUT | `tracker/activities/<id>/` | pemilik | Ganti data aktivitas | lokal |
| DELETE | `tracker/activities/<id>/` | pemilik | Hapus aktivitas | lokal |
| GET | `tracker/dashboard/?period=week` | ya | Total, rincian kategori, dan data grafik; periode `week`, `month`, atau `year` | lokal |

### Profil dan Udara (Faishal Falih)

Data: `User` dan `UserProfile` (bio, kota, koordinat).

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| POST | `auth/register/` | tidak | Daftar dengan `username`, `password1`, `password2`, `email`, dan token pilihan `city` | lokal |
| POST | `auth/login/` | tidak | Masuk dengan username dan kata sandi; mengembalikan token | lokal |
| POST | `auth/logout/` | ya | Cabut token | lokal |
| GET, PUT, DELETE | `profile/` | ya | Baca profil; PUT mengubah `email` dan `bio`; DELETE perlu `password` dan `confirm: true` | lokal |
| GET | `profile/cities/?q=` | tidak | Cari kota; hasil berisi label dan token kota | lokal |
| PUT | `profile/city/` | ya | Ubah kota menggunakan token hasil pencarian | lokal |
| GET | `profile/environment/` | ya | Cuaca dan kualitas udara kota profil | lokal |
| POST | `profile/password/` | ya | Ganti kata sandi; token saat ini dicabut | lokal |

### Green Community (M. Fatih Danika)

Data: `Post` (kategori `tips`, `diskusi`, `berita`), `Comment`, dan `Like`.

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET, POST | `community/posts/` | GET publik, POST ya | Baca feed berhalaman atau buat post `tips`/`diskusi` | lokal |
| GET, PUT, DELETE | `community/posts/<uuid:pk>/` | GET publik, ubah/hapus pemilik | Baca atau kelola post sendiri | lokal |
| PUT, DELETE | `community/posts/<uuid:pk>/like/` | ya | Suka atau batal suka | lokal |
| GET, POST | `community/posts/<uuid:pk>/comments/` | GET publik, POST ya | Baca komentar atau tambah komentar | lokal |
| PUT, DELETE | `community/comments/<id>/` | pemilik | Ubah atau hapus komentar sendiri | lokal |
| GET | `community/news/` | tidak | Baca berita lingkungan | lokal |
| POST | `community/news/share/` | ya | Bagikan berita dari daftar berita | lokal |

Riwayat aktivitas, feed, dan komentar menggunakan pagination `?page=`. ID aktivitas/komentar berupa integer; ID post/tantangan berupa UUID. Respons hapus `204` tidak memiliki body. Check-in ulang dapat membalas `409`; pembatasan frekuensi dapat membalas `429`.

---

## Data Eksternal dan Sumber

- **Climatiq API** (https://www.climatiq.io/docs/api-reference): faktor emisi untuk Carbon Tracker. Estimasi daging memakai faktor CONCITO/2-0 LCA, Big Climate Database v1.2, wilayah Prancis, tahun 2024. Ini perkiraan referensi, bukan faktor khusus Indonesia. Sumber: [Big Climate Database](https://thebigclimatedatabase.com/).
- **Open-Meteo** (https://open-meteo.com/): cuaca, kualitas udara (estimasi model Open-Meteo dan CAMS), dan pencarian kota.
- **GNews API** (https://gnews.io/): berita iklim dan lingkungan berbahasa Indonesia untuk Beranda dan Green Community.

Semua dipanggil oleh server Django dan hasilnya di-cache. Aplikasi mobile tidak memanggil layanan ini secara langsung.

---

## Teknologi

| Lapisan | Teknologi |
| :--- | :--- |
| Aplikasi mobile | Flutter dan Dart (SDK `^3.13.7`), Material |
| Web service | Django 5.2 dan Django REST Framework |
| Basis data | SQLite (lokal) dan PostgreSQL (produksi) |
| Server | gunicorn dan WhiteNoise |
| CI/CD mobile | GitHub Actions untuk analisis dan tes. Bitrise untuk build dan distribusi APK Android debug. |
| CI/CD backend | GitHub Actions untuk Ruff, tes Django, dan deploy `main` ke PWS. |

---

## Struktur Repositori Flutter (usulan)

```
lib/
  main.dart               # titik masuk dan kerangka navigasi
  core/                   # klien HTTP, konfigurasi URL dasar, autentikasi
  modules/
    beranda/
    tracker/              # Modul 1
    profil/               # Modul 2
    challenges/           # Modul 3
    komunitas/            # Modul 4
```

Satu folder per modul agar anggota tidak bentrok saat merge.

---

## Menjalankan Proyek

### Web service (repo Django)

```bash
git clone https://github.com/PBP-B-11/carbon-sense.git
cd carbon-sense
python -m venv env
# Windows (PowerShell): .\env\Scripts\Activate.ps1   |   macOS/Linux: source env/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_tantangan
python manage.py runserver
```

Variabel lingkungan opsional di berkas `.env`: `CLIMATIQ_API_KEY`, `GNEWS_API_KEY`, dan `PRODUCTION`.

### Aplikasi Flutter (repo ini)

```bash
git clone https://github.com/PBP-B-11/carbon-sense-mobile.git
cd carbon-sense-mobile
flutter pub get
flutter run
```

- Dari **emulator Android**, server di komputer yang sama diakses lewat `http://10.0.2.2:8000/` (bukan `localhost`). Tambahkan `10.0.2.2` ke `ALLOWED_HOSTS` di `settings.py` untuk uji lokal.
- Dari **perangkat fisik**, pakai alamat IP komputer di jaringan yang sama, atau langsung URL PWS.

### Pengujian

- Aplikasi mobile: `flutter analyze` dan `flutter test`.
- Web service: `python manage.py test` (185 tes di branch `main`). Tes API mobile: `python manage.py test mobile_api`.
- Kualitas kode (dijalankan CI): `ruff check .` dan `ruff format --check .`

### CI/CD Android

GitHub Actions menjalankan analisis dan tes pada pull request yang menargetkan `main` atau `develop` dan setiap push ke kedua branch itu. Job Bitrise dinonaktifkan sementara. Setelah diaktifkan, GitHub Actions mengantrekan workflow `android_debug` untuk setiap push yang lulus pemeriksaan. Unduh `app-debug.apk` dari tab **Artifacts** pada build Bitrise yang berhasil.

1. Hubungkan repo ini ke proyek Bitrise. Setelah `bitrise.yml` ada di branch default proyek, pilih **Workflows → Change storage**, gunakan penyimpanan di repo, lalu pilih **Validate and save**. Pastikan `bitrise.yml` juga tersedia di branch lain yang akan dibangun. Gunakan GitHub Actions sebagai pemicu otomatis agar tiap push hanya mengantrekan satu build. [Panduan penyimpanan konfigurasi Bitrise](https://docs.bitrise.io/en/bitrise-ci/configure-builds/configuration-yaml/storing-an-apps-configuration-yaml)
2. Di GitHub, buka **Settings → Secrets and variables → Actions**. Tambahkan variable `BITRISE_APP_SLUG` dari URL proyek Bitrise dan secret `BITRISE_API_TOKEN` yang punya akses untuk memicu build proyek itu. [Panduan autentikasi API Bitrise](https://docs.bitrise.io/en/bitrise-ci/api/authenticating-with-the-bitrise-api)
3. Setelah konfigurasi selesai, aktifkan job `deploy` di `.github/workflows/mobile.yml` dengan kondisi `if: github.event_name == 'push'`.

APK ini untuk uji coba internal. Jika tanda tangan debug berbeda dari APK yang sudah terpasang, hapus versi lama sebelum memasang APK baru.

---

## Repositori Terkait

- Aplikasi mobile Flutter (repositori ini): https://github.com/PBP-B-11/carbon-sense-mobile
- Situs web Django dan web service API (Proyek Tengah Semester): https://github.com/PBP-B-11/carbon-sense
