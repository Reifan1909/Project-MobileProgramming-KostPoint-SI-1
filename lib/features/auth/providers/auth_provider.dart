import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';

class _StoredUserCredentials {
  final UserModel user;
  final String password;

  const _StoredUserCredentials({required this.user, required this.password});
}

/// Provider Pengelolaan Autentikasi dan Sesi Pengguna
class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Manajemen Registrasi & Verifikasi OTP
  String? _pendingOtp;
  String? _pendingOtpEmail;
  final Map<String, _StoredUserCredentials> _registeredUsers = {};

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _currentUser != null && _currentUser!.role != UserRole.guest;
  bool get isPenyewa => _currentUser?.role == UserRole.penyewa;
  bool get isPemilik => _currentUser?.role == UserRole.pemilik;
  UserRole get currentRole => _currentUser?.role ?? UserRole.guest;

  /// Akun Demo Cepat untuk Pengujian
  static const UserModel demoPenyewa = UserModel(
    id: 'user_penyewa_demo',
    name: 'Reifan Mardatilla',
    email: 'reifan@mhs.upiyptk.ac.id',
    phone: '081234567890',
    role: UserRole.penyewa,
    institution: 'Universitas Putra Indonesia "YPTK" Padang',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
  );

  static const UserModel demoPemilik = UserModel(
    id: 'user_pemilik_demo',
    name: 'Haji Syamsul Bahri',
    email: 'syamsul@pemilik.kostpoint.com',
    phone: '081298765432',
    role: UserRole.pemilik,
    institution: 'Pengelola Kos Graha YPTK',
    managedKosIds: ['kos_1'],
    avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&q=80',
  );

  /// Simulasi Login dengan Validasi Role
  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Email dan kata sandi wajib diisi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (!email.contains('@')) {
      _errorMessage = 'Format email tidak valid.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (password.length < 4) {
      _errorMessage = 'Kata sandi minimal 4 karakter.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final cleanEmail = email.trim().toLowerCase();

    // Periksa apakah user terdaftar lewat registrasi email manual
    if (_registeredUsers.containsKey(cleanEmail)) {
      final stored = _registeredUsers[cleanEmail]!;
      if (stored.password != password) {
        _errorMessage = 'Kata sandi salah. Silakan periksa kembali.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (stored.user.role != role) {
        final roleName = stored.user.role == UserRole.pemilik ? 'Pemilik Kos' : 'Penyewa';
        _errorMessage = 'Akun ini terdaftar sebagai $roleName. Silakan ubah tab pilihan peran di atas.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _currentUser = stored.user;
    } else {
      // Set user berdasarkan role yang dipilih
      if (role == UserRole.pemilik) {
        _currentUser = demoPemilik.copyWith(email: cleanEmail);
      } else {
        _currentUser = demoPenyewa.copyWith(email: cleanEmail);
      }
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Generate dan kirim kode OTP 6-digit untuk verifikasi pendaftaran
  Future<String> requestRegistrationOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final random = Random();
    final otpCode = (100000 + random.nextInt(900000)).toString();
    _pendingOtp = otpCode;
    _pendingOtpEmail = email.trim().toLowerCase();

    _isLoading = false;
    notifyListeners();
    return otpCode;
  }

  /// Verifikasi Kode OTP dan Selesaikan Pendaftaran Akun Baru
  Future<bool> verifyOtpAndRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    required String otpInput,
    String? institution,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final cleanEmail = email.trim().toLowerCase();

    if (_pendingOtp == null || _pendingOtpEmail != cleanEmail) {
      _errorMessage = 'Sesi OTP kadaluarsa. Silakan kirim ulang kode OTP.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (otpInput.trim() != _pendingOtp) {
      _errorMessage = 'Kode OTP yang Anda masukkan salah. Periksa kembali email Anda.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Buat objek UserModel baru
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: role,
      institution: institution?.trim().isNotEmpty == true
          ? institution!.trim()
          : (role == UserRole.penyewa ? 'Mahasiswa / Penyewa' : 'Pengelola Properti Kos'),
      avatarUrl: role == UserRole.pemilik
          ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&q=80'
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
    );

    // Simpan ke daftar user terdaftar
    _registeredUsers[cleanEmail] = _StoredUserCredentials(user: newUser, password: password);

    // Reset OTP pending dan tetapkan sebagai user aktif
    _pendingOtp = null;
    _pendingOtpEmail = null;
    _currentUser = newUser;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// 1-Click Demo Login untuk kemudahan evaluasi fitur
  void loginDemo(UserRole role) {
    if (role == UserRole.pemilik) {
      _currentUser = demoPemilik;
    } else {
      _currentUser = demoPenyewa;
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Login Otomatis dengan Akun Google
  Future<bool> loginWithGoogle({
    required UserRole role,
    String? email,
    String? name,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final isOwner = role == UserRole.pemilik;
    final defaultEmail = isOwner ? 'syamsul.bahri@gmail.com' : 'reifan.mardatilla@gmail.com';
    final defaultName = isOwner ? 'Haji Syamsul Bahri' : 'Reifan Mardatilla';
    final defaultAvatar = isOwner
        ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&q=80'
        : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80';

    if (isOwner) {
      _currentUser = demoPemilik.copyWith(
        email: email ?? defaultEmail,
        name: name ?? defaultName,
        avatarUrl: avatarUrl ?? defaultAvatar,
      );
    } else {
      _currentUser = demoPenyewa.copyWith(
        email: email ?? defaultEmail,
        name: name ?? defaultName,
        avatarUrl: avatarUrl ?? defaultAvatar,
      );
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Menambahkan ID kos yang baru didaftarkan ke akun pemilik aktif
  void addManagedKos(String kosId) {
    if (_currentUser != null) {
      final updatedList = List<String>.from(_currentUser!.managedKosIds)..add(kosId);
      _currentUser = _currentUser!.copyWith(managedKosIds: updatedList);
      notifyListeners();
    }
  }

  /// Menghapus ID kos dari daftar kelolaan pemilik
  void removeManagedKos(String kosId) {
    if (_currentUser != null) {
      final updatedList = List<String>.from(_currentUser!.managedKosIds)..remove(kosId);
      _currentUser = _currentUser!.copyWith(managedKosIds: updatedList);
      notifyListeners();
    }
  }

  /// Logout kembali ke Mode Guest
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

