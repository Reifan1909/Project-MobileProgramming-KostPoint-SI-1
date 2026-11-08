import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../shared/models/kos_model.dart';
import '../../../shared/widgets/kos_image_viewer.dart';
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
              background: _DetailPhotoCarousel(images: kos.allImages),
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

class _DetailPhotoCarousel extends StatefulWidget {
  final List<String> images;

  const _DetailPhotoCarousel({required this.images});

  @override
  State<_DetailPhotoCarousel> createState() => _DetailPhotoCarouselState();
}

class _DetailPhotoCarouselState extends State<_DetailPhotoCarousel> {
  int _activePage = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    if (images.isEmpty) {
      return const KosImageViewer(imagePath: '');
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (page) => setState(() => _activePage = page),
          itemBuilder: (context, index) {
            return KosImageViewer(
              imagePath: images[index],
              fit: BoxFit.cover,
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.35),
              ],
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_activePage + 1} / ${images.length} Foto',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

