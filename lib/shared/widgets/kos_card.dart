import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/distance_calculator.dart';
import '../models/kos_model.dart';

/// Kartu Kos modern sesuai standar Section 2 & 4.3 Kost Point Guide.
/// Dilengkapi cover image (150px), badge PRO, badge sisa kamar, dan kalkulasi jarak dinamis.
class KosCard extends StatelessWidget {
  final KosModel kos;
  final double targetLatitude;
  final double targetLongitude;
  final VoidCallback? onTap;

  const KosCard({
    super.key,
    required this.kos,
    required this.targetLatitude,
    required this.targetLongitude,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = DistanceCalculator.calculateDistanceKm(
      startLatitude: kos.latitude,
      startLongitude: kos.longitude,
      endLatitude: targetLatitude,
      endLongitude: targetLongitude,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kos.isPremium
              ? AppColors.primaryAccent.withValues(alpha: 0.6)
              : AppColors.surfaceBorderSoft,
          width: kos.isPremium ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceBorderSoft.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KosCoverImage(kos: kos),
              _KosInformation(kos: kos, distanceKm: distanceKm),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sub-widget untuk foto sampul beserta overlay badge PRO, tipe gender, & sisa kamar.
class _KosCoverImage extends StatelessWidget {
  final KosModel kos;

  const _KosCoverImage({required this.kos});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              kos.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceBorderSoft,
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 48,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.surfaceBorderSoft,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
            if (kos.isPremium)
              Positioned(
                top: 10,
                left: 10,
                child: _BadgePro(),
              ),
            Positioned(
              top: 10,
              right: 10,
              child: _BadgeGender(type: kos.type),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: _BadgeRemainingRooms(remaining: kos.remainingRooms),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sub-widget untuk detail teks nama kos, rating, jarak, dan harga.
class _KosInformation extends StatelessWidget {
  final KosModel kos;
  final double distanceKm;

  const _KosInformation({
    required this.kos,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = DistanceCalculator.formatDistance(distanceKm);
    final travelEstimate = DistanceCalculator.formatTravelEstimate(distanceKm);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  kos.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: AppColors.premiumGold),
                  const SizedBox(width: 3),
                  Text(
                    kos.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.near_me_rounded,
                size: 14,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(width: 4),
              Text(
                '$distanceText dari tujuan',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '•',
                style: TextStyle(color: AppColors.textSecondaryMuted, fontSize: 11),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  travelEstimate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            kos.address,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: kos.formattedPrice.replaceAll(kos.pricePeriod, ''),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' ${kos.pricePeriod}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceBorderSoft),
                ),
                child: Text(
                  kos.district,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Visual Badge khusus Kos PRO / Unggulan
class _BadgePro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.white),
          SizedBox(width: 4),
          Text(
            'PRO / Teratas',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge Tipe Gender Kos (Putra / Putri / Campur)
class _BadgeGender extends StatelessWidget {
  final String type;

  const _BadgeGender({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge Status Sisa Kamar (misal: "Tersisa 2 Kamar")
class _BadgeRemainingRooms extends StatelessWidget {
  final int remaining;

  const _BadgeRemainingRooms({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isCritical = remaining <= 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.danger.withValues(alpha: 0.9)
            : AppColors.cardSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Tersisa $remaining Kamar',
        style: TextStyle(
          color: isCritical ? AppColors.white : AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
