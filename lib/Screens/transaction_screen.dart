import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Center(
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 201, 232, 247),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'Transactions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
