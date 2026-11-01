import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';

/// Provider Pengelolaan Autentikasi dan Sesi Pengguna
class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

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

    // Set user berdasarkan role yang dipilih
    if (role == UserRole.pemilik) {
      _currentUser = demoPemilik.copyWith(email: email.trim());
    } else {
      _currentUser = demoPenyewa.copyWith(email: email.trim());
    }

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

