import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../shared/models/kos_model.dart';
import '../../../shared/widgets/map_picker_dialog.dart';
import '../providers/katalog_provider.dart';

/// Halaman Pencarian Peta Eksplorasi (Menu Bar Tab Peta).
/// Memungkinkan navigasi peta bebas, melihat sebaran kos di sekitar titik tujuan,
/// dan memindahkan titik pusat pencarian ke mana saja di Indonesia.
class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  KosModel? _selectedKos;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KatalogProvider>();
    final destination = provider.selectedDestination;
    final kosList = provider.sortedKosList;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _MapAppBar(
        destination: destination,
        onTapChangeLocation: () => _openMapPicker(destination),
      ),
      body: Stack(
        children: [
          _InteractiveMapExplorer(
            destination: destination,
            kosList: kosList,
            selectedKos: _selectedKos,
            onSelectKos: (kos) => setState(() => _selectedKos = kos),
          ),
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: _LocationStatusCard(
              destination: destination,
              onTapChange: () => _openMapPicker(destination),
            ),
          ),
          if (_selectedKos != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _KosMapPreviewCard(
                kos: _selectedKos!,
                target: destination,
                onClose: () => setState(() => _selectedKos = null),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker(DestinationTarget current) async {
    final result = await MapPickerDialog.show(context, initialTarget: current);
    if (result != null && mounted) {
      context.read<KatalogProvider>().updateDestination(result);
    }
  }
}

/// AppBar Khusus Peta
class _MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DestinationTarget destination;
  final VoidCallback onTapChangeLocation;

  const _MapAppBar({
    required this.destination,
    required this.onTapChangeLocation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Peta Eksplorasi Kos',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onTapChangeLocation,
          icon: const Icon(Icons.add_location_alt_rounded, color: AppColors.primaryAccent),
          tooltip: 'Atur Titik Peta',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Kartu status informasi titik tujuan aktif di bagian atas peta
class _LocationStatusCard extends StatelessWidget {
  final DestinationTarget destination;
  final VoidCallback onTapChange;

  const _LocationStatusCard({
    required this.destination,
    required this.onTapChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location_rounded, color: AppColors.primaryAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  destination.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${destination.city} • Ketuk untuk pindah kota/GPS',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onTapChange,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Ganti', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryAccent)),
          ),
        ],
      ),
    );
  }
}

/// Kanvas Peta Interaktif dengan titik pusat dan sebaran penanda kos
class _InteractiveMapExplorer extends StatelessWidget {
  final DestinationTarget destination;
  final List<KosModel> kosList;
  final KosModel? selectedKos;
  final ValueChanged<KosModel> onSelectKos;

  const _InteractiveMapExplorer({
    required this.destination,
    required this.kosList,
    required this.selectedKos,
    required this.onSelectKos,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFFE5ECF4),
          child: CustomPaint(painter: _PetaBackgroundPainter()),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Titik Tujuan',
                  style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.stars_rounded, color: AppColors.primaryAccent, size: 38),
            ],
          ),
        ),
        ..._buildKosMarkers(context),
      ],
    );
  }

  List<Widget> _buildKosMarkers(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widgets = <Widget>[];

    for (int i = 0; i < kosList.length && i < 6; i++) {
      final kos = kosList[i];
      final isSelected = selectedKos?.id == kos.id;

      // Posisi offset terdistribusi di sekitar titik pusat
      final radius = 90.0 + (i % 2) * 45.0;
      final offsetX = size.width / 2 + radius * 1.3 * (i % 2 == 0 ? 1 : -1) * (i > 2 ? 0.8 : 0.5);
      final offsetY = size.height / 2.3 + radius * (i % 3 == 0 ? 1 : -1) * 0.7;

      widgets.add(
        Positioned(
          left: offsetX.clamp(20.0, size.width - 90.0),
          top: offsetY.clamp(90.0, size.height - 240.0),
          child: GestureDetector(
            onTap: () => onSelectKos(kos),
            child: _KosMapPin(kos: kos, isSelected: isSelected),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _KosMapPin extends StatelessWidget {
  final KosModel kos;
  final bool isSelected;

  const _KosMapPin({
    required this.kos,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textPrimary : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: kos.isPremium ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
              width: kos.isPremium ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kos.isPremium) ...[
                const Icon(Icons.verified_rounded, size: 12, color: AppColors.primaryAccent),
                const SizedBox(width: 4),
              ],
              Text(
                kos.name.split(' ').take(2).join(' '),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.location_on_rounded,
          size: isSelected ? 34 : 28,
          color: kos.isPremium ? AppColors.primaryAccent : AppColors.textSecondaryMuted,
        ),
      ],
    );
  }
}

/// Floating Card Preview saat salah satu pin kos ditekan
class _KosMapPreviewCard extends StatelessWidget {
  final KosModel kos;
  final DestinationTarget target;
  final VoidCallback onClose;

  const _KosMapPreviewCard({
    required this.kos,
    required this.target,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final distKm = DistanceCalculator.calculateDistanceKm(
      startLatitude: kos.latitude,
      startLongitude: kos.longitude,
      endLatitude: target.latitude,
      endLongitude: target.longitude,
    );
    final distText = DistanceCalculator.formatDistance(distKm);
    final travel = DistanceCalculator.formatTravelEstimate(distKm);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              kos.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: AppColors.surfaceBorderSoft,
                child: const Icon(Icons.apartment_rounded, color: AppColors.textSecondaryMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        kos.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: onClose,
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondaryMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$distText • $travel',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryAccent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  kos.formattedPrice,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetaBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    final secondaryPaint = Paint()
      ..color = const Color(0xFFEFF3F8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (double y = 60; y < size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    for (double x = 50; x < size.width; x += 90) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.7), secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
