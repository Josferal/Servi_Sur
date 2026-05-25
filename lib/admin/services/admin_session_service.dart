import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';

class AdminSessionService {
  AdminSessionService({
    AuthService? authService,
    UserProfileService? profileService,
  }) : _authService = authService ?? AuthService(),
       _profileService = profileService ?? UserProfileService();

  final AuthService _authService;
  final UserProfileService _profileService;

  Future<bool> isSignedIn() async {
    final user = _authService.currentUser;
    if (user == null) {
      return false;
    }

    final profile = await _profileService.ensureUserProfile(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
    return _profileService.isActive(profile) && profile['role'] == 'admin';
  }

  Future<bool> signIn({
    required String email,
    required String password,
    bool remember = true,
  }) async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      return false;
    }

    final profile = await _profileService.ensureUserProfile(
      uid: user.uid,
      email: user.email ?? email,
      name: user.displayName,
    );
    final isAdmin =
        _profileService.isActive(profile) && profile['role'] == 'admin';
    if (!isAdmin) {
      await _authService.signOut();
    }

    // TODO(firebase): Promote admin authorization to custom claims enforced
    // by Firestore rules and Cloud Functions.
    return isAdmin;
  }

  Future<void> signOut() => _authService.signOut();
}
