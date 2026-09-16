import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tube_well/Screens/add_person_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<PersonEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _entries = [];
        _isLoading = false;
      });
      return;
    }

    final ref = FirebaseDatabase.instance.ref('transactions/${user.uid}');
    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      final loadedEntries = <PersonEntry>[];

      if (data is Map) {
        for (final item in data.values) {
          if (item is Map) {
            loadedEntries.add(
              PersonEntry.fromMap(Map<String, dynamic>.from(item)),
            );
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _entries = loadedEntries;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 232, 247),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF123B5D)),
            )
          : _entries.isEmpty
          ? const Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(
                  color: Color(0xFF123B5D),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF123B5D).withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF123B5D).withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF123B5D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs ${entry.amount}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF123B5D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123B5D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_android,
                            size: 15,
                            color: Color(0xFF123B5D),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.mobileNumber,
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF123B5D)
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 15,
                            color: Color(0xFF123B5D),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${entry.date}   •   ${entry.startTime} - ${entry.endTime}',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF123B5D)
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      if (entry.note.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          entry.note,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF123B5D)
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
