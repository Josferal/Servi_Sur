import 'package:shared_preferences/shared_preferences.dart';

class AdminSessionService {
  static const _sessionKey = 'servi_sur_admin_session';
  static const validEmail = 'admin@servimarket.com';
  static const validPassword = 'admin123';

  Future<bool> isSignedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_sessionKey) ?? false;
  }

  bool validateCredentials(String email, String password) {
    return email.trim().toLowerCase() == validEmail &&
        password == validPassword;
  }

  Future<bool> signIn({
    required String email,
    required String password,
    bool remember = true,
  }) async {
    if (!validateCredentials(email, password)) {
      return false;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_sessionKey, remember);
    return true;
  }

  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }
}
