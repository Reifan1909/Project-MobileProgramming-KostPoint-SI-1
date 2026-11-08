import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../shared/models/kos_model.dart';
import '../../../shared/widgets/kos_image_viewer.dart';
import '../../../shared/widgets/map_picker_dialog.dart';
import '../providers/katalog_provider.dart';
import 'detail_kos_screen.dart';

/// Halaman Pencarian Peta Eksplorasi (Menu Bar Tab Peta).
/// Menggunakan OpenStreetMap nyata untuk menampilkan sebaran lokasi kos di sekitar titik tujuan.
class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  late final MapController _mapController;
  KosModel? _selectedKos;
  String? _lastDestinationId;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _checkDestinationUpdate(DestinationTarget destination) {
    if (_lastDestinationId != destination.id) {
      _lastDestinationId = destination.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(LatLng(destination.latitude, destination.longitude), 14.5);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KatalogProvider>();
    final destination = provider.selectedDestination;
    final kosList = provider.sortedKosList;

    _checkDestinationUpdate(destination);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _MapAppBar(
        destination: destination,
        onTapChangeLocation: () => _openMapPicker(destination),
      ),
      body: Stack(
        children: [
          _OsmMapExplorer(
            mapController: _mapController,
            destination: destination,
            kosList: kosList,
            selectedKos: _selectedKos,
            onSelectKos: (kos) {
              setState(() => _selectedKos = kos);
              _mapController.move(LatLng(kos.latitude, kos.longitude), 15.5);
            },
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
          Positioned(
            right: 14,
            bottom: _selectedKos != null ? 140 : 24,
            child: _MapFloatingControls(
              mapController: _mapController,
              destination: destination,
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
        color: AppColors.cardSurface,
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
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.near_me_rounded, color: AppColors.primaryAccent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  destination.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${destination.city} • Ketuk untuk pindah kota/lokasi',
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

/// Tampilan Peta Nyata OpenStreetMap dengan Sebaran Pin Kos
class _OsmMapExplorer extends StatelessWidget {
  final MapController mapController;
  final DestinationTarget destination;
  final List<KosModel> kosList;
  final KosModel? selectedKos;
  final ValueChanged<KosModel> onSelectKos;

  const _OsmMapExplorer({
    required this.mapController,
    required this.destination,
    required this.kosList,
    required this.selectedKos,
    required this.onSelectKos,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(destination.latitude, destination.longitude),
        initialZoom: 14.5,
        minZoom: 3.0,
        maxZoom: 19.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          fallbackUrl: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.kostpoint',
        ),
        MarkerLayer(
          markers: [
            // Penanda Titik Tujuan (Kampus/Kantor)
            Marker(
              point: LatLng(destination.latitude, destination.longitude),
              width: 140,
              height: 60,
              alignment: Alignment.topCenter,
              child: _DestinationMarker(name: destination.name),
            ),
            // Penanda Seluruh Kos Terdaftar
            ...kosList.map((kos) {
              final isSelected = selectedKos?.id == kos.id;
              return Marker(
                point: LatLng(kos.latitude, kos.longitude),
                width: 120,
                height: 52,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => onSelectKos(kos),
                  child: _KosMarkerPin(kos: kos, isSelected: isSelected),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  final String name;

  const _DestinationMarker({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name.split(' ').take(3).join(' '),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.stars_rounded, color: AppColors.primaryAccent, size: 28),
      ],
    );
  }
}

class _KosMarkerPin extends StatelessWidget {
  final KosModel kos;
  final bool isSelected;

  const _KosMarkerPin({
    required this.kos,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textPrimary : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            kos.name.split(' ').take(2).join(' '),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          Icons.location_on_rounded,
          size: isSelected ? 30 : 24,
          color: isSelected ? AppColors.primaryAccent : AppColors.textSecondaryMuted,
        ),
      ],
    );
  }
}

class _MapFloatingControls extends StatelessWidget {
  final MapController mapController;
  final DestinationTarget destination;

  const _MapFloatingControls({
    required this.mapController,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ControlCircleButton(
          icon: Icons.add_rounded,
          tooltip: 'Perbesar Peta',
          onPressed: () {
            final zoom = mapController.camera.zoom;
            mapController.move(mapController.camera.center, zoom + 1);
          },
        ),
        const SizedBox(height: 8),
        _ControlCircleButton(
          icon: Icons.remove_rounded,
          tooltip: 'Perkecil Peta',
          onPressed: () {
            final zoom = mapController.camera.zoom;
            mapController.move(mapController.camera.center, zoom - 1);
          },
        ),
        const SizedBox(height: 8),
        _ControlCircleButton(
          icon: Icons.my_location_rounded,
          tooltip: 'Kembali ke Titik Tujuan',
          iconColor: AppColors.primaryAccent,
          onPressed: () {
            mapController.move(LatLng(destination.latitude, destination.longitude), 14.5);
          },
        ),
      ],
    );
  }
}

class _ControlCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? iconColor;

  const _ControlCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      elevation: 3,
      shape: const CircleBorder(side: BorderSide(color: AppColors.surfaceBorderSoft)),
      child: IconButton(
        icon: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailKosScreen(
              kos: kos,
              destination: target,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              child: KosImageViewer(
                imagePath: kos.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
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
    ),
  );
}
}
