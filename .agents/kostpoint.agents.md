# Kost Point Mobile

Dokumen ini merupakan panduan utama dan acuan aturan tunggal (*Single Source of Truth*) untuk seluruh proses perencanaan, perancangan antarmuka, dan penulisan kode dalam pengembangan aplikasi mobile Flutter **"Kost Point"**.

---

## 1. Project Context

- **Nama Aplikasi**: Kost Point Mobile
  - *Deskripsi*: Aplikasi Pencarian Kos Fleksibel Berbasis Kalkulasi Jarak Otomatis ke Lokasi Tujuan (Kampus, Sekolah, Kantor) dan Ketersediaan Kamar Real-Time.
- **Framework & State Management**: Flutter (Dart) dengan State Management `provider`.
- **Target Platform**: Android (Material Design 3).
- **Segmentasi Pengguna**:
  1. **Penyewa (Mahasiswa, Pelajar, Karyawan / Pekerja Kantor)**:
     - Mencari dan memfilter kos berdasarkan titik tujuan (kampus, sekolah, maupun area kantor), harga, fasilitas, dan tipe (putra/putri/campur).
     - Mengecek estimasi jarak otomatis dan estimasi waktu tempuh (berkendara motor & jalan kaki) ke lokasi tujuan.
     - Melihat rating serta ulasan kos.
     - Menghubungi langsung pemilik kos melalui tombol intent WhatsApp otomatis dengan template pesan yang telah disiapkan.
  2. **Pemilik Kos**:
     - Mengelola inventaris ketersediaan kamar (sisa kamar vs total kamar) secara real-time.
     - Memasang iklan fasilitas kos lengkap dan foto properti.
     - Mengaktifkan status Pro / Premium untuk memprioritaskan penampilan kos di halaman katalog.

---

## 2. Color Palette & UI Guidelines

Penggunaan warna **wajib** mengikuti palet berikut secara konsisten. Dilarang menggunakan warna di luar palet resmi ini untuk elemen struktural utama aplikasi.

| Nama Variabel / Token | Kode Hex | Peruntukan & Kegunaan |
| :--- | :--- | :--- |
| `backgroundColor` | `#F5F8FA` | Latar belakang (*scaffold background*) modern dan bersih untuk halaman utama serta katalog. |
| `surfaceBorderSoft` | `#E2E2EC` | Latar kartu sekunder, border/garis pemisah (*divider*), dan kontur input field lembut. |
| `secondaryCardAccent` | `#C9CCB7` | Aksen netral elegan untuk tag fasilitas, chip status ketersediaan, atau elemen dekoratif sekunder. |
| `primaryAccent` | `#7EAAEE` | Biru modern untuk tombol aksi utama (*ElevatedButton*), header/AppBar, tautan aktif, tab aktif, dan ikon navigasi terpilih. |
| `textSecondaryMuted` | `#878788` | Abu-abu netral untuk teks jarak tempuh, alamat kos, keterangan waktu, dan placeholder. |
| `textPrimary` | `#323335` | Teks utama yang tegas, tajam, dan mudah dibaca (nama kos, harga, judul halaman, dan heading). |

### Aturan Desain Antarmuka:
- **Material Design 3**: Aktifkan `useMaterial3: true` pada `ThemeData`.
- **Standar Kartu Kos (`KosCard`)**:
  - Wajib menampilkan foto sampul (*thumbnail image*) di bagian atas kartu dengan tinggi proporsional **140–160px**.
  - Sudut kartu wajib melengkung lembut dengan `BorderRadius.circular(16)`.
  - **Dilarang** menampilkan kartu kos yang hanya berisi teks tanpa gambar sampul.
- **Hirarki Tipografi**:
  - Gunakan font yang bersih dan terbaca (misal: Poppins atau Plus Jakarta Sans via `google_fonts`).
  - **Bold / Semi-bold** untuk nama kos dan label harga sewa bulanan.
  - **Regular / Medium** untuk keterangan jarak ke lokasi tujuan (kampus, sekolah, kantor), alamat, dan sisa kamar.
- **Konsistensi Spacing**: Terapkan margin dan padding dengan kelipatan 4 atau 8 (8px, 12px, 16px, 24px) untuk menjaga ritme visual.

---

## 3. Agent Rules & Standar Penulisan Kode

Seluruh agen dan pengembang wajib mematuhi standar arsitektur dan penulisan kode berikut:

### A. Arsitektur Folder (Feature-First)
Struktur di dalam `lib/` wajib dipisahkan secara modular:
```text
lib/
├── core/                  # Utilitas global, tema, dan helper
│   ├── constants/         # app_colors.dart, app_sizes.dart, dummy_data.dart
│   ├── theme/             # app_theme.dart (Material 3 Theme)
│   └── utils/             # distance_calculator.dart, url_helper.dart
├── shared/                # Komponen dan model yang dipakai lintas fitur
│   ├── models/            # kos_model.dart, destination_model.dart (kampus, sekolah, kantor)
│   └── widgets/           # kos_card.dart, custom_button.dart, pro_badge.dart
├── features/
│   ├── auth/              # login, registrasi, pemilihan peran (role)
│   ├── penyewa/           # katalog kos, filter lokasi tujuan (kampus/sekolah/kantor), detail kos, kalkulasi jarak
│   └── pemilik/           # dashboard pemilik, edit ketersediaan kamar, manajemen Pro
└── main.dart              # Inisialisasi awal, multi-provider setup, dan router
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

