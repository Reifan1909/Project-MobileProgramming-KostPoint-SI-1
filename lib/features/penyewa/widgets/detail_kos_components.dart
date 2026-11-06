import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../shared/models/kos_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../../shared/models/user_model.dart';

/// Bagian 1: Header Info Kos (Nama, Tipe, Alamat, Rating)
class DetailHeaderInfo extends StatelessWidget {
  final KosModel kos;

  const DetailHeaderInfo({super.key, required this.kos});

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
          Row(
            children: [
              _TypeBadge(type: kos.type),
              const SizedBox(width: 8),
              if (kos.isPremium) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 12, color: AppColors.white),
                      SizedBox(width: 4),
                      Text(
                        'PRO / Unggulan',
                        style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              _AvailabilityBadge(remaining: kos.remainingRooms, total: kos.totalRooms),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            kos.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondaryMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${kos.address}, ${kos.district}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${kos.rating}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                '(${kos.reviewCount} ulasan penyewa)',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type.toLowerCase()) {
      case 'putri':
        bg = Colors.pink.withValues(alpha: 0.12);
        fg = Colors.pink.shade700;
        break;
      case 'putra':
        bg = Colors.blue.withValues(alpha: 0.12);
        fg = Colors.blue.shade700;
        break;
      default:
        bg = AppColors.primaryAccent.withValues(alpha: 0.15);
        fg = AppColors.primaryAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Kos $type',
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final int remaining;
  final int total;

  const _AvailabilityBadge({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final isAvailable = remaining > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.secondaryCardAccent.withValues(alpha: 0.35) : AppColors.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAvailable ? 'Sisa $remaining/$total Kamar' : 'Kamar Penuh',
        style: TextStyle(
          color: isAvailable ? AppColors.textPrimary : AppColors.danger,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Bagian 2: Estimasi Rute & Waktu Tempuh ke Titik Tujuan
class DetailRouteCard extends StatelessWidget {
  final KosModel kos;
  final DestinationTarget destination;

  const DetailRouteCard({
    super.key,
    required this.kos,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final distKm = DistanceCalculator.calculateDistanceKm(
      startLatitude: kos.latitude,
      startLongitude: kos.longitude,
      endLatitude: destination.latitude,
      endLongitude: destination.longitude,
    );
    final distText = DistanceCalculator.formatDistance(distKm);
    final motorMins = DistanceCalculator.estimateMotorbikeMinutes(distKm);
    final walkMins = DistanceCalculator.estimateWalkingMinutes(distKm);

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
              const Icon(Icons.alt_route_rounded, size: 20, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Jarak ke ${destination.name}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorderSoft),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TravelMetricItem(
                  icon: Icons.straighten_rounded,
                  label: 'Jarak Langsung',
                  value: distText,
                ),
                Container(height: 30, width: 1, color: AppColors.surfaceBorderSoft),
                _TravelMetricItem(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Sepeda Motor',
                  value: '± $motorMins menit',
                ),
                Container(height: 30, width: 1, color: AppColors.surfaceBorderSoft),
                _TravelMetricItem(
                  icon: Icons.directions_walk_rounded,
                  label: 'Jalan Kaki',
                  value: '± $walkMins menit',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelMetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TravelMetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryAccent),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryMuted),
        ),
      ],
    );
  }
}

/// Bagian 3: Daftar Fasilitas Kos
class DetailFacilitiesCard extends StatelessWidget {
  final List<String> facilities;

  const DetailFacilitiesCard({super.key, required this.facilities});

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
          const Text(
            'Fasilitas Kos & Kamar',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: facilities.map((fac) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorderSoft),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getFacilityIcon(fac),
                    const SizedBox(width: 6),
                    Text(
                      fac,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _getFacilityIcon(String name) {
    final lower = name.toLowerCase();
    IconData iconData = Icons.check_circle_outline_rounded;
    if (lower.contains('wifi')) iconData = Icons.wifi_rounded;
    if (lower.contains('ac')) iconData = Icons.ac_unit_rounded;
    if (lower.contains('mandi')) iconData = Icons.bathtub_outlined;
    if (lower.contains('kasur')) iconData = Icons.bed_rounded;
    if (lower.contains('parkir')) iconData = Icons.local_parking_rounded;
    if (lower.contains('dapur')) iconData = Icons.kitchen_rounded;
    if (lower.contains('cctv')) iconData = Icons.videocam_outlined;
    if (lower.contains('water') || lower.contains('hangat')) iconData = Icons.hot_tub_rounded;

    return Icon(iconData, size: 16, color: AppColors.primaryAccent);
  }
}

/// Bagian 4: Deskripsi & Peraturan Kos
class DetailDescriptionCard extends StatelessWidget {
  final String description;

  const DetailDescriptionCard({super.key, required this.description});

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
          const Text(
            'Deskripsi & Aturan Kos',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Bagian 5: Ulasan & Penilaian Bintang (Menggunakan flutter_rating_bar)
class DetailRatingSection extends StatefulWidget {
  final KosModel kos;

  const DetailRatingSection({super.key, required this.kos});

  @override
  State<DetailRatingSection> createState() => _DetailRatingSectionState();
}

class _DetailRatingSectionState extends State<DetailRatingSection> {
  double _userRating = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _handleSubmitReview(AuthProvider auth) {
    if (!auth.isLoggedIn) {
      _showLoginRequiredDialog(context, 'memberikan ulasan dan rating kos');
      return;
    }

    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terima kasih! Ulasan bintang Anda berhasil disimpan.'),
        backgroundColor: AppColors.primaryAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
          const Text(
            'Beri Ulasan Kos',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            auth.isLoggedIn
                ? 'Bagikan pengalaman Anda tentang kos ini sebagai ${auth.currentUser?.name}:'
                : 'Masuk akun untuk memberikan penilaian bintang & ulasan.',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
          ),
          const SizedBox(height: 12),
          if (!_submitted) ...[
            Center(
              child: RatingBar.builder(
                initialRating: _userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 32,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                onRatingUpdate: (rating) => setState(() => _userRating = rating),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Tulis komentar atau pengalaman Anda di sini...',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleSubmitReview(auth),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Kirim Ulasan Bintang'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ulasan Anda (${_userRating.toStringAsFixed(1)} ★) telah berhasil dicatat.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bagian 6: Bottom Bar Sticky (Harga & Tombol Hubungi via WhatsApp)
class DetailBottomActionBar extends StatelessWidget {
  final KosModel kos;
  final AuthProvider auth;

  const DetailBottomActionBar({
    super.key,
    required this.kos,
    required this.auth,
  });

  Future<void> _handleWhatsApp(BuildContext context) async {
    if (!auth.isLoggedIn) {
      _showLoginRequiredDialog(context, 'menghubungi pemilik kos melalui WhatsApp');
      return;
    }

    final message = 'Halo, saya tertarik dengan kos "${kos.name}" di ${kos.address}. Apakah masih ada kamar kosong yang tersedia?';
    final cleanPhone = kos.ownerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final finalPhone = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : cleanPhone;
    final url = Uri.parse('https://wa.me/$finalPhone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Membuka WhatsApp ke: $finalPhone')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomor kontak: $finalPhone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: const Border(top: BorderSide(color: AppColors.surfaceBorderSoft)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Biaya Sewa', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted)),
              Text(
                kos.formattedPrice,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleWhatsApp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // Hijau resmi WhatsApp
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: const Text(
                'Hubungi via WhatsApp',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog Pop-up bila aksi memerlukan login (Wajib Login untuk Penyewa)
void _showLoginRequiredDialog(BuildContext context, String actionText) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorderSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Perlu Masuk Akun',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorderSoft),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: AppColors.primaryAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Anda belum masuk ke akun. Silakan masuk terlebih dahulu untuk $actionText.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Nanti Saja'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(initialRole: UserRole.penyewa),
                      ),
                    );
                  },
                  child: const Text('Login Sekarang'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

