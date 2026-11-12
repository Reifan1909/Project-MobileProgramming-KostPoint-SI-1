import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Halaman penjelasan langkah-langkah cara kerja pencarian peta dinamis.
class DynamicMapHelpPage extends StatelessWidget {
  const DynamicMapHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Cara Kerja Pencarian Peta Dinamis',
          style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionIntro(title: 'Bagaimana cara kerja pencarian peta dinamis?'),
            SizedBox(height: 16),
            _DescriptionText(
              text:
                  'Kost Point Mobile menggunakan sistem pencarian berbasis geolokasi dan peta interaktif. Anda dapat mencari kos di sekitar kampus, kantor, atau lokasi pilihan secara real-time dengan akurasi radius dan estimasi rute perjalanan.',
            ),
            SizedBox(height: 20),
            Text(
              'Langkah-Langkah Pencarian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            _StepCard(
              step: '1',
              title: 'Pilih titik tujuan',
              icon: Icons.location_on_outlined,
              color: AppColors.primaryAccent,
              description:
                  'Buka halaman Peta, klik ikon titik lokasi, lalu pilih titik tujuan populer atau ketuk "Ubah Lokasi" untuk mencari titik secara manual.',
            ),
            _StepCard(
              step: '2',
              title: 'Aktifkan filter kos',
              icon: Icons.filter_list_outlined,
              color: AppColors.secondaryCardAccent,
              description:
                  'Aplikasi menampilkan daftar kos di sekitar titik tujuan. Gunakan filter kategori, jenis kamar, gender, dan fasilitas untuk menyempitkan pencarian.',
            ),
            _StepCard(
              step: '3',
              title: 'Hasil diurutkan otomatis',
              icon: Icons.sort_outlined,
              color: AppColors.success,
              description:
                  'Aplikasi menghitung jarak dari titik tujuan ke setiap kos menggunakan algoritma geolokasi. Hasil ditampilkan dari jarak terdekat (terbaik).',
            ),
            _StepCard(
              step: '4',
              title: 'Pantau dengan peta interaktif',
              icon: Icons.map_outlined,
              color: AppColors.primaryAccent,
              description:
                  'Halaman peta menampilkan marker untuk setiap kos yang ditemukan. Anda dapat menggeser (panning), memperbesar/memperkecil (zoom), dan menunjuk marker untuk melihat detail cepat.',
            ),
            _StepCard(
              step: '5',
              title: 'Lacak lokasi kos Anda',
              icon: Icons.track_changes_outlined,
              color: AppColors.premiumGold,
              description:
                  'Klik "Tracker" pada halaman detail kos. Fitur ini menampilkan lokasi kos pada peta dan memberikan perkiraan rute menuju kos pilihan Anda.',
            ),
            SizedBox(height: 8),
            _CalloutBox(
              title: 'Tips Praktis',
              body:
                  'Pastikan izin akses lokasi (GPS) aktif di perangkat Anda untuk mendapatkan rekomendasi kos terdekat dari posisi Anda saat ini secara otomatis.',
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  final String title;

  const _SectionIntro({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: AppColors.primaryAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const _StepCard({
    required this.step,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceBorderSoft.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$step. $title',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textSecondaryMuted,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final String text;

  const _DescriptionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.6,
          color: AppColors.textSecondaryMuted,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class _CalloutBox extends StatelessWidget {
  final String title;
  final String body;

  const _CalloutBox({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondaryMuted,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
