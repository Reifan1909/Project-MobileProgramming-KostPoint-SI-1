import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../shared/widgets/kos_image_viewer.dart';
import '../../../shared/widgets/map_picker_dialog.dart';

class FormConstants {
  FormConstants._();

  static const List<String> availableFacilities = [
    'WiFi Cepat',
    'AC',
    'Kamar Mandi Dalam',
    'Kasur & Lemari',
    'Meja Belajar',
    'Parkir Motor',
    'Parkir Mobil',
    'Dapur Bersama',
    'Kulkas',
    'CCTV 24 Jam',
    'Listrik Termasuk',
    'Water Heater',
  ];
}

/// Bagian 1: Informasi Dasar Kos (Nama, Tipe Kos, Deskripsi)
class KosBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const KosBasicInfoSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Informasi Utama Kos',
            subtitle: 'Nama, kategori penghuni, dan deskripsi kos.',
            icon: Icons.apartment_rounded,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Kos *',
              hintText: 'cth. Kos Graha Asri Syariah',
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama kos tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Tipe Penghuni Kos *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          _TypeSelectionRow(
            selectedType: selectedType,
            onTypeChanged: onTypeChanged,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Deskripsi & Aturan Kos',
              hintText: 'cth. Lingkungan aman dan tenang, jam malam pukul 23:00, dekat dengan halte kampus.',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSelectionRow extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const _TypeSelectionRow({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    const types = [
      {'label': 'Putra', 'icon': Icons.male_rounded},
      {'label': 'Putri', 'icon': Icons.female_rounded},
      {'label': 'Campur', 'icon': Icons.wc_rounded},
    ];

    return Row(
      children: types.map((item) {
        final label = item['label'] as String;
        final icon = item['icon'] as IconData;
        final isSelected = selectedType == label;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onTypeChanged(label),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryAccent.withValues(alpha: 0.15)
                      : AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? AppColors.primaryAccent : AppColors.textSecondaryMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Bagian 2: Pemilihan Titik Lokasi Google Maps Dinamis
class KosMapLocationSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final TextEditingController addressController;
  final TextEditingController districtController;
  final ValueChanged<DestinationTarget> onLocationPicked;

  const KosMapLocationSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.addressController,
    required this.districtController,
    required this.onLocationPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Titik Lokasi & Alamat di Peta',
            subtitle: 'Tentukan titik presisi di Google Maps untuk kalkulasi jarak penyewa.',
            icon: Icons.pin_drop_rounded,
          ),
          const SizedBox(height: 14),
          _MapPickerButtonCard(
            latitude: latitude,
            longitude: longitude,
            onOpenMap: () => _openMapPicker(context),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Alamat Lengkap *',
              hintText: 'cth. Jl. Raya Lubuk Begalung No. 12',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alamat lengkap wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: districtController,
            decoration: const InputDecoration(
              labelText: 'Kecamatan / Area *',
              hintText: 'cth. Lubuk Begalung, Padang',
              prefixIcon: Icon(Icons.holiday_village_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Kecamatan/Area wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker(BuildContext context) async {
    final currentTarget = DestinationTarget(
      id: 'kos_pin_${DateTime.now().millisecondsSinceEpoch}',
      name: addressController.text.isNotEmpty ? addressController.text : 'Lokasi Kos',
      address: addressController.text,
      city: districtController.text.isNotEmpty ? districtController.text : 'Kota Padang',
      latitude: latitude,
      longitude: longitude,
    );

    final result = await MapPickerDialog.show(context, initialTarget: currentTarget);
    if (result != null) {
      onLocationPicked(result);
    }
  }
}

class _MapPickerButtonCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final VoidCallback onOpenMap;

  const _MapPickerButtonCard({
    required this.latitude,
    required this.longitude,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.map_rounded, color: AppColors.primaryAccent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koordinat Titik Peta',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                    ),
                    Text(
                      'Lat: ${latitude.toStringAsFixed(6)} • Long: ${longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
              label: const Text('Buka Peta & Tempatkan Titik Kos'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bagian 3: Harga Sewa & Jumlah Kamar
class KosPricingRoomsSection extends StatelessWidget {
  final TextEditingController priceController;
  final int totalRooms;
  final int remainingRooms;
  final ValueChanged<int> onTotalRoomsChanged;
  final ValueChanged<int> onRemainingRoomsChanged;

  const KosPricingRoomsSection({
    super.key,
    required this.priceController,
    required this.totalRooms,
    required this.remainingRooms,
    required this.onTotalRoomsChanged,
    required this.onRemainingRoomsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Harga Sewa & Kapasitas Kamar',
            subtitle: 'Tarif bulanan serta jumlah ketersediaan kamar aktif.',
            icon: Icons.payments_rounded,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Harga Sewa per Bulan (Rp) *',
              hintText: 'cth. 750000',
              prefixText: 'Rp ',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Harga sewa wajib diisi';
              }
              final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
              if (parsed == null || parsed <= 0) {
                return 'Masukkan nominal harga yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RoomCounterTile(
                  label: 'Total Kamar',
                  count: totalRooms,
                  min: 1,
                  max: 100,
                  onChanged: (newTotal) {
                    onTotalRoomsChanged(newTotal);
                    if (remainingRooms > newTotal) {
                      onRemainingRoomsChanged(newTotal);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoomCounterTile(
                  label: 'Sisa Kamar Kosong',
                  count: remainingRooms,
                  min: 0,
                  max: totalRooms,
                  onChanged: onRemainingRoomsChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomCounterTile extends StatelessWidget {
  final String label;
  final int count;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _RoomCounterTile({
    required this.label,
    required this.count,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: count > min ? () => onChanged(count - 1) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Text(
                '$count Kamar',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: count < max ? () => onChanged(count + 1) : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bagian 4: Pemilihan & Unggah Beberapa Foto Kamar / Kos
class KosPhotoPickerSection extends StatefulWidget {
  final List<String> photoUrls;
  final ValueChanged<List<String>> onPhotosChanged;

  const KosPhotoPickerSection({
    super.key,
    required this.photoUrls,
    required this.onPhotosChanged,
  });

  @override
  State<KosPhotoPickerSection> createState() => _KosPhotoPickerSectionState();
}

class _KosPhotoPickerSectionState extends State<KosPhotoPickerSection> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickMultiFromGallery() async {
    try {
      final picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final updated = List<String>.from(widget.photoUrls);
        for (final img in images) {
          if (!updated.contains(img.path)) {
            updated.add(img.path);
          }
        }
        widget.onPhotosChanged(updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final updated = List<String>.from(widget.photoUrls)..add(image.path);
        widget.onPhotosChanged(updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto kamera: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _addUrlPhoto() {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;

    if (!widget.photoUrls.contains(text)) {
      final updated = List<String>.from(widget.photoUrls)..add(text);
      widget.onPhotosChanged(updated);
    }
    _urlController.clear();
  }

  void _removePhoto(int index) {
    final updated = List<String>.from(widget.photoUrls)..removeAt(index);
    widget.onPhotosChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photoUrls;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const _SectionHeader(
                  title: 'Foto Kamar & Kos',
                  subtitle: 'Unggah beberapa foto kos sekaligus (tampak depan, kamar, kamar mandi, parkiran).',
                  icon: Icons.photo_library_rounded,
                ),
              ),
              if (photos.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${photos.length} Foto',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (photos.isNotEmpty) ...[
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  // Tombol tambah foto di akhir list
                  if (index == photos.length) {
                    return InkWell(
                      onTap: _pickMultiFromGallery,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 110,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryAccent.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryAccent, size: 28),
                            SizedBox(height: 6),
                            Text(
                              '+ Tambah Foto',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryAccent),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final photoPath = photos[index];
                  final isCover = index == 0;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 120,
                          height: 130,
                          child: KosImageViewer(
                            imagePath: photoPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isCover)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Sampul',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '* Foto urutan pertama akan otomatis dijadikan foto sampul utama di katalog.',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondaryMuted),
            ),
          ] else ...[
            InkWell(
              onTap: _pickMultiFromGallery,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryAccent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 44,
                      color: AppColors.primaryAccent,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pilih Foto dari Galeri (Bisa Lebih dari 1 Foto)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tampak Depan, Kamar, Kamar Mandi, dsb.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickMultiFromGallery,
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Galeri (Multi Foto)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                    side: const BorderSide(color: AppColors.primaryAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromCamera,
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Buka Kamera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.surfaceBorderSoft),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Atau Tempel Tautan URL Foto',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.link_rounded),
                    isDense: true,
                  ),
                  onFieldSubmitted: (_) => _addUrlPhoto(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addUrlPhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                child: const Text('Tambah'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bagian 5: Fasilitas Kamar & Bersama (Klik Cepat + Input Fasilitas Kustom Bebas)
class KosFacilitiesPickerSection extends StatefulWidget {
  final List<String> selectedFacilities;
  final ValueChanged<List<String>> onFacilitiesChanged;

  const KosFacilitiesPickerSection({
    super.key,
    required this.selectedFacilities,
    required this.onFacilitiesChanged,
  });

  @override
  State<KosFacilitiesPickerSection> createState() => _KosFacilitiesPickerSectionState();
}

class _KosFacilitiesPickerSectionState extends State<KosFacilitiesPickerSection> {
  final _customFacilityController = TextEditingController();

  @override
  void dispose() {
    _customFacilityController.dispose();
    super.dispose();
  }

  void _addCustomFacility() {
    final text = _customFacilityController.text.trim();
    if (text.isEmpty) return;

    if (!widget.selectedFacilities.contains(text)) {
      final updated = List<String>.from(widget.selectedFacilities)..add(text);
      widget.onFacilitiesChanged(updated);
    }
    _customFacilityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Gabungkan fasilitas bawaan dengan fasilitas kustom yang baru ditambahkan
    final allFacilities = <String>{
      ...FormConstants.availableFacilities,
      ...widget.selectedFacilities,
    }.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Fasilitas Kos & Kamar',
            subtitle: 'Pilih fasilitas umum di bawah ini atau ketik fasilitas khusus kos Anda.',
            icon: Icons.checklist_rounded,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allFacilities.map((facility) {
              final isSelected = widget.selectedFacilities.contains(facility);
              final isCustom = !FormConstants.availableFacilities.contains(facility);

              return FilterChip(
                label: Text(facility),
                selected: isSelected,
                selectedColor: AppColors.primaryAccent.withValues(alpha: 0.18),
                checkmarkColor: AppColors.primaryAccent,
                avatar: isCustom
                    ? const Icon(Icons.star_border_rounded, size: 14, color: AppColors.primaryAccent)
                    : null,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                ),
                backgroundColor: AppColors.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
                  ),
                ),
                onSelected: (selected) {
                  final list = List<String>.from(widget.selectedFacilities);
                  if (selected) {
                    list.add(facility);
                  } else {
                    list.remove(facility);
                  }
                  widget.onFacilitiesChanged(list);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tambah Fasilitas Lainnya:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customFacilityController,
                  decoration: const InputDecoration(
                    hintText: 'Cth: Balkon Pribadi, Dapur Bersama',
                    prefixIcon: Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryAccent),
                    isDense: true,
                  ),
                  onFieldSubmitted: (_) => _addCustomFacility(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addCustomFacility,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bagian 6: Kontak WhatsApp & Opsi Status PRO
class KosContactProSection extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isPro;
  final ValueChanged<bool> onProChanged;

  const KosContactProSection({
    super.key,
    required this.phoneController,
    required this.isPro,
    required this.onProChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Kontak WhatsApp Pemilik',
            subtitle: 'Nomor WhatsApp aktif untuk dihubungi langsung oleh calon penyewa.',
            icon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor WhatsApp Pemilik *',
              hintText: 'cth. 081298765432',
              prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nomor WhatsApp wajib diisi';
              }
              if (value.length < 9) {
                return 'Nomor WhatsApp tidak valid';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

