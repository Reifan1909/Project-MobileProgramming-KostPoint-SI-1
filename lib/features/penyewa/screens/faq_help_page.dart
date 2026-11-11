import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Halaman Pusat Bantuan & FAQ.
///
/// Menampilkan daftar pertanyaan umum seputar cara booking kos,
/// pengelolaan akun, dan fitur tracker kos.
/// Setiap pertanyaan dikelilingi [ExpansionTile] agar jawaban dapat
/// di-expand / di-collapse saat diklik.
class FaqHelpPage extends StatelessWidget {
  final String? category;

  const FaqHelpPage({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          category != null ? 'FAQ $category' : 'Pusat Bantuan & FAQ',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _FAQs.length,
        itemBuilder: (context, index) {
          final faq = _FAQs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FaqExpansionTile(faq: faq),
          );
        },
      ),
    );
  }
}

/// Data model untuk satu entri FAQ.
class _FaqItem {
  final String question;
  final String answer;
  final String categoryLabel;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.categoryLabel,
  });
}

/// Daftar pertanyaan & jawaban FAQ.
const List<_FaqItem> _FAQs = const [
  // Booking Kos
  _FaqItem(
    question: 'Bagaimana cara melakukan booking kos?',
    answer:
        'Buka halaman Katalog atau Peta, pilih kos yang sesuai, klik "Book" pada '
        'detail kos, lalu isi form persyaratan (nama, nim, tanggal masuk, dan lain-lain). '
        'Setelah disubmit, pemilik kos akan menerima notifikasi dan mengonfirmasi. '
        'Status dapat dicek di halaman Favorit atau Profil.',
    categoryLabel: 'Booking Kos',
  ),
  _FaqItem(
    question: 'Apakah biaya booking kos sudah termasuk?',
    answer:
        'Tidak. Biaya booking sepenuhnya ditanggung penyewa. Aplikasi hanya '
        'berperan sebagai perantara informasi dan koordinasi.',
    categoryLabel: 'Booking Kos',
  ),

  // Pengelolaan Akun
  _FaqItem(
    question: 'Bagaimana cara mengganti password akun?',
    answer:
        'Buka Profil > Pengaturan Akun > Ubah Kata Sandi. Masukkan password '
        'lama, password baru, dan konfirmasi. Password baru harus minimal 8 '
        'karakter dengan huruf besar, huruf kecil, dan angka.',
    categoryLabel: 'Pengelolaan Akun',
  ),
  _FaqItem(
    question: 'Apa yang terjadi jika saya lupa password?',
    answer:
        'Klik "Lupa Password" di halaman login, masukkan email terdaftar. '
        'Sistem akan mengirimkan link reset ke email Anda.',
    categoryLabel: 'Pengelolaan Akun',
  ),

  // Tracker Kos
  _FaqItem(
    question: 'Bagaimana cara menggunakan fitur tracker kos?',
    answer:
        'Buka halaman Peta, pilih kos yang ingin dilacak, klik "Tracker". '
        'Fitur ini akan menampilkan lokasi kos pada peta dan perkiraan jarak/ketepatan waktu.',
    categoryLabel: 'Tracker Kos',
  ),

  // Peta Dinamis
  _FaqItem(
    question: 'Apa bedanya pencarian peta dinamis dengan biasa?',
    answer:
        'Pencarian peta dinamis menghitung jarak secara real-time dari titik '
        'tujuan yang dipilih (misal: kampus) ke setiap kos. Urutan hasil akan '
        'berubah saat titik tujuan berubah.',
    categoryLabel: 'Peta Dinamis',
  ),
];

/// Widget expansion tile untuk satu entri FAQ.
class _FaqExpansionTile extends StatelessWidget {
  final _FaqItem faq;

  const _FaqExpansionTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: const Icon(
        Icons.help_outline_rounded,
        color: AppColors.primaryAccent,
        size: 24,
      ),
      title: Text(
        faq.question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        faq.categoryLabel,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.primaryAccent.withValues(alpha: 0.85),
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.vertical(top: const Radius.circular(12)),
            border: Border(
              top: BorderSide(color: AppColors.surfaceBorderSoft, width: 1),
            ),
          ),
          child: SelectableText(
            faq.answer,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondaryMuted,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
