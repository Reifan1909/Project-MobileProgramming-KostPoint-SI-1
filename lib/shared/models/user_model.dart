enum UserRole {
  guest,
  penyewa,
  pemilik,
}

/// Model Pengguna Kost Point Mobile
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatarUrl;
  final String? institution; // misal nama kampus: "UPI YPTK Padang"
  final List<String> managedKosIds;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.institution,
    this.managedKosIds = const [],
  });

  bool get isPenyewa => role == UserRole.penyewa;
  bool get isPemilik => role == UserRole.pemilik;
  bool get isGuest => role == UserRole.guest;

  String get roleDisplayName {
    switch (role) {
      case UserRole.penyewa:
        return 'Penyewa (Mahasiswa)';
      case UserRole.pemilik:
        return 'Pemilik Kos';
      case UserRole.guest:
        return 'Tamu (Guest)';
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    String? institution,
    List<String>? managedKosIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      institution: institution ?? this.institution,
      managedKosIds: managedKosIds ?? this.managedKosIds,
    );
  }
}

