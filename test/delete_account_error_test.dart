import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_well/Screens/profile_screen.dart';

void main() {
  test(
    'returns reauthentication guidance for requires-recent-login errors',
    () {
      final error = FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Please sign in again',
      );

      expect(
        getDeleteAccountErrorMessage(error),
        'Please sign in again and then try deleting your account.',
      );
    },
  );

  test('returns generic message for other Firebase auth errors', () {
    final error = FirebaseAuthException(
      code: 'unknown',
      message: 'Something unexpected happened',
    );

    expect(
      getDeleteAccountErrorMessage(error),
      'Could not delete account. Please try again.',
    );
  });
}
