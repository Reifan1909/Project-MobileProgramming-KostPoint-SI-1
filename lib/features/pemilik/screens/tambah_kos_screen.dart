import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../shared/models/kos_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../penyewa/providers/katalog_provider.dart';
import '../widgets/tambah_kos_form_sections.dart';

/// Halaman Daftarkan Kos Baru oleh Pemilik Kos.
/// Mengumpulkan data lengkap kos termasuk titik koordinat Google Maps interaktif,
/// jumlah kamar, harga, foto kamar, tipe kos, dan fasilitas pendukung.
class TambahKosScreen extends StatefulWidget {
  const TambahKosScreen({super.key});

  @override
  State<TambahKosScreen> createState() => _TambahKosScreenState();
}

class _TambahKosScreenState extends State<TambahKosScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController(text: 'Jl. Raya Lubuk Begalung No. 25');
  final _districtController = TextEditingController(text: 'Lubuk Begalung, Padang');
  final _priceController = TextEditingController(text: '750000');
  final _photoUrlController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedType = 'Putra';
  double _latitude = -0.965874;
  double _longitude = 100.399587;
  int _totalRooms = 10;
  int _remainingRooms = 4;
  String _currentPhotoUrl = '';
  bool _isPro = false;

  List<String> _selectedFacilities = [
    'WiFi Cepat',
    'Kamar Mandi Dalam',
    'Kasur & Lemari',
    'Parkir Motor',
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null && currentUser.phone.isNotEmpty) {
      _phoneController.text = currentUser.phone;
    } else {
      _phoneController.text = '081298765432';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onLocationPicked(DestinationTarget target) {
    setState(() {
      _latitude = target.latitude;
      _longitude = target.longitude;
      if (target.address.isNotEmpty) {
        _addressController.text = target.address;
      }
      if (target.city.isNotEmpty) {
        _districtController.text = target.city;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Titik koordinat berhasil diperbarui: (${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)})'),
        backgroundColor: AppColors.primaryAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua kolom wajib.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_currentPhotoUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih atau unggah foto kamar/kos terlebih dahulu.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final priceCleaned = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final newKosId = 'kos_${DateTime.now().millisecondsSinceEpoch}';

    final newKos = KosModel(
      id: newKosId,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      district: _districtController.text.trim(),
      price: priceCleaned,
      pricePeriod: '/ bulan',
      type: _selectedType,
      latitude: _latitude,
      longitude: _longitude,
      imageUrl: _currentPhotoUrl.trim(),
      remainingRooms: _remainingRooms,
      totalRooms: _totalRooms,
      facilities: _selectedFacilities,
      rating: 5.0,
      reviewCount: 0,
      isPremium: false,
      ownerPhone: _phoneController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Kos modern dan nyaman dengan lokasi strategis, fasilitas lengkap, dan lingkungan asri.',
    );

    context.read<KatalogProvider>().addKos(newKos);
    context.read<AuthProvider>().addManagedKos(newKosId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat! "${newKos.name}" berhasil didaftarkan ke Kost Point.'),
        backgroundColor: AppColors.primaryAccent,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Daftarkan Kos Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            KosBasicInfoSection(
              nameController: _nameController,
              descriptionController: _descriptionController,
              selectedType: _selectedType,
              onTypeChanged: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: 16),
            KosMapLocationSection(
              latitude: _latitude,
              longitude: _longitude,
              addressController: _addressController,
              districtController: _districtController,
              onLocationPicked: _onLocationPicked,
            ),
            const SizedBox(height: 16),
            KosPricingRoomsSection(
              priceController: _priceController,
              totalRooms: _totalRooms,
              remainingRooms: _remainingRooms,
              onTotalRoomsChanged: (val) => setState(() => _totalRooms = val),
              onRemainingRoomsChanged: (val) => setState(() => _remainingRooms = val),
            ),
            const SizedBox(height: 16),
            KosPhotoPickerSection(
              photoUrlController: _photoUrlController,
              currentPhotoUrl: _currentPhotoUrl,
              onPhotoSelected: (url) => setState(() => _currentPhotoUrl = url),
            ),
            const SizedBox(height: 16),
            KosFacilitiesPickerSection(
              selectedFacilities: _selectedFacilities,
              onFacilitiesChanged: (list) => setState(() => _selectedFacilities = list),
            ),
            const SizedBox(height: 16),
            KosContactProSection(
              phoneController: _phoneController,
              isPro: _isPro,
              onProChanged: (val) => setState(() => _isPro = val),
            ),
            const SizedBox(height: 24),
            _SubmitButton(onPressed: _submitForm),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
      label: const Text(
        'Simpan & Daftarkan Kos',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

