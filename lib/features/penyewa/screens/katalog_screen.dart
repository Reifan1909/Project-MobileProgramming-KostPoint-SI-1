import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../shared/widgets/kos_card.dart';
import '../../../shared/widgets/map_picker_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/katalog_provider.dart';
import 'detail_kos_screen.dart';

/// Halaman Katalog Utama (Mode Guest).
/// Membuka langsung daftar kos dengan pencarian berbasis titik tujuan dinamis di seluruh Indonesia.
class KatalogScreen extends StatelessWidget {
  const KatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KatalogProvider>();
    final destination = provider.selectedDestination;
    final kosList = provider.sortedKosList;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const _KatalogAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DestinationSelectorCard(
                    destination: destination,
                    onTapChange: () => _openMapPicker(context, destination),
                  ),
                  const SizedBox(height: 14),
                  const _CategoryFilterBar(),
                  const SizedBox(height: 16),
                  _KosListHeader(
                    totalCount: kosList.length,
                    city: destination.city,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          if (kosList.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          size: 48,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Kos Terdaftar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Saat ini belum ada properti kos yang didaftarkan. Kos yang didaftarkan oleh pemilik kos akan otomatis muncul di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final kos = kosList[index];
                    return KosCard(
                      kos: kos,
                      targetLatitude: destination.latitude,
                      targetLongitude: destination.longitude,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailKosScreen(
                              kos: kos,
                              destination: destination,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: kosList.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker(BuildContext context, DestinationTarget current) async {
    final result = await MapPickerDialog.show(context, initialTarget: current);
    if (result != null && context.mounted) {
      context.read<KatalogProvider>().updateDestination(result);
    }
  }
}

/// AppBar dengan Brand Kost Point dan Aksi Masuk / Autentikasi
class _KatalogAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _KatalogAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final currentDest = context.watch<KatalogProvider>().selectedDestination;
    final auth = context.watch<AuthProvider>();

    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_city_rounded,
              color: AppColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kost Point',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                auth.isLoggedIn
                    ? '${currentDest.city} • ${auth.currentUser?.name.split(' ').first}'
                    : '${currentDest.city} • Belum Masuk',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: auth.isLoggedIn
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryAccent),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        auth.isPemilik ? Icons.storefront_rounded : Icons.verified_user_rounded,
                        size: 14,
                        color: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        auth.currentUser?.name.split(' ').first ??
                            (auth.isPemilik ? 'Pemilik' : 'Penyewa'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login_rounded, size: 16),
                  label: const Text('Masuk'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                    side: const BorderSide(color: AppColors.primaryAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Kartu Pemilihan Titik Tujuan Maps Dinamis
class _DestinationSelectorCard extends StatelessWidget {
  final DestinationTarget destination;
  final VoidCallback onTapChange;

  const _DestinationSelectorCard({
    required this.destination,
    required this.onTapChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceBorderSoft.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.map_rounded,
                color: AppColors.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Titik Peta Pencarian Dinamis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondaryMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              InkWell(
                onTap: onTapChange,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Pilih Peta',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.pin_drop_rounded,
                        size: 14,
                        color: AppColors.primaryAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            destination.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${destination.address} • ${destination.city}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.gps_fixed_rounded,
                  size: 12,
                  color: AppColors.primaryAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Koordinat: ${destination.latitude.toStringAsFixed(5)}, ${destination.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondaryMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Bar Kategori Kos (Semua, Putra, Putri, Campur)
class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar();

  static const _categories = ['Semua', 'Putra', 'Putri', 'Campur'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KatalogProvider>();
    final current = provider.selectedCategory;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = cat == current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => provider.setCategory(cat),
              selectedColor: AppColors.primaryAccent,
              backgroundColor: AppColors.cardSurface,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Header Teks Jumlah Kos & Status Sorting
class _KosListHeader extends StatelessWidget {
  final int totalCount;
  final String city;

  const _KosListHeader({
    required this.totalCount,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Kos ($totalCount)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Row(
          children: [
            Icon(Icons.tune_rounded, size: 14, color: AppColors.textSecondaryMuted),
            SizedBox(width: 4),
            Text(
              'PRO & Terdekat',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
