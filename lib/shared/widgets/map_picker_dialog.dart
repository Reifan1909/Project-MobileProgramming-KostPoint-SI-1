import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dummy_data.dart';

/// Dialog Penandaan & Pemilihan Titik Lokasi Maps Dinamis.
/// Dapat digunakan oleh Penyewa (menentukan titik tujuan di mana saja di Indonesia)
/// dan Pemilik Kos (menentukan titik koordinat lokasi kos).
class MapPickerDialog extends StatefulWidget {
  final DestinationTarget initialTarget;

  const MapPickerDialog({
    super.key,
    required this.initialTarget,
  });

  static Future<DestinationTarget?> show(
    BuildContext context, {
    required DestinationTarget initialTarget,
  }) {
    return showModalBottomSheet<DestinationTarget>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MapPickerDialog(initialTarget: initialTarget),
    );
  }

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late double _latitude;
  late double _longitude;
  late String _locationName;
  late String _locationAddress;
  late String _selectedCity;
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialTarget.latitude;
    _longitude = widget.initialTarget.longitude;
    _locationName = widget.initialTarget.name;
    _locationAddress = widget.initialTarget.address;
    _selectedCity = widget.initialTarget.city;
  }

  Future<void> _fetchCurrentGps() async {
    setState(() => _isLoadingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showToast('Layanan lokasi (GPS) perangkat belum aktif.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          _showToast('Izin akses lokasi ditolak.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showToast('Izin lokasi ditolak permanen pada pengaturan perangkat.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationName = 'Lokasi GPS Saya Saat Ini';
        _locationAddress = 'Berdasarkan sensor GPS perangkat aktif';
        _selectedCity = 'Lokasi Terkini';
      });
      _showToast('Berhasil mendapatkan koordinat GPS terkini!');
    } catch (e) {
      _showToast('Gagal memuat GPS: $e');
    } finally {
      if (mounted) setState(() => _isLoadingGps = false);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _applyTarget() {
    final result = DestinationTarget(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _locationName,
      address: _locationAddress,
      city: _selectedCity,
      latitude: _latitude,
      longitude: _longitude,
    );
    Navigator.pop(context, result);
  }

  void _onMapTapped(TapDownDetails details, Size size) {
    // Simulasi pergeseran koordinat halus berdasarkan ketukan layar
    final dx = (details.localPosition.dx / size.width - 0.5) * 0.04;
    final dy = (details.localPosition.dy / size.height - 0.5) * 0.04;

    setState(() {
      _latitude = _latitude - dy;
      _longitude = _longitude + dx;
      _locationAddress = 'Titik peta dipilih manual (${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const _DragHandleHeader(),
          _MapSearchBar(
            onSelectedDestination: (dest) {
              setState(() {
                _latitude = dest.latitude;
                _longitude = dest.longitude;
                _locationName = dest.name;
                _locationAddress = dest.address;
                _selectedCity = dest.city;
              });
            },
          ),
          const SizedBox(height: 8),
          _CityPresetChips(
            onSelect: (dest) {
              setState(() {
                _latitude = dest.latitude;
                _longitude = dest.longitude;
                _locationName = dest.name;
                _locationAddress = dest.address;
                _selectedCity = dest.city;
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _InteractiveMapCanvas(
              latitude: _latitude,
              longitude: _longitude,
              locationName: _locationName,
              onTapDown: _onMapTapped,
            ),
          ),
          _MapBottomBar(
            latitude: _latitude,
            longitude: _longitude,
            locationName: _locationName,
            locationAddress: _locationAddress,
            city: _selectedCity,
            isLoadingGps: _isLoadingGps,
            onGpsPressed: _fetchCurrentGps,
            onApply: _applyTarget,
          ),
        ],
      ),
    );
  }
}

/// Drag handle pada bagian paling atas modal sheet
class _DragHandleHeader extends StatelessWidget {
  const _DragHandleHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceBorderSoft,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

/// Search bar untuk mencari lokasi / kampus di seluruh Indonesia
class _MapSearchBar extends StatelessWidget {
  final ValueChanged<DestinationTarget> onSelectedDestination;

  const _MapSearchBar({required this.onSelectedDestination});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari kampus, kantor, atau kota di Indonesia...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAccent),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                isDense: true,
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorderSoft),
                ),
              ),
              onSubmitted: (query) {
                if (query.trim().isEmpty) return;
                final match = DummyData.popularDestinations.firstWhere(
                  (d) => d.name.toLowerCase().contains(query.toLowerCase()) ||
                      d.city.toLowerCase().contains(query.toLowerCase()),
                  orElse: () => DestinationTarget(
                    id: 'custom_search',
                    name: query,
                    address: 'Area $query',
                    city: query,
                    latitude: -0.965874,
                    longitude: 100.399587,
                  ),
                );
                onSelectedDestination(match);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip pilihan kota / kampus populer di Indonesia
class _CityPresetChips extends StatelessWidget {
  final ValueChanged<DestinationTarget> onSelect;

  const _CityPresetChips({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: DummyData.popularDestinations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = DummyData.popularDestinations[index];
          return ActionChip(
            avatar: const Icon(Icons.location_city_rounded, size: 14, color: AppColors.primaryAccent),
            label: Text(item.city),
            backgroundColor: AppColors.backgroundColor,
            side: const BorderSide(color: AppColors.surfaceBorderSoft),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            onPressed: () => onSelect(item),
          );
        },
      ),
    );
  }
}

/// Canvas Peta Interaktif dengan Grid Jalan, Pin Marker, & Kontrol
class _InteractiveMapCanvas extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final Function(TapDownDetails, Size) onTapDown;

  const _InteractiveMapCanvas({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapDown: (details) => onTapDown(details, canvasSize),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                size: canvasSize,
                painter: _MapCanvasPainter(),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        locationName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 42,
                      color: AppColors.primaryAccent,
                    ),
                    Container(
                      width: 12,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.surfaceBorderSoft),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primaryAccent),
                      SizedBox(width: 4),
                      Text(
                        'Ketuk layar untuk geser titik',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom Bar Informasi Koordinat Terpilih & Aksi Terapkan
class _MapBottomBar extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final String locationAddress;
  final String city;
  final bool isLoadingGps;
  final VoidCallback onGpsPressed;
  final VoidCallback onApply;

  const _MapBottomBar({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.locationAddress,
    required this.city,
    required this.isLoadingGps,
    required this.onGpsPressed,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: const Border(top: BorderSide(color: AppColors.surfaceBorderSoft)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$locationAddress • ($city)',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.primaryAccent, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: isLoadingGps ? null : onGpsPressed,
                icon: isLoadingGps
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location_rounded, color: AppColors.primaryAccent),
                tooltip: 'Gunakan Lokasi GPS Saya',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Terapkan Titik Lokasi Ini'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter yang merender grid peta dinamis yang elegan
class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE8EEF5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFF0F4F8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Garis jalan horizontal & vertikal
    for (double y = 40; y < size.height; y += 70) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    for (double x = 40; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Jalan diagonal sekunder
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.8), secondaryRoadPaint);
    canvas.drawLine(Offset(size.width * 0.1, size.height), Offset(size.width * 0.9, 0), secondaryRoadPaint);

    // Area taman hijau
    final parkPaint = Paint()..color = const Color(0xFFD6E9DB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.12, 100, 60),
        const Radius.circular(8),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.6, 90, 70),
        const Radius.circular(8),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
