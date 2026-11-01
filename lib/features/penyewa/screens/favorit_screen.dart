import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/kos_card.dart';
import '../providers/katalog_provider.dart';

/// Halaman Favorit (Menu Bar Tab Favorit).
class FavoritScreen extends StatelessWidget {
  const FavoritScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KatalogProvider>();
    final favorites = provider.favoriteKosList;
    final destination = provider.selectedDestination;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kos Favorit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: favorites.isEmpty
          ? const _EmptyFavoriteView()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final kos = favorites[index];
                return KosCard(
                  kos: kos,
                  targetLatitude: destination.latitude,
                  targetLongitude: destination.longitude,
                );
              },
            ),
    );
  }
}

class _EmptyFavoriteView extends StatelessWidget {
  const _EmptyFavoriteView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 56,
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Kos Disimpan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tandai kos pilihanmu saat menjelajah katalog untuk menyimpannya di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<KatalogProvider>().setNavIndex(0);
              },
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Jelajahi Katalog'),
            ),
          ],
        ),
      ),
    );
  }
}

