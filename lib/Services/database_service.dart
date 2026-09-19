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

  Future<void> deleteUserData(String uid) async {
    if (uid.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    await _database
        .child('users')
        .child(uid)
        .remove()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
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

  // Get one customer's information
  Future<Map<String, dynamic>> getCustomer(String customerId) async {
    final snapshot = await userDatabase
        .child('customers')
        .child(customerId)
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );

    if (!snapshot.exists || snapshot.value == null) {
      throw Exception('Customer not found.');
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return data;
  }

  Future<void> updateCustomer({
    required String customerId,
    required String name,
    required String mobileNumber,
    required double ratePerHour,
    required String note,
  }) async {
    await userDatabase
        .child('customers')
        .child(customerId)
        .update({
          'name': name.trim(),
          'mobileNumber': mobileNumber.trim(),
          'ratePerHour': ratePerHour,
          'note': note.trim(),
        })
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
  }

  Future<void> deleteCustomer({required String customerId}) async {
    if (customerId.trim().isEmpty) {
      throw Exception('Customer ID is required.');
    }

    await userDatabase
        .child('customers')
        .child(customerId)
        .remove()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
  }

  Future<List<Map<String, dynamic>>> getCustomerRuns(String customerId) async {
    final snapshot = await userDatabase
        .child('customers')
        .child(customerId)
        .child('runs')
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final runs = data.entries.map((entry) {
      final run = Map<String, dynamic>.from(entry.value as Map);

      run['id'] = entry.key;

      return run;
    }).toList();

    runs.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1970);

      final bDate =
          DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1970);

      return bDate.compareTo(aDate);
    });

    return runs;
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

          // Save the rate used for this particular run.
          // This means old runs won't change when the customer's
          // current rate is updated later.
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

  Future<void> updatePayment({
    required String customerId,
    required String paymentId,
    required double amount,
    required DateTime date,
    required String note,
  }) async {
    if (paymentId.trim().isEmpty) {
      throw Exception('Payment ID is required to update a payment.');
    }

    await userDatabase
        .child('customers')
        .child(customerId)
        .child('payments')
        .child(paymentId)
        .update({
          'amount': amount,
          'date': date.toIso8601String(),
          'note': note.trim(),
        })
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
  }

  Future<void> deletePayment({
    required String customerId,
    required String paymentId,
  }) async {
    if (paymentId.trim().isEmpty) {
      throw Exception('Payment ID is required to delete a payment.');
    }

    await userDatabase
        .child('customers')
        .child(customerId)
        .child('payments')
        .child(paymentId)
        .remove()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
  }

  Future<void> updateRun({
    required String customerId,
    required String runId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required double ratePerHour,
    required double totalAmount,
  }) async {
    if (runId.trim().isEmpty) {
      throw Exception('Run ID is required to update a run.');
    }

    await userDatabase
        .child('customers')
        .child(customerId)
        .child('runs')
        .child(runId)
        .update({
          'date': date.toIso8601String(),
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'durationMinutes': durationMinutes,
          'ratePerHour': ratePerHour,
          'totalAmount': totalAmount,
        })
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );
  }

  Future<void> deleteRun({
    required String customerId,
    required String runId,
  }) async {
    if (runId.trim().isEmpty) {
      throw Exception('Run ID is required to delete a run.');
    }

    await userDatabase
        .child('customers')
        .child(customerId)
        .child('runs')
        .child(runId)
        .remove()
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

  Future<List<Map<String, dynamic>>> getCustomerPayments(
    String customerId,
  ) async {
    final snapshot = await userDatabase
        .child('customers')
        .child(customerId)
        .child('payments')
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final payments = data.entries.map((entry) {
      final payment = Map<String, dynamic>.from(entry.value as Map);
      payment['id'] = entry.key;
      return payment;
    }).toList();

    payments.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1970);

      final bDate =
          DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1970);

      return bDate.compareTo(aDate);
    });

    return payments;
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final snapshot = await userDatabase
        .child('customers')
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final customers = <Map<String, dynamic>>[];

    for (final entry in data.entries) {
      final customer = Map<String, dynamic>.from(entry.value as Map);

      double totalRuns = 0;
      double totalPayments = 0;

      // Calculate total run amount
      if (customer['runs'] != null) {
        final runs = Map<String, dynamic>.from(customer['runs'] as Map);

        for (final run in runs.values) {
          final runData = Map<String, dynamic>.from(run as Map);

          totalRuns += (runData['totalAmount'] as num?)?.toDouble() ?? 0;
        }
      }

      // Calculate total payments
      if (customer['payments'] != null) {
        final payments = Map<String, dynamic>.from(customer['payments'] as Map);

        for (final payment in payments.values) {
          final paymentData = Map<String, dynamic>.from(payment as Map);

          totalPayments += (paymentData['amount'] as num?)?.toDouble() ?? 0;
        }
      }

      final owed = totalRuns - totalPayments;

      customer['id'] = entry.key;
      customer['totalRuns'] = totalRuns;
      customer['totalPayments'] = totalPayments;
      customer['owed'] = owed < 0 ? 0 : owed;

      customers.add(customer);
    }

    customers.sort((a, b) {
      final nameA = a['name']?.toString().toLowerCase() ?? '';
      final nameB = b['name']?.toString().toLowerCase() ?? '';

      return nameA.compareTo(nameB);
    });

    return customers;
  }

  Future<Map<String, dynamic>> getThisMonthSummary() async {
    final snapshot = await userDatabase
        .child('customers')
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );

    if (!snapshot.exists || snapshot.value == null) {
      return {
        'outstanding': 0.0,
        'people': 0,
        'usageRecords': 0,
        'payments': 0,
      };
    }

    final customers = Map<String, dynamic>.from(snapshot.value as Map);

    final now = DateTime.now();

    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    double totalRuns = 0;
    double totalPayments = 0;

    int usageRecords = 0;
    int paymentRecords = 0;

    final Set<String> peopleWithOutstanding = {};

    for (final customerEntry in customers.entries) {
      final customerId = customerEntry.key;
      final customer = Map<String, dynamic>.from(customerEntry.value as Map);

      double customerRuns = 0;
      double customerPayments = 0;

      // -------------------------
      // THIS MONTH'S RUNS
      // -------------------------
      final runsData = customer['runs'];

      if (runsData != null) {
        final runs = Map<String, dynamic>.from(runsData as Map);

        for (final runEntry in runs.entries) {
          final run = Map<String, dynamic>.from(runEntry.value as Map);

          final date = DateTime.tryParse(run['date']?.toString() ?? '');

          if (date == null) continue;

          if (!date.isBefore(monthStart) && date.isBefore(nextMonthStart)) {
            final amount = (run['totalAmount'] as num?)?.toDouble() ?? 0;

            customerRuns += amount;
            totalRuns += amount;
            usageRecords++;
          }
        }
      }

      // -------------------------
      // THIS MONTH'S PAYMENTS
      // -------------------------
      final paymentsData = customer['payments'];

      if (paymentsData != null) {
        final payments = Map<String, dynamic>.from(paymentsData as Map);

        for (final paymentEntry in payments.entries) {
          final payment = Map<String, dynamic>.from(paymentEntry.value as Map);

          final date = DateTime.tryParse(payment['date']?.toString() ?? '');

          if (date == null) continue;

          if (!date.isBefore(monthStart) && date.isBefore(nextMonthStart)) {
            final amount = (payment['amount'] as num?)?.toDouble() ?? 0;

            customerPayments += amount;
            totalPayments += amount;
            paymentRecords++;
          }
        }
      }

      // This customer's remaining amount
      final customerOutstanding = customerRuns - customerPayments;

      if (customerOutstanding > 0) {
        peopleWithOutstanding.add(customerId);
      }
    }

    final outstanding = totalRuns - totalPayments;

    return {
      'outstanding': outstanding > 0 ? outstanding : 0.0,
      'people': peopleWithOutstanding.length,
      'usageRecords': usageRecords,
      'payments': paymentRecords,
    };
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final snapshot = await userDatabase
        .child('customers')
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'The database did not respond. Check the Realtime Database URL and rules.',
          ),
        );

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final customers = Map<String, dynamic>.from(snapshot.value as Map);

    final List<Map<String, dynamic>> transactions = [];

    for (final customerEntry in customers.entries) {
      final customerId = customerEntry.key;

      final customer = Map<String, dynamic>.from(customerEntry.value as Map);

      final customerName = customer['name']?.toString() ?? 'Unknown Customer';

      // -------------------------
      // RUNS
      // -------------------------
      final runsData = customer['runs'];

      if (runsData != null) {
        final runs = Map<String, dynamic>.from(runsData as Map);

        for (final runEntry in runs.entries) {
          final run = Map<String, dynamic>.from(runEntry.value as Map);

          final parsedDate = DateTime.tryParse(run['date']?.toString() ?? '');

          if (parsedDate == null) continue;

          final date = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );

          transactions.add({
            'id': runEntry.key,
            'customerId': customerId,
            'customerName': customerName,
            'type': 'run',
            'date': date,
            'startTime': DateTime.tryParse(run['startTime']?.toString() ?? ''),
            'endTime': DateTime.tryParse(run['endTime']?.toString() ?? ''),
            'amount': (run['totalAmount'] as num?)?.toDouble() ?? 0,
          });
        }
      }

      // -------------------------
      // PAYMENTS
      // -------------------------
      final paymentsData = customer['payments'];

      if (paymentsData != null) {
        final payments = Map<String, dynamic>.from(paymentsData as Map);

        for (final paymentEntry in payments.entries) {
          final payment = Map<String, dynamic>.from(paymentEntry.value as Map);

          final parsedDate = DateTime.tryParse(
            payment['date']?.toString() ?? '',
          );

          if (parsedDate == null) continue;

          final date = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );

          transactions.add({
            'id': paymentEntry.key,
            'customerId': customerId,
            'customerName': customerName,
            'type': 'payment',
            'date': date,
            'amount': (payment['amount'] as num?)?.toDouble() ?? 0,
            'note': payment['note']?.toString() ?? '',
          });
        }
      }
    }

    // Newest transactions first
    transactions.sort((a, b) {
      final aDate = a['date'] as DateTime;
      final bDate = b['date'] as DateTime;

      return bDate.compareTo(aDate);
    });

    return transactions;
  }
}
