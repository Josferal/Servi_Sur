import 'package:firebase_auth/firebase_auth.dart';

import 'package:servi_sur/features/admin/data/repositories/mock_admin_repository.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_activity.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_chart_segment.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_order_record.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_report_point.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_role_config.dart';
import 'package:servi_sur/features/admin/domain/entities/admin_settings.dart';
import 'package:servi_sur/features/admin/domain/repositories/admin_repository.dart';
import 'package:servi_sur/shared/data/datasources/account_service.dart';
import 'package:servi_sur/shared/domain/entities/service_category.dart';
import 'package:servi_sur/shared/domain/entities/service_item.dart';
import 'package:servi_sur/shared/domain/entities/user_model.dart';
import 'package:servi_sur/shared/domain/repositories/marketplace_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository(
    MarketplaceRepository marketplace, {
    AccountService? accountService,
    FirebaseAuth? firebaseAuth,
  }) : _fallback = MockAdminRepository(marketplace),
       _accountService = accountService ?? AccountService(),
       _firebaseAuth = firebaseAuth;

  final MockAdminRepository _fallback;
  final AccountService _accountService;
  final FirebaseAuth? _firebaseAuth;
  final List<UserModel> _users = [];
  String? _lastError;

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  @override
  String? get lastError => _lastError;

  @override
  UserModel get currentAdmin {
    String? uid;
    try {
      uid = _auth.currentUser?.uid;
    } on FirebaseException {
      uid = null;
    }
    if (uid != null) {
      for (final user in _users) {
        if (user.id == uid) {
          return user;
        }
      }
    }
    return _fallback.currentAdmin;
  }

  @override
  AdminSettings getSettings() => _fallback.getSettings();

  @override
  List<UserModel> getUsers() {
    if (_users.isEmpty) {
      return _fallback.getUsers();
    }
    return List.unmodifiable(_users);
  }

  @override
  Future<void> loadUsers() async {
    try {
      _lastError = null;
      final users = await _accountService.listUsers();
      if (users.isNotEmpty) {
        _users
          ..clear()
          ..addAll(users);
      }
    } on AccountServiceException catch (error) {
      _lastError = error.message;
    } on Object {
      _lastError = 'No se pudieron cargar usuarios desde Firebase.';
    }
  }

  @override
  bool updateUserStatus(String userId, UserStatus status) {
    final user = _cachedUser(userId);
    if (user == null ||
        user.id == currentAdmin.id && status != UserStatus.active) {
      return false;
    }

    _accountService
        .changeStatus(
          adminId: currentAdmin.id,
          targetUserId: userId,
          status: status,
          previousStatus: user.status,
        )
        .then((_) => loadUsers())
        .onError((Object error, StackTrace stackTrace) {
          _lastError = error is AccountServiceException
              ? error.message
              : 'No se pudo actualizar el estado del usuario.';
        });
    _replaceCached(user.copyWith(status: status, updatedAt: DateTime.now()));
    return true;
  }

  @override
  Future<bool> updateUser(
    String userId, {
    required String name,
    required String phone,
    required UserRole role,
    required UserStatus status,
  }) async {
    final previous = _cachedUser(userId);
    if (previous == null) {
      return false;
    }

    try {
      _lastError = null;
      await _accountService.updateUserAsAdmin(
        adminId: currentAdmin.id,
        targetUserId: userId,
        name: name,
        phone: phone,
        role: role,
        status: status,
        previousUser: previous,
      );
      _replaceCached(
        previous.copyWith(
          fullName: name,
          phone: phone,
          role: role,
          status: status,
          updatedAt: DateTime.now(),
        ),
      );
      return true;
    } on AccountServiceException catch (error) {
      _lastError = error.message;
      return false;
    }
  }

  @override
  Future<bool> createBasicUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required UserStatus status,
  }) async {
    try {
      _lastError = null;
      await _accountService.createBasicAccountAsAdmin(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        status: status,
      );
      await loadUsers();
      return true;
    } on AccountServiceException catch (error) {
      _lastError = error.message;
      return false;
    }
  }

  @override
  List<ServiceItem> getServices() => _fallback.getServices();

  @override
  List<AdminOrderRecord> getOrders() => _fallback.getOrders();

  @override
  List<ServiceCategory> getCategories() => _fallback.getCategories();

  @override
  List<AdminActivity> getRecentActivity() => _fallback.getRecentActivity();

  @override
  List<AdminReportPoint> getRevenueReport() => _fallback.getRevenueReport();

  @override
  List<AdminChartSegment> getOrderStatusSegments() =>
      _fallback.getOrderStatusSegments();

  @override
  List<AdminChartSegment> getUserRoleSegments() {
    final users = getUsers();
    return _fallback.getUserRoleSegments().map((segment) {
      final role = switch (segment.label) {
        'Clientes' => UserRole.client,
        'Proveedores' => UserRole.provider,
        _ => UserRole.admin,
      };
      return AdminChartSegment(
        label: segment.label,
        value: users.where((user) => user.role == role).length.toDouble(),
        colorValue: segment.colorValue,
      );
    }).toList();
  }

  @override
  List<AdminRoleConfig> getRoles() => _fallback.getRoles();

  @override
  bool updateServiceStatus(String serviceId, ServiceStatus status) =>
      _fallback.updateServiceStatus(serviceId, status);

  @override
  bool deleteService(String serviceId) => _fallback.deleteService(serviceId);

  @override
  bool updateOrderStatus(String orderId, String status) =>
      _fallback.updateOrderStatus(orderId, status);

  UserModel? _cachedUser(String userId) {
    for (final user in getUsers()) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }

  void _replaceCached(UserModel user) {
    final index = _users.indexWhere((cached) => cached.id == user.id);
    if (index == -1) {
      _users.insert(0, user);
      return;
    }
    _users[index] = user;
  }
}
