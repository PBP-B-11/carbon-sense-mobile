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
| **Administrator (superuser)** | Semua hak pengguna, ditambah mengelola katalog tantangan (tambah, ubah, hapus). |

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

- **URL dasar web service:** `http://faishal-falih-carbon-sense.pws.cs.ui.ac.id/api/mobile/`

### Struktur kode API di repo Django

Kode API mobile dipisah dari kode web, di folder `mobile_api/` dengan satu subfolder per modul, dan semuanya dipasang di `/api/mobile/`. Endpoint web yang sudah ada (misalnya `/api/tantangan/`) tidak diubah.

```
mobile_api/
  urls.py        # rute utama, tempat tiap modul menambah include
  tantangan/     # Eco-Challenges (serializers.py, views.py, urls.py)
  tests/
```

### Autentikasi

> **Belum diputuskan kelompok.** Situs web memakai sesi dan CSRF bawaan Django, dan server produksi mengatur `CSRF_TRUSTED_ORIGINS` untuk `https`. Cara Flutter menyimpan sesi atau token dan menangani CSRF perlu disepakati dengan pemilik Modul 2 (login ada di sana), mengikuti materi Tutorial 07. Perlu dicek juga apakah PWS melayani `http` atau `https`.

---

## Navigasi Aplikasi

Bottom navigation dengan lima tab: **Beranda**, **Tracker**, **Profil**, **Challenges**, dan **Komunitas**. Tiap tab membuka halaman milik modulnya.

---

## Daftar Endpoint Django REST Framework

Semua path berada di bawah `/api/mobile/`. Kolom **Status**:
- **berjalan (lokal)**: sudah dibuat dan lulus tes di komputer pengembang, belum diuji di PWS.
- **rencana**: usulan berdasarkan fitur web yang sudah ada, menunggu pemilik modul membuat dan mengonfirmasi.

### Eco-Challenges (M Naufal Abyaz Bawono)

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET | `tantangan/` | tidak | Daftar tantangan (query `kategori`, `q`, `sort`) | berjalan (lokal) |
| GET | `tantangan/<id>/` | tidak | Detail satu tantangan | berjalan (lokal) |
| POST | `tantangan/<id>/ikut/` | ya | Ikut tantangan (hanya satu tantangan aktif) | berjalan (lokal) |
| POST | `tantangan/<id>/checkin/` | ya | Check-in hari ini (409 bila sudah) | berjalan (lokal) |
| POST | `tantangan/<id>/berhenti/` | ya | Berhenti dari tantangan | berjalan (lokal) |
| GET | `tantangan/aktif/` | ya | Tantangan yang diikuti beserta progres | berjalan (lokal) |
| GET | `lencana/` | tidak | Semua lencana dengan penanda `dimiliki` | berjalan (lokal) |
| GET | `ringkasan/` | ya | Poin, streak, dan hitungan tantangan pengguna | berjalan (lokal) |
| POST | `tantangan/` | admin | Tambah tantangan | rencana |
| PUT/PATCH | `tantangan/<id>/` | admin | Ubah tantangan | rencana |
| DELETE | `tantangan/<id>/` | admin | Hapus tantangan | rencana |

### Beranda (M Naufal Abyaz Bawono)

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET | `beranda/` | opsional | Total emisi minggu ini, tips hari ini, dan berita hangat | rencana |

Bergantung pada data Carbon Tracker (total emisi) dan Green Community (berita).

### Carbon Tracker (Putu Rizki Manik Widiadnyana)

Data: `CarbonActivity` (jenis: `car_travel`, `electricity`, `chicken`, `beef`; jumlah; emisi kg; tanggal; deskripsi).

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET | `aktivitas/` | ya | Riwayat aktivitas pengguna | rencana |
| POST | `aktivitas/estimasi/` | ya | Estimasi emisi tanpa menyimpan | rencana |
| POST | `aktivitas/` | ya | Catat aktivitas baru | rencana |
| GET | `aktivitas/<id>/` | ya | Detail satu aktivitas | rencana |
| PUT/PATCH | `aktivitas/<id>/` | ya | Ubah aktivitas | rencana |
| DELETE | `aktivitas/<id>/` | ya | Hapus aktivitas | rencana |
| GET | `aktivitas/ringkasan/` | ya | Dashboard: total, rincian per kategori, dan grafik (query `period`) | rencana |

### Profil dan Udara (Faishal Falih)

Data: `User` dan `UserProfile` (bio, kota, koordinat).

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| POST | `auth/register/` | tidak | Daftar akun beserta kota | rencana |
| POST | `auth/login/` | tidak | Masuk | rencana |
| POST | `auth/logout/` | ya | Keluar | rencana |
| GET | `profil/` | ya | Lihat profil | rencana |
| PATCH | `profil/` | ya | Ubah email dan bio | rencana |
| GET | `kota/?q=` | tidak | Cari kota | rencana |
| PUT | `profil/kota/` | ya | Ubah kota domisili | rencana |
| POST | `profil/password/` | ya | Ganti kata sandi | rencana |
| DELETE | `profil/` | ya | Hapus akun | rencana |
| GET | `udara/` | ya | Cuaca dan kualitas udara di kota pengguna | rencana |

### Green Community (M. Fatih Danika)

Data: `Post` (kategori `tips`, `diskusi`, `berita`), `Comment`, dan `Like`.

| Metode | Endpoint | Login | Fungsi | Status |
| :--- | :--- | :---: | :--- | :--- |
| GET | `komunitas/postingan/` | tidak | Feed postingan (filter kategori, halaman) | rencana |
| POST | `komunitas/postingan/` | ya | Buat postingan | rencana |
| GET | `komunitas/postingan/<id>/` | tidak | Detail postingan beserta komentar | rencana |
| PATCH | `komunitas/postingan/<id>/` | pemilik | Ubah postingan | rencana |
| DELETE | `komunitas/postingan/<id>/` | pemilik | Hapus postingan | rencana |
| POST | `komunitas/postingan/<id>/like/` | ya | Suka atau batal suka | rencana |
| POST | `komunitas/postingan/<id>/komentar/` | ya | Tambah komentar | rencana |
| PATCH/DELETE | `komunitas/komentar/<id>/` | pemilik | Ubah atau hapus komentar | rencana |
| GET | `komunitas/berita/` | tidak | Berita lingkungan | rencana |
| POST | `komunitas/berita/bagikan/` | ya | Bagikan berita sebagai postingan | rencana |

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
| CI/CD | GitHub Actions: `ruff check`, `ruff format --check`, dan seluruh tes, lalu deploy `main` ke PWS |

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

- Web service: `python manage.py test` (185 tes di branch `main`). Tes API mobile: `python manage.py test mobile_api`.
- Kualitas kode (dijalankan CI): `ruff check .` dan `ruff format --check .`

---

## Repositori Terkait

- Aplikasi mobile Flutter (repositori ini): https://github.com/PBP-B-11/carbon-sense-mobile
- Situs web Django dan web service API (Proyek Tengah Semester): https://github.com/PBP-B-11/carbon-sense
