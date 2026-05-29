import 'package:servi_sur/shared/domain/entities/date_value_parser.dart';

enum UserRole { client, provider, admin }

enum UserStatus { active, inactive, suspended, deleted }

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
    this.updatedAt,
    this.lastLoginAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final String? avatarUrl;
  final UserStatus status;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  bool get isClient => role == UserRole.client;
  bool get isProvider => role == UserRole.provider;
  bool get isAdmin => role == UserRole.admin;

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    String? avatarUrl,
    UserStatus? status,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final id = _stringValue(map['id']).isNotEmpty
        ? _stringValue(map['id'])
        : _stringValue(map['uid']);
    final fullName = _stringValue(map['fullName']).isNotEmpty
        ? _stringValue(map['fullName'])
        : _stringValue(map['name']);

    return UserModel(
      id: id,
      fullName: fullName,
      email: _stringValue(map['email']),
      phone: _stringValue(map['phone']),
      role: _roleFromValue(map['role']),
      createdAt:
          dateTimeFromValue(map['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      avatarUrl: _nullableStringValue(map['avatarUrl']),
      status: _statusFromValue(map['status']),
      updatedAt: dateTimeFromValue(map['updatedAt']),
      lastLoginAt: dateTimeFromValue(map['lastLoginAt']),
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
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  static String _stringValue(Object? value) {
    if (value is String) {
      return value.trim();
    }
    return '';
  }

  static String? _nullableStringValue(Object? value) {
    final parsed = _stringValue(value);
    return parsed.isEmpty ? null : parsed;
  }

  static UserRole _roleFromValue(Object? value) {
    final parsed = _stringValue(value);
    for (final role in UserRole.values) {
      if (role.name == parsed) {
        return role;
      }
    }
    return UserRole.client;
  }

  static UserStatus _statusFromValue(Object? value) {
    final parsed = _stringValue(value);
    for (final status in UserStatus.values) {
      if (status.name == parsed) {
        return status;
      }
    }
    return UserStatus.active;
  }
}
