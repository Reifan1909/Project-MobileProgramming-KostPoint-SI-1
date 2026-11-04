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

  Future<void> _handleGoogleLogin() async {
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _GoogleAccountPickerSheet(role: _selectedRole),
    );

    if (selected != null && mounted) {
      final auth = context.read<AuthProvider>();
      await auth.loginWithGoogle(
        role: _selectedRole,
        email: selected['email'],
        name: selected['name'],
        avatarUrl: selected['avatar'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Masuk otomatis dengan akun Google: ${auth.currentUser?.name} berhasil!'),
            backgroundColor: AppColors.primaryAccent,
          ),
        );
        Navigator.pop(context);
      }
    }
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
              const SizedBox(height: 16),
              const _OrDivider(),
              const SizedBox(height: 16),
              _GoogleSignInButton(
                role: _selectedRole,
                onPressed: _handleGoogleLogin,
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

/// Pembatas divider antara form email dan Google Sign-In
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.surfaceBorderSoft, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ATAU MASUK DENGAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.surfaceBorderSoft, thickness: 1)),
      ],
    );
  }
}

/// Tombol Masuk Otomatis dengan Akun Google
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final UserRole role;

  const _GoogleSignInButton({
    required this.onPressed,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final roleLabel = role == UserRole.pemilik ? 'Pemilik Kos' : 'Penyewa';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorderSoft, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(
                  painter: _GoogleLogoPainter(),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Masuk Otomatis dengan Akun Google ($roleLabel)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter untuk logo Google 4-warna resmi (Merah, Kuning, Hijau, Biru)
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const pi = 3.1415926535897932;
    // Blue arc (-45 to 45 deg)
    canvas.drawArc(rect, -pi / 4, pi / 2, false, paintBlue);
    // Green arc (45 to 135 deg)
    canvas.drawArc(rect, pi / 4, pi / 2, false, paintGreen);
    // Yellow arc (135 to 225 deg)
    canvas.drawArc(rect, 3 * pi / 4, pi / 2, false, paintYellow);
    // Red arc (225 to 315 deg)
    canvas.drawArc(rect, 5 * pi / 4, pi / 2, false, paintRed);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTRB(w * 0.44, h * 0.39, w * 0.96, h * 0.61);
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Modal BottomSheet Pemilih Akun Google (Simulasi Google Play Services Account Picker)
class _GoogleAccountPickerSheet extends StatelessWidget {
  final UserRole role;

  const _GoogleAccountPickerSheet({required this.role});

  @override
  Widget build(BuildContext context) {
    final isOwner = role == UserRole.pemilik;

    final accounts = isOwner
        ? [
            {
              'name': 'Haji Syamsul Bahri',
              'email': 'syamsul.bahri@gmail.com',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&q=80',
              'tag': 'Akun Google Utama • Terverifikasi',
            },
            {
              'name': 'Kost Point Partner (Bisnis)',
              'email': 'partner.kostpoint@gmail.com',
              'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
              'tag': 'Akun Bisnis Properti Kos',
            },
          ]
        : [
            {
              'name': 'Reifan Mardatilla',
              'email': 'reifan.mardatilla@gmail.com',
              'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
              'tag': 'Akun Google Pribadi',
            },
            {
              'name': 'Reifan Mardatilla (Akademik)',
              'email': 'reifan@mhs.upiyptk.ac.id',
              'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
              'tag': 'Email Google Suite Kampus UPI YPTK',
            },
          ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorderSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: CustomPaint(painter: _GoogleLogoPainter()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Akun Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'untuk melanjutkan ke Kost Point (${isOwner ? "Pemilik Kos" : "Penyewa"})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          const SizedBox(height: 8),
          ...accounts.map((acc) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(acc['avatar']!),
                backgroundColor: AppColors.surfaceBorderSoft,
              ),
              title: Text(
                acc['name']!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    acc['email']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  Text(
                    acc['tag']!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondaryMuted,
              ),
              onTap: () => Navigator.pop(context, acc),
            );
          }),
          const SizedBox(height: 4),
          const Divider(height: 1, color: AppColors.surfaceBorderSoft),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.backgroundColor,
              child: Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppColors.textSecondaryMuted),
            ),
            title: const Text(
              'Gunakan Akun Google Lain',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context, {
                'name': isOwner ? 'Mitra Baru Pemilik' : 'Penyewa Baru Kost Point',
                'email': isOwner ? 'mitra.baru@gmail.com' : 'penyewa.baru@gmail.com',
                'avatar': isOwner
                    ? 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80'
                    : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80',
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Kost Point akan mengakses info profil publik dan alamat email Google Anda untuk autentikasi otomatis tanpa memasukkan kata sandi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondaryMuted.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

