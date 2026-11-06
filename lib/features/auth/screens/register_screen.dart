import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../providers/auth_provider.dart';

/// Halaman Registrasi Akun Baru dengan Verifikasi OTP Email.
class RegisterScreen extends StatefulWidget {
  final UserRole initialRole;

  const RegisterScreen({
    super.key,
    this.initialRole = UserRole.penyewa,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late UserRole _selectedRole;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _institutionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final otpCode = await auth.requestRegistrationOtp(email);

    if (!mounted) return;

    _showOtpVerificationDialog(otpCode);
  }

  void _showOtpVerificationDialog(String initialOtpCode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OtpVerificationSheet(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        institution: _institutionController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        initialOtpCode: initialOtpCode,
        onSuccess: () {
          Navigator.pop(ctx); // Close OTP sheet
          Navigator.pop(context); // Close RegisterScreen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _selectedRole == UserRole.pemilik;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daftar Akun Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _RegisterHeader(),
                const SizedBox(height: 18),
                _RoleToggleSelector(
                  selectedRole: _selectedRole,
                  onRoleChanged: (role) => setState(() => _selectedRole = role),
                ),
                const SizedBox(height: 20),
                Container(
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
                        isOwner ? 'Data Pemilik Kos' : 'Data Penyewa Kos',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOwner
                            ? 'Daftarkan nama & no kontak untuk mengelola kos'
                            : 'Lengkapi info akun untuk menyewa & memberi ulasan',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          hintText: 'Masukkan nama sesuai KTP / KTM',
                          prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryAccent),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Email',
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryAccent),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi.';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Format email tidak valid.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor WhatsApp / HP',
                          hintText: 'Contoh: 081234567890',
                          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryAccent),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor HP/WhatsApp wajib diisi.';
                          }
                          if (value.trim().length < 9) {
                            return 'Nomor HP minimal 9 digit.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _institutionController,
                        decoration: InputDecoration(
                          labelText: isOwner ? 'Nama Properti / Usaha Kos' : 'Nama Kampus / Instansi (Opsional)',
                          hintText: isOwner ? 'Contoh: Kos Graha Sejahtera' : 'Contoh: UPI YPTK Padang',
                          prefixIcon: const Icon(Icons.business_outlined, color: AppColors.primaryAccent),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppColors.textSecondaryMuted,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi wajib diisi.';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi',
                          hintText: 'Ulangi kata sandi di atas',
                          prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.primaryAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppColors.textSecondaryMuted,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Konfirmasi kata sandi tidak cocok.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: auth.isLoading ? null : _handleSendOtp,
                              icon: const Icon(Icons.mark_email_read_rounded, size: 18),
                              label: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                                    )
                                  : const Text('Kirim Kode Verifikasi OTP'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk Sekarang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

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
            Icons.person_add_alt_1_rounded,
            size: 34,
            color: AppColors.primaryAccent,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Buat Akun Kost Point',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Daftar akun manual dengan verifikasi kode OTP email',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
        ),
      ],
    );
  }
}

class _RoleToggleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const _RoleToggleSelector({
    required this.selectedRole,
    required this.onRoleChanged,
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
            child: _RoleTabButton(
              icon: Icons.school_rounded,
              title: 'Penyewa',
              subtitle: 'Mahasiswa / Pencari Kos',
              isSelected: selectedRole == UserRole.penyewa,
              onTap: () => onRoleChanged(UserRole.penyewa),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _RoleTabButton(
              icon: Icons.storefront_rounded,
              title: 'Pemilik Kos',
              subtitle: 'Pengelola Kamar & Iklan',
              isSelected: selectedRole == UserRole.pemilik,
              onTap: () => onRoleChanged(UserRole.pemilik),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTabButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTabButton({
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
                    color: Colors.black.withValues(alpha: 0.05),
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

/// Modal BottomSheet Verifikasi Kode OTP Email
class _OtpVerificationSheet extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String? institution;
  final String password;
  final UserRole role;
  final String initialOtpCode;
  final VoidCallback onSuccess;

  const _OtpVerificationSheet({
    required this.name,
    required this.email,
    required this.phone,
    this.institution,
    required this.password,
    required this.role,
    required this.initialOtpCode,
    required this.onSuccess,
  });

  @override
  State<_OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<_OtpVerificationSheet> {
  final _otpController = TextEditingController();
  late String _currentOtpCode;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentOtpCode = widget.initialOtpCode;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleResendOtp() async {
    final auth = context.read<AuthProvider>();
    final newCode = await auth.requestRegistrationOtp(widget.email);
    setState(() {
      _currentOtpCode = newCode;
    });
    _startTimer();
  }

  Future<void> _handleVerify() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtpAndRegister(
      name: widget.name,
      email: widget.email,
      phone: widget.phone,
      institution: widget.institution,
      password: widget.password,
      role: widget.role,
      otpInput: _otpController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${widget.name}! Akun berhasil didaftarkan.'),
          backgroundColor: AppColors.primaryAccent,
        ),
      );
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mark_email_read_rounded, color: AppColors.primaryAccent, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verifikasi Kode OTP',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Masukkan kode 6-digit untuk aktivasi akun',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondaryMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Simulasi Notifikasi Penerimaan Email OTP
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, color: AppColors.primaryAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Simulasi Email Masuk:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryAccent),
                        ),
                        Text(
                          'Kode OTP verifikasi Anda: $_currentOtpCode',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _otpController.text = _currentOtpCode;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Isi Otomatis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kode dikirimkan ke: ${widget.email}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 10,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
                hintStyle: const TextStyle(fontSize: 20, letterSpacing: 8, color: AppColors.textSecondaryMuted),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleVerify,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : const Text('Verifikasi & Selesaikan Pendaftaran'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: _secondsRemaining > 0
                  ? Text(
                      'Kirim ulang kode dalam $_secondsRemaining detik',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryMuted),
                    )
                  : TextButton.icon(
                      onPressed: _handleResendOtp,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Kirim Ulang Kode OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
