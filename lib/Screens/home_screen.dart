import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tube_well/Auth_Screens/signin_screen.dart';
import 'package:tube_well/Screens/profile_screen.dart';
import 'package:tube_well/Screens/transaction_screen.dart';
import 'package:tube_well/core/profile_avatar.dart';
import 'package:tube_well/Screens/add_customer_screen.dart';
import 'package:tube_well/Screens/customer_details.dart';
import 'package:tube_well/Services/database_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tube_well/Screens/customers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _PeopleTile extends StatelessWidget {
  final String customerId;
  final String name;
  final String amount;
  final String badge;
  final String searchQuery;
  final VoidCallback? onTapCustomer;

  const _PeopleTile({
    required this.customerId,
    required this.name,
    required this.amount,
    required this.badge,
    this.searchQuery = '',
    this.onTapCustomer,
  });

  Color _badgeColor() {
    switch (badge) {
      case 'Owed':
        return Colors.red;
      case 'Settled':
        return Colors.green;
      case 'Paid':
        return const Color(0xFF2E7D32);
      case 'Due':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF1976D2);
    }
  }

  Color _avatarColor() {
    final palette = <Color>[
      const Color(0xFF123B5D),
      const Color(0xFF4CAF50),
      const Color(0xFF9C27B0),
      const Color(0xFFEF6C00),
      const Color(0xFFE91E63),
      const Color(0xFF00ACC1),
      const Color(0xFF7E57C2),
      const Color(0xFF607D8B),
    ];

    if (name.trim().isEmpty) return palette.first;

    final index =
        name.toUpperCase().codeUnits.fold(0, (sum, value) => sum + value) %
        palette.length;

    return palette[index];
  }

  Widget _buildNameText() {
    final query = searchQuery.trim();

    if (query.isEmpty) {
      return Text(
        name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF123B5D),
        ),
      );
    }

    final normalizedName = name.toLowerCase();
    final normalizedQuery = query.toLowerCase();
    final matchIndex = normalizedName.indexOf(normalizedQuery);

    if (matchIndex == -1) {
      return Text(
        name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF123B5D),
        ),
      );
    }

    final before = name.substring(0, matchIndex);
    final match = name.substring(matchIndex, matchIndex + query.length);
    final after = name.substring(matchIndex + query.length);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: before,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123B5D),
            ),
          ),
          TextSpan(
            text: match,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123B5D),
              backgroundColor: Color.fromARGB(255, 255, 235, 118),
            ),
          ),
          TextSpan(
            text: after,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123B5D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor();
    final avatarColor = _avatarColor();

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        onTapCustomer?.call();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsScreen(
              customerId: customerId,
              customerName: name,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor,
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameText(),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF123B5D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, size: 22, color: Color(0xFF123B5D)),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: active ? const Color(0xFF123B5D) : const Color(0xFF7B8FA7),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF123B5D) : const Color(0xFF7B8FA7),
          ),
        ),
      ],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  Map<String, dynamic> _summary = {
    'outstanding': 0.0,
    'people': 0,
    'usageRecords': 0,
    'payments': 0,
  };

  bool _summaryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummaryForRange(selectedRange);
    _databaseService.userDatabase.child('customers').onValue.listen((_) {
      if (!mounted) return;
      _loadSummaryForRange(selectedRange);
    });
  }

  Future<void> _loadSummaryForRange(String range) async {
    setState(() {
      _summaryLoading = true;
    });

    try {
      final customers = await _databaseService.getCustomers();

      if (!mounted) return;

      final now = DateTime.now();

      bool matchesRange(DateTime date) {
        switch (range) {
          case 'Today':
            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          case 'Yesterday':
            final yesterday = now.subtract(const Duration(days: 1));
            return date.year == yesterday.year &&
                date.month == yesterday.month &&
                date.day == yesterday.day;
          case 'This Week':
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final weekStart = DateTime(
              startOfWeek.year,
              startOfWeek.month,
              startOfWeek.day,
            );
            final weekEnd = weekStart.add(const Duration(days: 7));
            return !date.isBefore(weekStart) && date.isBefore(weekEnd);
          case 'This Month':
            final monthStart = DateTime(now.year, now.month, 1);
            final monthEnd = DateTime(now.year, now.month + 1, 1);
            return !date.isBefore(monthStart) && date.isBefore(monthEnd);
          case 'All':
          default:
            return true;
        }
      }

      double totalRuns = 0;
      double totalPayments = 0;
      int usageRecords = 0;
      int paymentRecords = 0;
      final peopleWithOutstanding = <String>{};

      for (final customer in customers) {
        final runs = customer['runs'] is Map
            ? Map<String, dynamic>.from(customer['runs'] as Map)
            : <String, dynamic>{};

        final payments = customer['payments'] is Map
            ? Map<String, dynamic>.from(customer['payments'] as Map)
            : <String, dynamic>{};

        double customerRuns = 0;
        double customerPayments = 0;

        for (final runEntry in runs.entries) {
          final run = Map<String, dynamic>.from(runEntry.value as Map);
          final date = DateTime.tryParse(run['date']?.toString() ?? '');

          if (date == null || !matchesRange(date)) continue;

          final amount = (run['totalAmount'] as num?)?.toDouble() ?? 0;
          customerRuns += amount;
          totalRuns += amount;
          usageRecords++;
        }

        for (final paymentEntry in payments.entries) {
          final payment = Map<String, dynamic>.from(paymentEntry.value as Map);
          final date = DateTime.tryParse(payment['date']?.toString() ?? '');

          if (date == null || !matchesRange(date)) continue;

          final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
          customerPayments += amount;
          totalPayments += amount;
          paymentRecords++;
        }

        if (customerRuns - customerPayments > 0) {
          peopleWithOutstanding.add(customer['id']?.toString() ?? '');
        }
      }

      final outstanding = totalRuns - totalPayments;

      if (!mounted) return;

      setState(() {
        _summary = {
          'outstanding': outstanding > 0 ? outstanding : 0.0,
          'people': peopleWithOutstanding.length,
          'usageRecords': usageRecords,
          'payments': paymentRecords,
        };
        _summaryLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _summaryLoading = false;
      });

      if (context.mounted) {
        final message =
            error.toString().contains('The database did not respond')
            ? 'Database did not respond. Check the Realtime Database URL and rules.'
            : 'Unable to load data right now. Please check the Firebase database configuration.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  final TextEditingController _searchController = TextEditingController();
  bool _isSearchOpen = false;
  int _selectedTab = 0;
  String selectedRange = 'This Month';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // morning time section
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else if (hour < 21) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  // user name from database
  String getUserName() {
    final userName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    return userName != null && userName.isNotEmpty ? userName : 'User';
  }

  //moon and sun
  String getTimeEmoji() {
    final hour = DateTime.now().hour;

    if (hour < 18) {
      return '☀️';
    } else {
      return '🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = getGreeting();
    final userName = getUserName();
    final timeEmoji = getTimeEmoji();

    return PopScope(
      canPop: !_isSearchOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSearchOpen) {
          _searchController.clear();
          setState(() {
            _isSearchOpen = false;
            _selectedTab = 0;
          });
        }
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 201, 232, 247),
            appBar: _isSearchOpen
                ? AppBar(
                    backgroundColor: const Color(0xFF123B5D),
                    automaticallyImplyLeading: false,
                    titleSpacing: 8,
                    title: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _isSearchOpen = false;
                                _selectedTab = 0;
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (_) {
                                setState(() {});
                              },
                              onSubmitted: (_) {
                                setState(() {
                                  _isSearchOpen = false;
                                  _selectedTab = 0;
                                });
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search people or records',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 201, 232, 247),
                                  fontSize: 14,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : AppBar(
                    backgroundColor: const Color(0xFF123B5D),
                    iconTheme: const IconThemeData(
                      color: Color.fromARGB(255, 201, 232, 247),
                    ),
                    title: Row(
                      children: [
                        const Icon(
                          Icons.water_drop,
                          size: 30,
                          color: Color.fromARGB(255, 201, 232, 247),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tube Well',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Track • Manage • Settle',
                              style: TextStyle(
                                color: Color.fromARGB(255, 201, 232, 247),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color.fromARGB(255, 201, 232, 247),
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearchOpen = true;
                          });
                        },
                      ),
                    ],
                  ),

            drawer: Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(color: Color(0xFF123B5D)),
                      child: Row(
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: ProfileAvatarStore.selectedEmoji,
                            builder: (context, emoji, _) {
                              return CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.18,
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  FirebaseAuth.instance.currentUser?.displayName
                                              ?.trim()
                                              .isNotEmpty ==
                                          true
                                      ? FirebaseAuth
                                            .instance
                                            .currentUser!
                                            .displayName!
                                            .trim()
                                      : 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FirebaseAuth.instance.currentUser?.email ??
                                      'No email found',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 201, 232, 247),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Profile'),
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                        if (!mounted) return;
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Home'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to log out of your account?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout != true) return;

                        try {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const SigninScreen(),
                            ),
                            (route) => false,
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Unable to logout right now.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF123B5D)
                                .withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF123B5D)
                                  .withValues(alpha: 0.10),
                              blurRadius: 14,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF123B5D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF123B5D),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeEmoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Keep track of your tube-well usage and payments.',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF123B5D),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 150,
                              height: 100,
                              child: Opacity(
                                opacity: 0.94,
                                child: Image.asset(
                                  'assets/images/tubewell_illustration.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF123B5D),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF123B5D)
                                  .withValues(alpha: 0.24),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 23,
                              color: Color.fromARGB(255, 201, 232, 247),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        offset: const Offset(0, 30),
                                        tooltip: 'Select date range',
                                        onSelected: (value) {
                                          setState(() {
                                            selectedRange = value;
                                          });
                                          _loadSummaryForRange(value);
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'All',
                                            child: Text('All'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'This Month',
                                            child: Text('This Month'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'This Week',
                                            child: Text('This Week'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'Today',
                                            child: Text('Today'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'Yesterday',
                                            child: Text('Yesterday'),
                                          ),
                                        ],
                                        child: Row(
                                          children: [
                                            Text(
                                              selectedRange,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              size: 18,
                                              color: Color.fromARGB(
                                                255,
                                                201,
                                                232,
                                                247,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Total Outstanding',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _summaryLoading
                                            ? '...'
                                            : 'Rs ${(_summary['outstanding'] as num).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 1,
                                    height: 90,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                  const SizedBox(width: 18),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.group_outlined,
                                            size: 17,
                                            color: Color.fromARGB(
                                              255,
                                              201,
                                              232,
                                              247,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_summary['people']} ${(_summary['people'] as num) == 1 ? 'Person' : 'People'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.water_drop_outlined,
                                            size: 17,
                                            color: Color.fromARGB(
                                              255,
                                              201,
                                              232,
                                              247,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_summary['usageRecords']} ${(_summary['usageRecords'] as num) == 1 ? 'Usage Record' : 'Usage Records'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.payments_outlined,
                                            size: 17,
                                            color: Color.fromARGB(
                                              255,
                                              201,
                                              232,
                                              247,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_summary['payments']} ${(_summary['payments'] as num) == 1 ? 'Payment' : 'Payments'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'People',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF123B5D),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  _selectedTab = 0;
                                });
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CustomersScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                setState(() {
                                  _selectedTab = 0;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF123B5D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<DatabaseEvent>(
                        stream: DatabaseService().userDatabase
                            .child('customers')
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'Unable to load customers.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          final data = snapshot.data?.snapshot.value;

                          if (data == null) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: Text(
                                  'No customers added yet.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          final customers = Map<String, dynamic>.from(
                            data as Map,
                          );
                          final searchQuery = _searchController.text.trim();

                          final filteredCustomers = customers.entries.where((
                            entry,
                          ) {
                            final customer = Map<String, dynamic>.from(
                              entry.value as Map,
                            );
                            final name = customer['name']?.toString() ?? '';

                            if (searchQuery.isEmpty) return true;

                            return name.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            );
                          }).toList();

                          if (filteredCustomers.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: Text(
                                  'No matching customers found.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: filteredCustomers.map((entry) {
                              final customerId = entry.key;
                              final customer = Map<String, dynamic>.from(
                                entry.value as Map,
                              );
                              final name =
                                  customer['name']?.toString() ??
                                  'Unknown Customer';

                              double totalRuns = 0;
                              if (customer['runs'] != null) {
                                final runs = Map<String, dynamic>.from(
                                  customer['runs'] as Map,
                                );

                                for (final run in runs.values) {
                                  final runData = Map<String, dynamic>.from(
                                    run as Map,
                                  );

                                  totalRuns +=
                                      (runData['totalAmount'] as num?)
                                          ?.toDouble() ??
                                      0;
                                }
                              }

                              double totalPayments = 0;
                              if (customer['payments'] != null) {
                                final payments = Map<String, dynamic>.from(
                                  customer['payments'] as Map,
                                );

                                for (final payment in payments.values) {
                                  final paymentData = Map<String, dynamic>.from(
                                    payment as Map,
                                  );

                                  totalPayments +=
                                      (paymentData['amount'] as num?)
                                          ?.toDouble() ??
                                      0;
                                }
                              }

                              final owed = totalRuns - totalPayments;
                              final finalOwed = owed > 0 ? owed : 0;
                              final isOwed = finalOwed > 0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFF123B5D)
                                          .withValues(alpha: 0.08),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF123B5D)
                                            .withValues(alpha: 0.06),
                                        blurRadius: 12,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _PeopleTile(
                                    customerId: customerId,
                                    name: name,
                                    amount:
                                        'Rs. ${finalOwed.toStringAsFixed(0)}',
                                    badge: isOwed ? 'Owed' : 'Settled',
                                    searchQuery: searchQuery,
                                    onTapCustomer: () {
                                      _searchController.clear();
                                      setState(() {
                                        _isSearchOpen = false;
                                        _selectedTab = 0;
                                      });
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCustomerScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF123B5D),
              foregroundColor: const Color.fromARGB(255, 201, 232, 247),
              elevation: 8,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 30),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: _BottomNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      active: _selectedTab == 0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedTab = 1;
                      });
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionScreen(),
                        ),
                      );
                      if (!mounted) return;
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: _BottomNavItem(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Transactions',
                      active: _selectedTab == 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedTab = 2;
                      });
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomersScreen(),
                        ),
                      );
                      if (!mounted) return;
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: _BottomNavItem(
                      icon: Icons.people_rounded,
                      label: 'Customers',
                      active: _selectedTab == 2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedTab = 3;
                      });
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      if (!mounted) return;
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: _BottomNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      active: _selectedTab == 3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
