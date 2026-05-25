import 'package:flutter_test/flutter_test.dart';
import 'package:servi_sur/services/auth_service.dart';
import 'package:servi_sur/services/user_profile_service.dart';

void main() {
  test('auth service tolerates missing Firebase app in tests', () async {
    final service = AuthService();

    expect(service.currentUser, isNull);
    await expectLater(service.authStateChanges, emits(isNull));
  });

  test(
    'user profile service tolerates missing Firebase app in tests',
    () async {
      final service = UserProfileService();

      expect(await service.getUserProfile('missing-test-user'), isNull);
    },
  );
}
