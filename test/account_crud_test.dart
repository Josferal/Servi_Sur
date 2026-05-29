import 'package:flutter_test/flutter_test.dart';
import 'package:servi_sur/features/admin/data/repositories/mock_admin_repository.dart';
import 'package:servi_sur/services/account_service.dart';
import 'package:servi_sur/shared/data/repositories/mock_marketplace_repository.dart';
import 'package:servi_sur/shared/domain/entities/user_model.dart';

void main() {
  test('UserModel.fromMap tolerates missing fields', () {
    final user = UserModel.fromMap(const {});

    expect(user.id, isEmpty);
    expect(user.fullName, isEmpty);
    expect(user.email, isEmpty);
    expect(user.phone, isEmpty);
    expect(user.role, UserRole.client);
    expect(user.status, UserStatus.active);
    expect(user.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('UserModel.fromMap falls back for unknown role and status', () {
    final user = UserModel.fromMap(const {
      'id': 'u1',
      'name': 'Ana',
      'email': 'ana@example.com',
      'role': 'owner',
      'status': 'paused',
    });

    expect(user.fullName, 'Ana');
    expect(user.role, UserRole.client);
    expect(user.status, UserStatus.active);
  });

  test('safe own profile update only includes allowed profile fields', () {
    final update = AccountService.safeOwnProfileUpdate(
      name: ' Ana ',
      phone: ' 8888-0000 ',
      avatarUrl: ' https://example.com/a.png ',
    );

    expect(
      update.keys,
      containsAll(['name', 'fullName', 'phone', 'avatarUrl']),
    );
    expect(update.keys, isNot(contains('role')));
    expect(update.keys, isNot(contains('status')));
    expect(update['name'], 'Ana');
    expect(update['phone'], '8888-0000');
  });

  test('MockAdminRepository still updates user status', () async {
    final repository = MockAdminRepository(MockMarketplaceRepository());
    final target = repository.getUsers().firstWhere(
      (user) => user.role == UserRole.client && user.id != 'admin-001',
    );

    final success = repository.updateUserStatus(target.id, UserStatus.inactive);

    expect(success, isTrue);
    expect(
      repository.getUsers().firstWhere((user) => user.id == target.id).status,
      UserStatus.inactive,
    );
  });
}
