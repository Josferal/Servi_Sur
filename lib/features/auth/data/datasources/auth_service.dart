import 'package:firebase_auth/firebase_auth.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return Stream<User?>.value(null);
      }
      rethrow;
    }
  }

  User? get currentUser {
    try {
      return _auth.currentUser;
    } on FirebaseException catch (error) {
      if (error.code == 'no-app') {
        return null;
      }
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_messageForCode(error.code));
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_messageForCode(error.code));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_messageForCode(error.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electronico no tiene un formato valido.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada. Contacta al soporte.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta registrada con este correo.';
      case 'operation-not-allowed':
        return 'El acceso con correo y contrasena no esta habilitado.';
      case 'weak-password':
        return 'La contrasena debe tener al menos 6 caracteres.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
      case 'network-request-failed':
        return 'No se pudo conectar con Firebase. Revisa tu conexion.';
      case 'requires-recent-login':
        return 'Por seguridad, vuelve a iniciar sesion e intenta de nuevo.';
      default:
        return 'No se pudo completar la autenticacion. Intenta de nuevo.';
    }
  }
}
