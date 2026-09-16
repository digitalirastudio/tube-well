import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  DatabaseReference get database => _database;

  DatabaseReference get userDatabase {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    return _database.child('users').child(user.uid);
  }

  Future<void> addCustomer({
    required String name,
    required String mobileNumber,
    required double ratePerHour,
    required String note,
  }) async {
    final customerRef = userDatabase.child('customers').push();

    await customerRef
        .set({
          'name': name.trim(),
          'mobileNumber': mobileNumber.trim(),
          'ratePerHour': ratePerHour,
          'note': note.trim(),
          'createdAt': ServerValue.timestamp,
        })
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
  }

  Future<void> testDatabaseConnection() async {
    final userDatabase = this.userDatabase;

    await userDatabase.child('test').set({
      'message': 'TubeWell database connected',
      'timestamp': ServerValue.timestamp,
    });
  }
}
