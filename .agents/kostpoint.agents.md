# Kost Point Mobile - AI Agent Instructions

Dokumen ini merupakan panduan utama dan acuan aturan tunggal (*Single Source of Truth*) untuk seluruh proses pengembangan aplikasi mobile Flutter **"Kost Point"**.

---

## 1. Project Context

- **Nama Aplikasi**: Kost Point Mobile
  - *Deskripsi*: Aplikasi Pencarian Kos Fleksibel Berbasis Peta Dinamis, Kalkulasi Jarak Otomatis, dan Ketersediaan Kamar Real-Time.
- **Framework & State Management**: Flutter (Dart) dengan State Management `provider`.
- **Target Platform**: Android (Material Design 3).
- **Segmentasi Pengguna & Akses**:
  1. **Guest (Tanpa Login)**:
     - Bisa membuka aplikasi dan langsung mencari kos.
     - Bisa menentukan Titik Tujuan (Kampus/Sekolah/Kantor) secara bebas dengan memilih titik (*pin point*) di Google Maps.
     - Bisa melihat daftar kos, detail fasilitas, melihat jarak, dan estimasi waktu tempuh.
  2. **Penyewa (Wajib Login)**:
     - Memiliki semua akses *Guest*.
     - Ditambah fitur interaktif: Memberikan rating, menulis ulasan, dan menghubungi pemilik via WhatsApp. Jika *Guest* menekan tombol ini, munculkan dialog "Silakan Login".
  3. **Pemilik Kos (Wajib Login)**:
     - Dashboard khusus untuk mengelola ketersediaan kamar (sisa vs total kamar).
     - Memasang iklan kos, mengunggah foto, dan **menentukan titik koordinat lokasi kos di peta (*map picker*)**.
     - Manajemen status Pro/Premium.

---

## 2. Color Palette & UI Guidelines

Penggunaan warna **wajib** mengikuti palet berikut secara ketat.

| Nama Variabel / Token | Kode Hex | Peruntukan & Kegunaan |
| :--- | :--- | :--- |
| `backgroundColor` | `#F5F8FA` | Latar belakang utama aplikasi dan layar katalog. |
| `surfaceBorderSoft` | `#E2E2EC` | Latar kartu sekunder, garis pemisah (*divider*), border lembut. |
| `secondaryCardAccent` | `#C9CCB7` | Aksen netral elegan untuk tag fasilitas, chip status ketersediaan. |
| `primaryAccent` | `#7EAAEE` | Biru modern untuk tombol utama, AppBar, dan pin maps aktif. |
| `textSecondaryMuted` | `#878788` | Abu-abu netral untuk teks jarak tempuh, alamat, placeholder. |
| `textPrimary` | `#323335` | Teks utama yang tegas (nama kos, harga, judul). |

### Aturan Desain Antarmuka:
- **Material Design 3**: Aktifkan `useMaterial3: true`.
- **Halaman Autentikasi**: Desain halaman login harus membedakan dengan jelas opsi "Masuk sebagai Penyewa" dan "Masuk sebagai Pemilik Kos" (misal dengan dua tab atau dua tombol besar).
- **Standar Kartu Kos (`KosCard`)**:
  - Wajib ada foto sampul (tinggi 140–160px) dengan `BorderRadius.circular(16)`.
  - Hirarki font (Poppins/Plus Jakarta Sans): **Bold** (Nama/Harga), **Regular** (Jarak/Fasilitas).
- **Interaksi Maps**: Halaman pencarian dan penandaan lokasi harus menggunakan UI Peta interaktif (seperti `google_maps_flutter`).

---

## 3. Agent Rules & Standar Penulisan Kode

### A. Arsitektur Folder (Feature-First)
```text
lib/
├── core/                  # app_colors.dart, app_theme.dart, distance_calculator.dart, dummy_data.dart
├── shared/                # kos_model.dart, user_model.dart, kos_card.dart, map_picker_dialog.dart
├── features/
│   ├── auth/              # login_screen.dart (pemilihan role), auth_provider.dart
│   ├── penyewa/           # beranda_katalog.dart, map_search.dart, detail_kos.dart
│   └── pemilik/           # dashboard_pemilik.dart, tambah_kos_screen.dart (dengan map picker)
└── main.dart              # Setup provider, inisialisasi aplikasi (Route awal ke Beranda Guest)
```
> **Aturan**: Dilarang menumpuk seluruh kode dalam satu file `main.dart`. `main.dart` hanya berisi konfigurasi bootstrap aplikasi. Modul penyewa dapat diimplementasikan di folder `features/penyewa/` (atau `features/mahasiswa/` jika mempertahankan konvensi nama awal).

### B. Aturan Pembuatan Widget & Clean Code
- **Batas Panjang Widget**: Jika file atau build method widget melebihi **80 baris**, widget **wajib** dipecah menjadi sub-widget terpisah (ekstraksi ke file komponen baru atau private `StatelessWidget`).
- **Optimalisasi Const**: Wajib menggunakan keyword `const` pada setiap konstruktor widget statis untuk mencegah rebuild yang tidak perlu.
- **Larangan Hardcode Warna**: Dilarang menuliskan literal `Color(0xFF...)` di dalam file UI. Seluruh pemanggilan warna harus merujuk pada `AppColors` atau `Theme.of(context).colorScheme`.

### C. Pemisahan Logika Bisnis (*Separation of Concerns*)
- Kalkulasi jarak koordinat (misal formula Haversine atau pemanfaatan `geolocator`) dan manipulasi data dilarang ditempatkan langsung di dalam event handler UI (seperti callback `onPressed` atau `onTap`).
- Semua operasi data dan state ketersediaan kamar harus diproses melalui kelas Provider atau Service khusus.

### D. Fitur Prioritas (Kos Pro / Premium)
- Kos yang memiliki properti `isPremium: true` **wajib** secara otomatis disortir ke urutan teratas pada daftar pencarian dan katalog utama.
- Kos Pro wajib diberi visual badge khusus bertuliskan **"PRO / Teratas"** yang mencolok namun harmonis dengan palet warna.

### E. Dependensi Resmi yang Diizinkan
Hanya paket-paket berikut yang diizinkan untuk digunakan dalam proyek ini:
- `provider`: Pengelolaan status (*state management*) reaktif.
- `google_fonts`: Tipografi modern dan konsisten.
- `geolocator`: Pengambilan lokasi pengguna dan perhitungan jarak koordinat.
- `url_launcher`: Integrasi tautan WhatsApp dan rute eksternal.
- `flutter_rating_bar`: Tampilan dan input penilaian bintang kos.

> **Peringatan**: Dilarang menambahkan dependensi/package pihak ketiga lainnya ke dalam `pubspec.yaml` tanpa instruksi eksplisit dari pengguna.

---

## 4. Skills & Workflow Pengembangan

### Definisi Keahlian Spesifik (Core Competencies)
1. **Kalkulasi Estimasi Waktu Tempuh**:
   - Menghitung jarak antara koordinat kos (`latitude`, `longitude`) dengan titik tujuan (gerbang kampus, sekolah, maupun gedung perkantoran).
   - Mengonversi jarak menjadi estimasi waktu tempuh:
     - **Sepeda Motor**: Asumsi kecepatan rata-rata 30–40 km/jam di area perkotaan / sekitar lokasi tujuan.
     - **Jalan Kaki**: Asumsi kecepatan rata-rata 4–5 km/jam (khusus radius dekat < 1.5 km).
2. **Intent Otomatis WhatsApp**:
   - Membuka aplikasi WhatsApp melalui `url_launcher` dengan schema `https://wa.me/{nomor}?text={encoded_message}`.
   - Menyediakan format pesan otomatis yang informatif (mencantumkan nama kos, tipe kamar, serta identitas pencari/penyewa).
3. **Rendering Kartu UI Modern**:
   - Memastikan implementasi `KosCard` selalu proporsional, memiliki cover image berkualitas, badge status ketersediaan yang jelas (misal: *"Tersisa 2 Kamar"*), serta visual badge *"PRO"* untuk item unggulan.

### Workflow Eksekusi Setiap Fitur
```
[1. Pahami Kebutuhan] ──► [2. Buat Komponen Modular] ──► [3. Terapkan Palet Warna] ──► [4. Validasi flutter analyze]
```
1. **Pahami Kebutuhan**: Identifikasi entitas, relasi data, serta peran pengguna (Penyewa: mahasiswa/pelajar/pekerja, atau Pemilik Kos).
2. **Buat Komponen Modular**: Siapkan model, helper logika, dan sub-widget kecil terlebih dahulu sebelum merangkai tampilan layar penuh.
3. **Terapkan Palet Warna**: Pastikan setiap komponen visual patuh 100% pada palet warna `#F5F8FA`, `#E2E2EC`, `#C9CCB7`, `#7EAAEE`, `#878788`, dan `#323335`.
4. **Validasi & Quality Assurance**: Jalankan perintah `flutter analyze` secara berkala untuk memverifikasi tidak ada warning linter, dead code, maupun kesalahan tipe data.

