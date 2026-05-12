enum UserRole { client, provider }

enum UserStatus { active, suspended, deleted }

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
    this.status = UserStatus.active,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final String? avatarUrl;
  final UserStatus status;

  bool get isClient => role == UserRole.client;
  bool get isProvider => role == UserRole.provider;

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    String? avatarUrl,
    UserStatus? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: UserRole.values.byName(map['role'] as String? ?? 'client'),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      avatarUrl: map['avatarUrl'] as String?,
      status: UserStatus.values.byName(map['status'] as String? ?? 'active'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'status': status.name,
    };
  }
}
