import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String role = 'client',
    String status = 'active',
  }) {
    final now = FieldValue.serverTimestamp();

    return _users.doc(uid).set({
      'uid': uid,
      'id': uid,
      'name': name.trim(),
      'fullName': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': '',
      'role': role,
      'status': status,
      'createdAt': now,
      'updatedAt': now,
      'lastLoginAt': now,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> ensureUserProfile({
    required String uid,
    required String email,
    String? name,
  }) async {
    final profile = await getUserProfile(uid);
    if (profile != null) {
      return profile;
    }

    await createUserProfile(uid: uid, name: name ?? '', email: email);
    return {
      'uid': uid,
      'id': uid,
      'name': (name ?? '').trim(),
      'fullName': (name ?? '').trim(),
      'email': email.trim().toLowerCase(),
      'phone': '',
      'role': 'client',
      'status': 'active',
    };
  }

  Future<void> touchLastLogin(String uid) {
    return _users.doc(uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final snapshot = await _users.doc(uid).get();
      return snapshot.data();
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return null;
      }
      rethrow;
    }
  }

  Future<String?> getUserRole(String uid) async {
    final profile = await getUserProfile(uid);
    return profile?['role'] as String?;
  }

  Future<String?> getUserStatus(String uid) async {
    final profile = await getUserProfile(uid);
    return profile?['status'] as String?;
  }

  bool isActive(Map<String, dynamic>? profile) {
    return profile?['status'] == null || profile?['status'] == 'active';
  }
}
