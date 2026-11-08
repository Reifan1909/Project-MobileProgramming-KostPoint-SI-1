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
        return 'Belum Masuk';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'institution': institution,
      'managedKosIds': managedKosIds,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.penyewa,
      ),
      avatarUrl: json['avatarUrl'] as String?,
      institution: json['institution'] as String?,
      managedKosIds: (json['managedKosIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

