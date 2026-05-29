import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:servi_sur/shared/domain/entities/user_model.dart';

class AccountServiceException implements Exception {
  const AccountServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AccountService {
  AccountService({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore,
      _firebaseAuth = firebaseAuth;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _firebaseAuth;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _adminActivity =>
      _db.collection('adminActivity');

  Stream<List<UserModel>> watchUsers() {
    try {
      return _users.orderBy('createdAt', descending: true).snapshots().map((
        snapshot,
      ) {
        return snapshot.docs
            .map((doc) => UserModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      });
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return Stream<List<UserModel>>.value(const []);
      }
      rethrow;
    }
  }

  Future<List<UserModel>> listUsers() async {
    try {
      final snapshot = await _users
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return const [];
      }
      throw AccountServiceException(_firestoreMessage(error));
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final snapshot = await _users.doc(uid).get();
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return UserModel.fromMap({...data, 'id': snapshot.id});
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return null;
      }
      throw AccountServiceException(_firestoreMessage(error));
    }
  }

  Future<void> updateOwnProfile({
    required String uid,
    required String name,
    required String phone,
    String? avatarUrl,
  }) async {
    await _updateUserDocument(uid, {
      'name': name.trim(),
      'fullName': name.trim(),
      'phone': phone.trim(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserAsAdmin({
    required String adminId,
    required String targetUserId,
    required String name,
    required String phone,
    required UserRole role,
    required UserStatus status,
    UserModel? previousUser,
  }) async {
    await _updateUserDocument(targetUserId, {
      'name': name.trim(),
      'fullName': name.trim(),
      'phone': phone.trim(),
      'role': role.name,
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await registerAdminActivity(
      adminId: adminId,
      targetUserId: targetUserId,
      action: 'user_updated',
      previousValue: previousUser?.toMap(),
      newValue: {
        'name': name.trim(),
        'phone': phone.trim(),
        'role': role.name,
        'status': status.name,
      },
    );
  }

  Future<void> changeStatus({
    required String adminId,
    required String targetUserId,
    required UserStatus status,
    UserStatus? previousStatus,
  }) async {
    await _updateUserDocument(targetUserId, {
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await registerAdminActivity(
      adminId: adminId,
      targetUserId: targetUserId,
      action: switch (status) {
        UserStatus.suspended => 'user_blocked',
        UserStatus.active when previousStatus == UserStatus.suspended =>
          'user_unblocked',
        UserStatus.active => 'user_activated',
        UserStatus.inactive => 'user_deactivated',
        UserStatus.deleted => 'user_deleted',
      },
      previousValue: previousStatus?.name,
      newValue: status.name,
    );
  }

  Future<void> changeRole({
    required String adminId,
    required String targetUserId,
    required UserRole role,
    UserRole? previousRole,
  }) async {
    await _updateUserDocument(targetUserId, {
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await registerAdminActivity(
      adminId: adminId,
      targetUserId: targetUserId,
      action: 'user_role_changed',
      previousValue: previousRole?.name,
      newValue: role.name,
    );
  }

  Future<void> createBasicAccountAsAdmin({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    required UserStatus status,
  }) async {
    throw const AccountServiceException(
      'Crear usuarios desde admin requiere Cloud Functions/Admin SDK para no cambiar la sesion actual.',
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AccountServiceException(_authMessage(error.code));
    }
  }

  Future<void> updateCurrentPassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AccountServiceException('Debes iniciar sesion nuevamente.');
    }
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      throw AccountServiceException(_authMessage(error.code));
    }
  }

  Future<void> registerAdminActivity({
    required String adminId,
    required String targetUserId,
    required String action,
    Object? previousValue,
    Object? newValue,
  }) async {
    try {
      await _adminActivity.add({
        'adminId': adminId,
        'targetUserId': targetUserId,
        'action': action,
        'previousValue': ?previousValue,
        'newValue': ?newValue,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return;
      }
      throw AccountServiceException(_firestoreMessage(error));
    }
  }

  Future<void> _updateUserDocument(
    String uid,
    Map<String, Object?> data,
  ) async {
    try {
      await _users.doc(uid).update(data);
    } on FirebaseException catch (error) {
      throw AccountServiceException(_firestoreMessage(error));
    }
  }

  static Map<String, Object?> safeOwnProfileUpdate({
    required String name,
    required String phone,
    String? avatarUrl,
  }) {
    return {
      'name': name.trim(),
      'fullName': name.trim(),
      'phone': phone.trim(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl.trim(),
    };
  }

  String _firestoreMessage(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'No tienes permisos para realizar esta accion en Firebase.',
      'unavailable' => 'Firebase no esta disponible. Intenta de nuevo.',
      _ => 'No se pudo completar la accion en Firestore.',
    };
  }

  String _authMessage(String code) {
    return switch (code) {
      'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
      'invalid-email' => 'El correo electronico no tiene un formato valido.',
      'weak-password' => 'La contrasena debe tener al menos 6 caracteres.',
      'requires-recent-login' =>
        'Por seguridad, vuelve a iniciar sesion e intenta de nuevo.',
      _ => 'No se pudo completar la accion en Firebase Auth.',
    };
  }
}
