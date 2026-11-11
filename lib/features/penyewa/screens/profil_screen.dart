import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/katalog_provider.dart';

// Halaman bantuan & about
import 'dynamic_map_help_page.dart';
import 'faq_help_page.dart';
import 'about_app_page.dart';

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
                context.read<KatalogProvider>().setNavIndex(2);
              },
            ),
            const SizedBox(height: 18),
          ],
          if (!auth.isLoggedIn) ...[
            const _LoginActionCard(),
            const SizedBox(height: 18),
          ],
          const _AppSettingsSection(),
          if (auth.isLoggedIn && user != null) ...[
            const SizedBox(height: 18),
            _AccountActionsCard(
              onLogout: () => _showLogoutConfirmation(context, auth),
              onDeleteAccount: () => _showDeleteAccountDialog(context, user),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardSurface,
        title: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Kost Point?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondaryMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, UserModel user) {
    context.read<AuthProvider>().clearError();
    showDialog(
      context: context,
      builder: (_) => _DeleteAccountDialog(user: user),
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
          child: const Icon(Icons.storefront_rounded, color: AppColors.white, size: 20),
        ),
        title: const Text(
          'Menu Kos Saya',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        subtitle: const Text(
          'Kelola ketersediaan kamar, foto, dan data properti kos Anda.',
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DynamicMapHelpPage()),
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryAccent),
            title: const Text('Tentang Kost Point Mobile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Versi 1.0.0+1 (Material 3)', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutAppPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountActionsCard extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const _AccountActionsCard({
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Pengaturan Akun & Keamanan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.textSecondaryMuted, size: 20),
            title: const Text('Keluar dari Akun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondaryMuted),
            onTap: onLogout,
          ),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 20),
            title: const Text(
              'Hapus Akun Permanen',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.danger),
            ),
            subtitle: const Text(
              'Hapus seluruh data akun secara permanen',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondaryMuted),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.danger),
            onTap: onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  final UserModel user;

  const _DeleteAccountDialog({required this.user});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.deleteCurrentAccount(
      confirmationPassword: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun Anda telah berhasil dihapus secara permanen.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.cardSurface,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hapus Akun Permanen?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menghapus akun "${widget.user.name}" (${widget.user.email})?',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'Tindakan ini tidak dapat dibatalkan. Semua data profil, preferensi, dan informasi akun akan dihapus permanen dari sistem.',
                  style: TextStyle(fontSize: 11, color: AppColors.danger, height: 1.35),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Masukkan kata sandi Anda untuk konfirmasi:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryMuted),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Saat Ini',
                  hintText: 'Masukkan kata sandi',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.danger),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textSecondaryMuted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Kata sandi wajib diisi untuk verifikasi.';
                  }
                  return null;
                },
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: auth.isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: AppColors.textSecondaryMuted, fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: auth.isLoading ? null : _handleDelete,
          child: auth.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                )
              : const Text('Hapus Akun'),
        ),
      ],
    );
  }
}
