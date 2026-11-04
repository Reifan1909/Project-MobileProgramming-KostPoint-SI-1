import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../shared/models/kos_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/katalog_provider.dart';
import '../widgets/detail_kos_components.dart';

/// Halaman Detail Informasi Kos Lengkap.
/// Terbuka untuk Guest maupun Pengguna Terautentikasi (Penyewa / Pemilik).
/// Menyediakan informasi foto, spesifikasi kamar, rute & jarak, fasilitas, serta rating ulasan.
class DetailKosScreen extends StatelessWidget {
  final KosModel kos;
  final DestinationTarget destination;

  const DetailKosScreen({
    super.key,
    required this.kos,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final katalog = context.watch<KatalogProvider>();
    final isBookmarked = katalog.bookmarkedKosIds.contains(kos.id);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.cardSurface,
            leading: CircleAvatar(
              backgroundColor: AppColors.cardSurface.withValues(alpha: 0.85),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: AppColors.cardSurface.withValues(alpha: 0.85),
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isBookmarked ? AppColors.primaryAccent : AppColors.textPrimary,
                  ),
                  onPressed: () {
                    katalog.toggleBookmark(kos.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isBookmarked ? 'Dihapus dari Favorit' : 'Disimpan ke Favorit'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    kos.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceBorderSoft,
                      child: const Center(
                        child: Icon(Icons.apartment_rounded, size: 64, color: AppColors.textSecondaryMuted),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                DetailHeaderInfo(kos: kos),
                const SizedBox(height: 14),
                DetailRouteCard(kos: kos, destination: destination),
                const SizedBox(height: 14),
                DetailFacilitiesCard(facilities: kos.facilities),
                const SizedBox(height: 14),
                DetailDescriptionCard(description: kos.description),
                const SizedBox(height: 14),
                DetailRatingSection(kos: kos),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DetailBottomActionBar(kos: kos, auth: auth),
    );
  }
}

