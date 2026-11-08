import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/email_otp_service.dart';
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
  EmailOtpResult? _lastOtpResult;
  final Map<String, _StoredUserCredentials> _registeredUsers = {};

  static const String _storageKeyUsers = 'kostpoint_registered_users_v2';
  static const String _storageKeyCurrentUserId = 'kostpoint_active_user_id_v2';

  AuthProvider() {
    _initFromStorage();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  EmailOtpResult? get lastOtpResult => _lastOtpResult;
  String? get pendingOtp => _pendingOtp;

  bool get isLoggedIn =>
      _currentUser != null && _currentUser!.role != UserRole.guest;
  bool get isPenyewa => _currentUser?.role == UserRole.penyewa;
  bool get isPemilik => _currentUser?.role == UserRole.pemilik;
  UserRole get currentRole => _currentUser?.role ?? UserRole.guest;

  /// Akun Demo Bawaan untuk Keperluan Pengujian & Review Dosen/Penguji
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

  /// Inisialisasi data dari penyimpanan lokal SharedPreferences
  Future<void> _initFromStorage() async {
    // Daftarkan akun bawaan agar bisa diuji bila diperlukan
    _registeredUsers[demoPenyewa.email
        .toLowerCase()] = const _StoredUserCredentials(
      user: demoPenyewa,
      password: 'password123',
    );
    _registeredUsers[demoPemilik.email
        .toLowerCase()] = const _StoredUserCredentials(
      user: demoPemilik,
      password: 'password123',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString(_storageKeyUsers);
      if (usersRaw != null) {
        final Map<String, dynamic> decoded = jsonDecode(usersRaw);
        decoded.forEach((key, val) {
          final map = val as Map<String, dynamic>;
          _registeredUsers[key] = _StoredUserCredentials(
            user: UserModel.fromJson(map['user']),
            password: map['password'] as String,
          );
        });
      }

      final currentId = prefs.getString(_storageKeyCurrentUserId);
      if (currentId != null) {
        for (final cred in _registeredUsers.values) {
          if (cred.user.id == currentId) {
            _currentUser = cred.user;
            break;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading auth from storage: $e');
    }
  }

  Future<void> _saveUsersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = {};
      _registeredUsers.forEach((key, val) {
        toSave[key] = {'user': val.user.toJson(), 'password': val.password};
      });
      await prefs.setString(_storageKeyUsers, jsonEncode(toSave));
      if (_currentUser != null) {
        await prefs.setString(_storageKeyCurrentUserId, _currentUser!.id);
      } else {
        await prefs.remove(_storageKeyCurrentUserId);
      }
    } catch (e) {
      debugPrint('Error saving auth to storage: $e');
    }
  }

  /// Login Resmi dengan Validasi Akun Terdaftar & Kata Sandi
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

    if (!email.contains('@') || !email.contains('.')) {
      _errorMessage = 'Format email tidak valid.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final cleanEmail = email.trim().toLowerCase();

    // Validasi ketat: email HARUS terdaftar
    if (!_registeredUsers.containsKey(cleanEmail)) {
      _errorMessage =
          'Email belum terdaftar. Silakan daftar akun baru terlebih dahulu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final stored = _registeredUsers[cleanEmail]!;

    // Validasi kata sandi
    if (stored.password != password) {
      _errorMessage = 'Kata sandi salah. Silakan periksa kembali.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validasi kecocokan peran yang dipilih
    if (stored.user.role != role) {
      final registeredRoleName = stored.user.role == UserRole.pemilik
          ? 'Pemilik Kos'
          : 'Penyewa';
      final selectedRoleName = role == UserRole.pemilik
          ? 'Pemilik Kos'
          : 'Penyewa';
      _errorMessage =
          'Akun ini terdaftar sebagai $registeredRoleName, bukan $selectedRoleName. Silakan ubah tab peran di atas.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = stored.user;
    _errorMessage = null;
    _isLoading = false;
    await _saveUsersToStorage();
    notifyListeners();
    return true;
  }

  /// Generate dan kirim kode OTP 6-digit untuk verifikasi pendaftaran
  Future<String> requestRegistrationOtp({
    required String email,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();

    // Cegah pendaftaran jika email sudah pernah terdaftar
    if (_registeredUsers.containsKey(cleanEmail)) {
      _errorMessage =
          'Email ini sudah terdaftar. Silakan langsung masuk ke akun.';
      _isLoading = false;
      notifyListeners();
      return '';
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final random = Random();
    final otpCode = (100000 + random.nextInt(900000)).toString();
    _pendingOtp = otpCode;
    _pendingOtpEmail = cleanEmail;

    // Kirim email OTP via EmailOtpService
    _lastOtpResult = await EmailOtpService.sendOtpEmail(
      targetEmail: cleanEmail,
      otpCode: otpCode,
      recipientName: name,
    );

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
      _errorMessage = 'Sesi OTP telah berakhir. Silakan kirim ulang kode OTP.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (otpInput.trim() != _pendingOtp) {
      _errorMessage = 'Kode OTP yang Anda masukkan salah. Periksa kembali kotak masuk email Anda.';
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
          : (role == UserRole.penyewa
                ? 'Mahasiswa / Penyewa'
                : 'Pengelola Properti Kos'),
      avatarUrl: role == UserRole.pemilik
          ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&q=80'
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
    );

    // Simpan ke daftar user terdaftar
    _registeredUsers[cleanEmail] = _StoredUserCredentials(
      user: newUser,
      password: password,
    );
    _pendingOtp = null;
    _pendingOtpEmail = null;
    _currentUser = newUser;
    _errorMessage = null;

    // Simpan permanen ke SharedPreferences
    await _saveUsersToStorage();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Menambahkan ID kos yang baru didaftarkan ke akun pemilik aktif
  void addManagedKos(String kosId) {
    if (_currentUser != null) {
      final updatedList = List<String>.from(_currentUser!.managedKosIds)
        ..add(kosId);
      _currentUser = _currentUser!.copyWith(managedKosIds: updatedList);
      _saveUsersToStorage();
      notifyListeners();
    }
  }

  /// Menghapus ID kos dari daftar kelolaan pemilik
  void removeManagedKos(String kosId) {
    if (_currentUser != null) {
      final updatedList = List<String>.from(_currentUser!.managedKosIds)
        ..remove(kosId);
      _currentUser = _currentUser!.copyWith(managedKosIds: updatedList);
      _saveUsersToStorage();
      notifyListeners();
    }
  }

  /// Logout kembali ke Mode Tamu
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    _saveUsersToStorage();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
