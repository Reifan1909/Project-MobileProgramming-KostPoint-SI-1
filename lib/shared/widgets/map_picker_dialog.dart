import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../../core/constants/app_colors.dart';
import '../../core/constants/dummy_data.dart';

/// Halaman Penuh Penandaan & Pemilihan Titik Lokasi Peta (Center-Pinned Map Picker ala Gojek/Grab).
/// Dilengkapi Live Autocomplete Pencarian Universitas dan OpenStreetMap nyata.
class MapPickerDialog extends StatefulWidget {
  final DestinationTarget initialTarget;

  const MapPickerDialog({
    super.key,
    required this.initialTarget,
  });

  /// Membuka pemilih peta sebagai halaman penuh agar gesture geser peta bekerja optimal tanpa terpotong
  static Future<DestinationTarget?> show(
    BuildContext context, {
    required DestinationTarget initialTarget,
  }) {
    return Navigator.push<DestinationTarget>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerDialog(initialTarget: initialTarget),
      ),
    );
  }

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late final MapController _mapController;
  late double _latitude;
  late double _longitude;
  late String _locationName;
  late String _locationAddress;
  late String _selectedCity;
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _latitude = widget.initialTarget.latitude;
    _longitude = widget.initialTarget.longitude;
    _locationName = widget.initialTarget.name;
    _locationAddress = widget.initialTarget.address;
    _selectedCity = widget.initialTarget.city;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
        _locationName = 'Lokasi GPS Saya';
        _locationAddress = 'Berdasarkan sensor GPS perangkat aktif';
        _selectedCity = 'Lokasi Terkini';
      });

      _mapController.move(LatLng(_latitude, _longitude), 16.0);
      _showToast('Mengarahkan ke koordinat GPS terkini!');
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

  void _onPositionChanged(double lat, double lng) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _locationAddress = 'Koordinat: ${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}';
    });
  }

  void _moveToDestination(DestinationTarget dest) {
    setState(() {
      _latitude = dest.latitude;
      _longitude = dest.longitude;
      _locationName = dest.name;
      _locationAddress = dest.address;
      _selectedCity = dest.city;
    });
    _mapController.move(LatLng(dest.latitude, dest.longitude), 16.0);
    _showToast('📍 Peta dipindahkan ke: ${dest.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Pilih Titik di Peta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Peta Nyata OpenStreetMap (Layar Penuh, gesture bebas 100%)
          Positioned.fill(
            child: _OsmCenterPinMapPicker(
              mapController: _mapController,
              latitude: _latitude,
              longitude: _longitude,
              locationName: _locationName,
              onCenterChanged: _onPositionChanged,
              onGpsPressed: _fetchCurrentGps,
              isLoadingGps: _isLoadingGps,
            ),
          ),

          // 2. Header Pencarian dengan Live Autocomplete & Preset Kampus
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapSearchBarWithSuggestions(onSelectedDestination: _moveToDestination),
                const SizedBox(height: 8),
                _CityPresetChips(onSelect: _moveToDestination),
              ],
            ),
          ),

          // 3. Bottom Bar Konfirmasi Titik Peta Terpilih
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _MapBottomBar(
              latitude: _latitude,
              longitude: _longitude,
              locationName: _locationName,
              locationAddress: _locationAddress,
              city: _selectedCity,
              isLoadingGps: _isLoadingGps,
              onGpsPressed: _fetchCurrentGps,
              onApply: _applyTarget,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search bar cerdas dengan Live Autocomplete Suggestions (otomatis menampilkan universitas saat diketik)
class _MapSearchBarWithSuggestions extends StatefulWidget {
  final ValueChanged<DestinationTarget> onSelectedDestination;

  const _MapSearchBarWithSuggestions({
    required this.onSelectedDestination,
  });

  @override
  State<_MapSearchBarWithSuggestions> createState() => _MapSearchBarWithSuggestionsState();
}

class _MapSearchBarWithSuggestionsState extends State<_MapSearchBarWithSuggestions> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<DestinationTarget> _suggestions = [];
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final q = query.toLowerCase().trim();
    final results = DummyData.popularDestinations.where((d) {
      final nameMatch = d.name.toLowerCase().contains(q);
      final cityMatch = d.city.toLowerCase().contains(q);
      final addrMatch = d.address.toLowerCase().contains(q);
      return nameMatch || cityMatch || addrMatch;
    }).toList();

    setState(() => _suggestions = results);
  }

  void _selectDestination(DestinationTarget dest) {
    _controller.text = dest.name;
    setState(() => _suggestions = []);
    _focusNode.unfocus();
    widget.onSelectedDestination(dest);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(14),
            color: AppColors.cardSurface,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari universitas (UPI, UNAND, ITB, UI, UGM...)',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAccent),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
                filled: true,
                fillColor: AppColors.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) {
                if (_suggestions.isNotEmpty) {
                  _selectDestination(_suggestions.first);
                }
              },
            ),
          ),
          if (_suggestions.isNotEmpty && _isFocused) ...[
            const SizedBox(height: 6),
            Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              color: AppColors.cardSurface,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorderSoft),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surfaceBorderSoft),
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school_rounded, size: 18, color: AppColors.primaryAccent),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${item.address} • ${item.city}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondaryMuted),
                      onTap: () => _selectDestination(item),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip pilihan kampus & kota beragam di seluruh Indonesia
class _CityPresetChips extends StatelessWidget {
  final ValueChanged<DestinationTarget> onSelect;

  const _CityPresetChips({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: DummyData.popularDestinations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = DummyData.popularDestinations[index];
          final cleanName = item.name.split(' (').first;

          return ActionChip(
            avatar: const Icon(Icons.school_rounded, size: 14, color: AppColors.primaryAccent),
            label: Text('$cleanName (${item.city})'),
            backgroundColor: AppColors.cardSurface,
            side: const BorderSide(color: AppColors.surfaceBorderSoft),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            onPressed: () => onSelect(item),
          );
        },
      ),
    );
  }
}

/// Peta OpenStreetMap dengan Pin Tengah Statis Persis Seperti Aplikasi Gojek/Grab
class _OsmCenterPinMapPicker extends StatelessWidget {
  final MapController mapController;
  final double latitude;
  final double longitude;
  final String locationName;
  final Function(double, double) onCenterChanged;
  final VoidCallback onGpsPressed;
  final bool isLoadingGps;

  const _OsmCenterPinMapPicker({
    required this.mapController,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.onCenterChanged,
    required this.onGpsPressed,
    required this.isLoadingGps,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Peta Nyata OpenStreetMap Dunia & Indonesia (Bebas Gesture)
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 15.0,
            minZoom: 3.0,
            maxZoom: 19.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) {
                onCenterChanged(camera.center.latitude, camera.center.longitude);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              fallbackUrl: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.kostpoint',
            ),
          ],
        ),

        // Pin Tengah Statis (Wajib IgnorePointer agar sentuhan jari tidak terblokir!)
        IgnorePointer(
          ignoring: true,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pin_drop_rounded, size: 14, color: AppColors.primaryAccent),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(
                            locationName.isNotEmpty ? locationName : 'Titik Terpilih',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 46,
                    color: AppColors.primaryAccent,
                  ),
                  Container(
                    width: 10,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Panduan Geser Peta di Bagian Atas
        const IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 112),
              child: _MapDragHintPill(),
            ),
          ),
        ),

        // Kontrol Tombol Floating (+, -, dan Tombol GPS)
        Positioned(
          right: 14,
          bottom: 160,
          child: Column(
            children: [
              _FloatingMapIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Perbesar Peta',
                onPressed: () {
                  final zoom = mapController.camera.zoom;
                  mapController.move(mapController.camera.center, zoom + 1);
                },
              ),
              const SizedBox(height: 8),
              _FloatingMapIconButton(
                icon: Icons.remove_rounded,
                tooltip: 'Perkecil Peta',
                onPressed: () {
                  final zoom = mapController.camera.zoom;
                  mapController.move(mapController.camera.center, zoom - 1);
                },
              ),
              const SizedBox(height: 8),
              _FloatingMapIconButton(
                icon: isLoadingGps ? Icons.hourglass_top_rounded : Icons.my_location_rounded,
                tooltip: 'Lokasi GPS Saya',
                iconColor: AppColors.primaryAccent,
                onPressed: onGpsPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapDragHintPill extends StatelessWidget {
  const _MapDragHintPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primaryAccent),
          SizedBox(width: 6),
          Text(
            'Geser peta untuk menempatkan pin lokasi',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _FloatingMapIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? iconColor;

  const _FloatingMapIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      elevation: 4,
      shape: const CircleBorder(side: BorderSide(color: AppColors.surfaceBorderSoft)),
      child: IconButton(
        icon: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
        padding: EdgeInsets.zero,
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: const Border(top: BorderSide(color: AppColors.surfaceBorderSoft)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text(
                'Terapkan Titik Lokasi Ini',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
