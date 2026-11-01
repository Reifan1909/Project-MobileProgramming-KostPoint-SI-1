import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../providers/auth_provider.dart';

/// Halaman Autentikasi Login Utama.
/// Mematuhi Section 2 panduan: membedakan dengan jelas opsi Masuk sebagai Penyewa vs Pemilik Kos.
class LoginScreen extends StatefulWidget {
  final UserRole initialRole;

  const LoginScreen({
    super.key,
    this.initialRole = UserRole.penyewa,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late UserRole _selectedRole;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _fillDefaultCredentials();
  }

  void _fillDefaultCredentials() {
    if (_selectedRole == UserRole.pemilik) {
      _emailController.text = 'syamsul@pemilik.kostpoint.com';
      _passwordController.text = '123456';
    } else {
      _emailController.text = 'reifan@mhs.upiyptk.ac.id';
      _passwordController.text = '123456';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      _fillDefaultCredentials();
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${auth.currentUser?.name}!'),
          backgroundColor: AppColors.primaryAccent,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _handleDemoLogin() {
    final auth = context.read<AuthProvider>();
    auth.loginDemo(_selectedRole);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Masuk cepat sebagai ${auth.currentUser?.roleDisplayName} berhasil!'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Masuk ke Akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _LoginBrandingHeader(),
              const SizedBox(height: 18),
              _RoleSegmentedTab(
                selectedRole: _selectedRole,
                onSelectRole: _onRoleChanged,
              ),
              const SizedBox(height: 20),
              _LoginFormCard(
                selectedRole: _selectedRole,
                emailController: _emailController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                onSubmit: _handleLogin,
              ),
              const SizedBox(height: 18),
              _DemoQuickLoginCard(
                selectedRole: _selectedRole,
                onDemoLogin: _handleDemoLogin,
                onContinueGuest: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header Brand Kost Point
class _LoginBrandingHeader extends StatelessWidget {
  const _LoginBrandingHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_city_rounded,
            size: 38,
            color: AppColors.primaryAccent,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Kost Point',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pencarian Kos Fleksibel Berbasis Titik Peta Dinamis',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryMuted,
          ),
        ),
      ],
    );
  }
}

/// Pemilih Peran (Segmented Tab) Sesuai Panduan Section 2
class _RoleSegmentedTab extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onSelectRole;

  const _RoleSegmentedTab({
    required this.selectedRole,
    required this.onSelectRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceBorderSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleTabItem(
              icon: Icons.school_rounded,
              title: 'Penyewa',
              subtitle: 'Mahasiswa / Tamu',
              isSelected: selectedRole == UserRole.penyewa,
              onTap: () => onSelectRole(UserRole.penyewa),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _RoleTabItem(
              icon: Icons.storefront_rounded,
              title: 'Pemilik Kos',
              subtitle: 'Kelola Kamar & Iklan',
              isSelected: selectedRole == UserRole.pemilik,
              onTap: () => onSelectRole(UserRole.pemilik),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTabItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTabItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primaryAccent, width: 1.5) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondaryMuted,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primaryAccent : AppColors.textSecondaryMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu Form Login dengan Input Email & Password
class _LoginFormCard extends StatelessWidget {
  final UserRole selectedRole;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _LoginFormCard({
    required this.selectedRole,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedRole == UserRole.pemilik
                ? 'Masuk sebagai Pemilik Kos'
                : 'Masuk sebagai Penyewa',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedRole == UserRole.pemilik
                ? 'Kelola kamar kosong, pasang pin peta, & upgrade PRO'
                : 'Beri ulasan kos, simpan favorit, & WhatsApp langsung',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryMuted,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Akun',
              hintText: 'nama@email.com',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryAccent),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Kata Sandi',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryAccent),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.textSecondaryMuted,
                ),
                onPressed: onToggleObscure,
              ),
            ),
          ),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : onSubmit,
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Masuk Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bagian Demo Cepat & Lanjut sebagai Tamu
class _DemoQuickLoginCard extends StatelessWidget {
  final UserRole selectedRole;
  final VoidCallback onDemoLogin;
  final VoidCallback onContinueGuest;

  const _DemoQuickLoginCard({
    required this.selectedRole,
    required this.onDemoLogin,
    required this.onContinueGuest,
  });

  @override
  Widget build(BuildContext context) {
    final roleName = selectedRole == UserRole.pemilik ? 'Pemilik Kos' : 'Penyewa';

    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: onDemoLogin,
          icon: const Icon(Icons.flash_on_rounded, color: AppColors.primaryAccent, size: 18),
          label: Text('Login Cepat Demo ($roleName)'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onContinueGuest,
          child: const Text(
            'Lanjutkan Tanpa Login (Mode Guest)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryMuted,
            ),
          ),
        ),
      ],
    );
  }
}

