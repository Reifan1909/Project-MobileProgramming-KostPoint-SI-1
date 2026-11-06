import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../pemilik/screens/dashboard_pemilik_screen.dart';

/// Halaman Profil & Pengaturan (Menu Bar Tab Profil).
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profil & Akun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.isLoggedIn && user != null)
            _LoggedInHeaderCard(user: user)
          else
            const _NotLoggedInHeaderCard(),
          const SizedBox(height: 18),
          if (auth.isLoggedIn && auth.isPemilik) ...[
            _PemilikShortcutCard(
              onOpenDashboard: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPemilikScreen()),
                );
              },
            ),
            const SizedBox(height: 18),
          ],
          if (!auth.isLoggedIn) ...[
            const _LoginActionCard(),
            const SizedBox(height: 18),
          ],
          const _AppSettingsSection(),
          if (auth.isLoggedIn) ...[
            const SizedBox(height: 20),
            _LogoutButton(onLogout: () => auth.logout()),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LoggedInHeaderCard extends StatelessWidget {
  final UserModel user;

  const _LoggedInHeaderCard({required this.user});

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
            radius: 28,
            backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.15),
            child: Icon(
              user.isPemilik ? Icons.storefront_rounded : Icons.school_rounded,
              size: 30,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
                ),
                if (user.institution != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.institution!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryAccent),
            ),
            child: Text(
              user.isPemilik ? 'Pemilik' : 'Penyewa',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotLoggedInHeaderCard extends StatelessWidget {
  const _NotLoggedInHeaderCard();

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
            radius: 28,
            backgroundColor: AppColors.surfaceBorderSoft.withValues(alpha: 0.6),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 32,
              color: AppColors.textSecondaryMuted,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum Masuk Akun',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Masuk untuk mengakses semua fitur',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceBorderSoft.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceBorderSoft),
            ),
            child: const Text(
              'Belum Masuk',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PemilikShortcutCard extends StatelessWidget {
  final VoidCallback onOpenDashboard;

  const _PemilikShortcutCard({required this.onOpenDashboard});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryAccent.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primaryAccent),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.dashboard_rounded, color: AppColors.white, size: 20),
        ),
        title: const Text(
          'Buka Dashboard Pemilik Kos',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        subtitle: const Text(
          'Kelola ketersediaan kamar, koordinat peta & status Pro.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryAccent),
        onTap: onOpenDashboard,
      ),
    );
  }
}

/// Kartu Aksi Masuk Akun Tunggal
class _LoginActionCard extends StatelessWidget {
  const _LoginActionCard();

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
            'Masuk ke Akun',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Akses ulasan kos, simpan favorit, dan pengelolaan kos dengan masuk ke akun Anda.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.surfaceBorderSoft),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.login_rounded, color: AppColors.primaryAccent, size: 20),
              ),
              title: const Text(
                'Masuk ke Akun',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Pilih login sebagai Penyewa atau Pemilik Kos',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryAccent),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppSettingsSection extends StatelessWidget {
  const _AppSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.map_rounded, color: AppColors.primaryAccent),
            title: const Text('Cara Kerja Pencarian Peta Dinamis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondaryMuted),
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: AppColors.primaryAccent),
            title: const Text('Pusat Bantuan & FAQ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondaryMuted),
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryAccent),
            title: const Text('Tentang Kost Point Mobile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Versi 1.0.0+1 (Material 3)', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onLogout,
      icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
      label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.danger),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
