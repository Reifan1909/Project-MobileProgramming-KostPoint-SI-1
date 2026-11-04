import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/kos_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../penyewa/providers/katalog_provider.dart';
import 'tambah_kos_screen.dart';

/// Dashboard Khusus Pemilik Kos (Section 1 & 3.A Panduan).
/// Mengelola ketersediaan kamar secara real-time, melihat status Pro, dan menentukan titik koordinat peta.
class DashboardPemilikScreen extends StatelessWidget {
  const DashboardPemilikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final katalog = context.watch<KatalogProvider>();
    final user = auth.currentUser;

    // Filter kos yang dikelola pemilik ini
    final managedKosList = katalog.allKos.where((k) {
      if (user != null && user.managedKosIds.isNotEmpty) {
        return user.managedKosIds.contains(k.id);
      }
      return k.id == 'kos_1';
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard Pemilik Kos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            tooltip: 'Keluar',
            onPressed: () {
              auth.logout();
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OwnerProfileHeader(user: user),
          const SizedBox(height: 16),
          _OwnerStatsRow(kosList: managedKosList),
          const SizedBox(height: 20),
          _ManagedKosSectionHeader(
            onAddNew: () => _openAddKosModal(context),
          ),
          const SizedBox(height: 10),
          if (managedKosList.isEmpty)
            _EmptyManagedKosCard(onAddNew: () => _openAddKosModal(context))
          else
            ...managedKosList.map((kos) => _ManagedKosItemCard(kos: kos)),
        ],
      ),
    );
  }

  void _openAddKosModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahKosScreen()),
    );
  }
}

class _EmptyManagedKosCard extends StatelessWidget {
  final VoidCallback onAddNew;

  const _EmptyManagedKosCard({required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.apartment_rounded, size: 40, color: AppColors.primaryAccent),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum Ada Kos Terdaftar',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daftarkan properti kos Anda sekarang untuk mulai menerima calon penyewa.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddNew,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Daftarkan Kos Sekarang'),
          ),
        ],
      ),
    );
  }
}

class _OwnerProfileHeader extends StatelessWidget {
  final dynamic user;

  const _OwnerProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.15),
            child: const Icon(Icons.storefront_rounded, color: AppColors.primaryAccent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Pemilik Kos',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.institution ?? 'Pengelola Kos Mitra Kost Point',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'MITRA PRO',
              style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerStatsRow extends StatelessWidget {
  final List<KosModel> kosList;

  const _OwnerStatsRow({required this.kosList});

  @override
  Widget build(BuildContext context) {
    final totalRooms = kosList.fold<int>(0, (sum, item) => sum + item.totalRooms);
    final remainingRooms = kosList.fold<int>(0, (sum, item) => sum + item.remainingRooms);
    final filledRooms = totalRooms - remainingRooms;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Kos',
            value: '${kosList.length}',
            icon: Icons.apartment_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Sisa Kamar',
            value: '$remainingRooms',
            icon: Icons.meeting_room_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Kamar Terisi',
            value: '$filledRooms',
            icon: Icons.person_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryAccent),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
          ),
        ],
      ),
    );
  }
}

class _ManagedKosSectionHeader extends StatelessWidget {
  final VoidCallback onAddNew;

  const _ManagedKosSectionHeader({required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Kos yang Dikelola',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        TextButton.icon(
          onPressed: onAddNew,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Tambah Kos'),
        ),
      ],
    );
  }
}

class _ManagedKosItemCard extends StatelessWidget {
  final KosModel kos;

  const _ManagedKosItemCard({required this.kos});

  @override
  Widget build(BuildContext context) {
    final katalog = context.read<KatalogProvider>();
    final auth = context.read<AuthProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  kos.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceBorderSoft,
                    child: const Icon(Icons.apartment_rounded, color: AppColors.textSecondaryMuted),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (kos.isPremium) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            kos.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${kos.type} • ${kos.district}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kos.formattedPrice,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryAccent),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                tooltip: 'Hapus Kos',
                onPressed: () => _confirmDeleteKos(context, kos, katalog, auth),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ketersediaan Kamar:', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted)),
                  Text(
                    '${kos.remainingRooms} dari ${kos.totalRooms} Kamar Kosong',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove_rounded, size: 16),
                    onPressed: kos.remainingRooms > 0
                        ? () => katalog.updateRoomAvailability(kos.id, kos.remainingRooms - 1)
                        : null,
                    tooltip: 'Kurangi kamar kosong',
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${kos.remainingRooms}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_rounded, size: 16),
                    onPressed: kos.remainingRooms < kos.totalRooms
                        ? () => katalog.updateRoomAvailability(kos.id, kos.remainingRooms + 1)
                        : null,
                    tooltip: 'Tambah kamar kosong',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteKos(BuildContext context, KosModel kos, KatalogProvider katalog, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kos Ini?'),
        content: Text('Apakah Anda yakin ingin menghapus "${kos.name}" dari sistem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.white),
            onPressed: () {
              Navigator.pop(ctx);
              katalog.deleteKos(kos.id);
              auth.removeManagedKos(kos.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kos "${kos.name}" berhasil dihapus.')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
