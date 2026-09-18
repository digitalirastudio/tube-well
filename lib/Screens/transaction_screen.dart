import 'package:flutter/material.dart';
import 'package:tube_well/Screens/customers_screen.dart';
import 'package:tube_well/Screens/home_screen.dart';
import 'package:tube_well/Screens/profile_screen.dart';
import 'package:tube_well/Services/database_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final DatabaseService _databaseService = DatabaseService();

  String _selectedFilter = 'All';

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];
  final int _selectedTab = 1;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _databaseService.getAllTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load transactions.';
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') {
      return _transactions;
    }

    if (_selectedFilter == 'Runs') {
      return _transactions
          .where((transaction) => transaction['type'] == 'run')
          .toList();
    }

    return _transactions
        .where((transaction) => transaction['type'] == 'payment')
        .toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final hour = time.hour;
    final minute = time.minute;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatRunTime(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) {
      return '';
    }

    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  void _navigateToTab(int index) {
    if (index == _selectedTab) return;

    final screens = [
      const HomeScreen(),
      const TransactionScreen(),
      const CustomersScreen(),
      const ProfileScreen(),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screens[index]),
    );
  }

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: active ? const Color(0xFF123B5D) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF123B5D) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label) {
    final selected = _selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF123B5D) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF123B5D),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> transaction) {
    final isRun = transaction['type'] == 'run';

    final customerName =
        transaction['customerName']?.toString() ?? 'Unknown Customer';

    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;

    final date = transaction['date'] as DateTime;

    final subtitle = isRun
        ? _formatRunTime(
            transaction['startTime'] as DateTime?,
            transaction['endTime'] as DateTime?,
          )
        : _formatTime(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF123B5D).withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isRun
                ? const Color(0xFF123B5D)
                : const Color(0xFF2E7D32),
            child: Icon(
              isRun ? Icons.water_drop_outlined : Icons.payments_outlined,
              size: 19,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRun ? 'Run' : 'Payment',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123B5D),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$customerName • $subtitle',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isRun ? '+' : '-'}Rs. ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isRun ? const Color(0xFF2E7D32) : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    final transactions = List<Map<String, dynamic>>.from(_filteredTransactions);

    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'No transactions found.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    // Sort ALL transactions by actual date/time: newest first.
    transactions.sort((a, b) {
      final aDate = a['date'] as DateTime;
      final bDate = b['date'] as DateTime;

      return bDate.compareTo(aDate);
    });

    // Group by actual calendar date.
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final transaction in transactions) {
      final date = transaction['date'] as DateTime;

      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    // Sort date groups: newest date first.
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDates.map((dateKey) {
        final date = DateTime.parse(dateKey);
        final dayTransactions = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B5D),
                ),
              ),
            ),

            ...dayTransactions.map(_transactionTile),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 232, 247),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 201, 232, 247),
        ),
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTransactions,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      _filterButton('All'),
                      _filterButton('Runs'),
                      _filterButton('Payments'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                else if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  _buildTransactions(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _navigateToTab(0),
              child: _bottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: _selectedTab == 0,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToTab(1),
              child: _bottomNavItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Transactions',
                active: _selectedTab == 1,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToTab(2),
              child: _bottomNavItem(
                icon: Icons.people_rounded,
                label: 'Customers',
                active: _selectedTab == 2,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToTab(3),
              child: _bottomNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: _selectedTab == 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
