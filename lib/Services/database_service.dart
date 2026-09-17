import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<String> addCustomer({
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
    return customerRef.key!;
  }

  Future<void> addRun({
    required String customerId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required double ratePerHour,
    required double totalAmount,
  }) async {
    final runRef = userDatabase
        .child('customers')
        .child(customerId)
        .child('runs')
        .push();

    await runRef
        .set({
          'date': date.toIso8601String(),
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'durationMinutes': durationMinutes,
          'ratePerHour': ratePerHour,
          'totalAmount': totalAmount,
          'createdAt': ServerValue.timestamp,
        })
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
  }

  Future<void> addPayment({
    required String customerId,
    required String customerName,
    required double amount,
    required DateTime date,
    required String note,
  }) async {
    final paymentRef = userDatabase
        .child('customers')
        .child(customerId)
        .child('payments')
        .push();

    await paymentRef
        .set({
          'customerName': customerName.trim(),
          'amount': amount,
          'date': date.toIso8601String(),
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
