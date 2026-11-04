import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../shared/widgets/map_picker_dialog.dart';

/// Preset foto kamar kos berkualitas untuk kemudahan input
class RoomPhotoPreset {
  final String label;
  final String url;

  const RoomPhotoPreset({required this.label, required this.url});
}

class FormConstants {
  FormConstants._();

  static const List<RoomPhotoPreset> roomPresets = [
    RoomPhotoPreset(
      label: 'Kamar Modern AC',
      url: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80',
    ),
    RoomPhotoPreset(
      label: 'Kamar Minimalis',
      url: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80',
    ),
    RoomPhotoPreset(
      label: 'Kamar Kayu Asri',
      url: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=80',
    ),
    RoomPhotoPreset(
      label: 'Kamar Mezzanine',
      url: 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800&q=80',
    ),
    RoomPhotoPreset(
      label: 'Kamar Estetik Putih',
      url: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
    ),
  ];

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

/// Bagian 4: Pemilihan Foto Kamar (Preset + URL Custom + Live Preview)
class KosPhotoPickerSection extends StatelessWidget {
  final TextEditingController photoUrlController;
  final String currentPhotoUrl;
  final ValueChanged<String> onPhotoSelected;

  const KosPhotoPickerSection({
    super.key,
    required this.photoUrlController,
    required this.currentPhotoUrl,
    required this.onPhotoSelected,
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
            title: 'Foto Kamar & Sampul',
            subtitle: 'Pilih preset foto kamar berkualitas atau tempel link URL foto kos Anda.',
            icon: Icons.photo_library_rounded,
          ),
          const SizedBox(height: 14),
          _PhotoPreviewBox(photoUrl: currentPhotoUrl),
          const SizedBox(height: 12),
          const Text(
            'Preset Foto Kamar Siap Pakai:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: FormConstants.roomPresets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = FormConstants.roomPresets[index];
                final isSelected = currentPhotoUrl == preset.url;

                return InkWell(
                  onTap: () {
                    photoUrlController.text = preset.url;
                    onPhotoSelected(preset.url);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(preset.url, fit: BoxFit.cover),
                        if (isSelected)
                          Container(
                            color: AppColors.primaryAccent.withValues(alpha: 0.35),
                            child: const Center(
                              child: Icon(Icons.check_circle_rounded, color: AppColors.white, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: photoUrlController,
            decoration: const InputDecoration(
              labelText: 'Atau Tempel URL Foto Kamar',
              hintText: 'https://images.unsplash.com/...',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            onChanged: onPhotoSelected,
          ),
        ],
      ),
    );
  }
}

class _PhotoPreviewBox extends StatelessWidget {
  final String photoUrl;

  const _PhotoPreviewBox({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        width: double.infinity,
        color: AppColors.surfaceBorderSoft,
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_rounded, size: 36, color: AppColors.textSecondaryMuted),
                SizedBox(height: 6),
                Text('URL Foto tidak dapat dimuat', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bagian 5: Fasilitas Kamar & Bersama
class KosFacilitiesPickerSection extends StatelessWidget {
  final List<String> selectedFacilities;
  final ValueChanged<List<String>> onFacilitiesChanged;

  const KosFacilitiesPickerSection({
    super.key,
    required this.selectedFacilities,
    required this.onFacilitiesChanged,
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
            title: 'Fasilitas Kos & Kamar',
            subtitle: 'Pilih fasilitas yang tersedia untuk menarik minat calon penyewa.',
            icon: Icons.checklist_rounded,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FormConstants.availableFacilities.map((facility) {
              final isSelected = selectedFacilities.contains(facility);
              return FilterChip(
                label: Text(facility),
                selected: isSelected,
                selectedColor: AppColors.primaryAccent.withValues(alpha: 0.18),
                checkmarkColor: AppColors.primaryAccent,
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
                  final list = List<String>.from(selectedFacilities);
                  if (selected) {
                    list.add(facility);
                  } else {
                    list.remove(facility);
                  }
                  onFacilitiesChanged(list);
                },
              );
            }).toList(),
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
            title: 'Kontak WhatsApp & Status Iklan',
            subtitle: 'Nomor WhatsApp untuk calon penyewa dan opsi promosi.',
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
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPro
                  ? AppColors.primaryAccent.withValues(alpha: 0.1)
                  : AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPro ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPro ? AppColors.primaryAccent : AppColors.surfaceBorderSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: isPro ? AppColors.white : AppColors.textSecondaryMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pasang Sebagai Kos PRO',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Kos diprioritaskan tampil di urutan teratas katalog pencarian.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isPro,
                  activeThumbColor: AppColors.primaryAccent,
                  onChanged: onProChanged,
                ),
              ],
            ),
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

