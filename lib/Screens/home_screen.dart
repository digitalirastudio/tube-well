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

  const _PeopleTile({
    required this.customerId,
    required this.name,
    required this.amount,
    required this.badge,
  });

  Color _badgeColor() {
    switch (badge) {
      case 'Paid':
        return const Color(0xFF2E7D32);
      case 'Due':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF1976D2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor();

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
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
              backgroundColor: const Color(0xFF123B5D).withValues(alpha: 0.12),
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF123B5D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF123B5D),
                    ),
                  ),
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
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Color(0xFF123B5D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Last activity • Today',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF123B5D).withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 201, 232, 247),
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
                        setState(() {
                          _isSearchOpen = false;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
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
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                  ],
                ),
              ),
            )
          : AppBar(
              backgroundColor: Color(0xFF123B5D),
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 201, 232, 247),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 30,
                    color: Color.fromARGB(255, 201, 232, 247),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tube Well',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track . Manage . Settle',
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
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
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
                leading: const Icon(Icons.logout, color: Colors.redAccent),
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
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
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
                      color: const Color(0xFF123B5D).withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF123B5D).withValues(alpha: 0.10),
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
                            //geerting text
                            Text(
                              greeting,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF123B5D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
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
                            //user below text
                            Text(
                              'Keep track of your tube-well usage and payments.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF123B5D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 250,
                        height: 150,
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
                SizedBox(height: 24),
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
                        color: const Color(0xFF123B5D).withValues(alpha: 0.24),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 30,
                        color: Color.fromARGB(255, 201, 232, 247),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PopupMenuButton<String>(
                                  color: Colors.white,
                                  offset: const Offset(0, 30),
                                  tooltip: 'Select date range',
                                  onSelected: (value) {
                                    setState(() {
                                      selectedRange = value;
                                    });
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
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Rs 24000',
                                  style: TextStyle(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.group_outlined,
                                      size: 17,
                                      color: Color.fromARGB(255, 201, 232, 247),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '6 People',
                                      style: TextStyle(
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
                                      color: Color.fromARGB(255, 201, 232, 247),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '12 Usage Records',
                                      style: TextStyle(
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
                                      color: Color.fromARGB(255, 201, 232, 247),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '3 Payments',
                                      style: TextStyle(
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
                        onPressed: () {
                          // Customer list is now shown below.
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                            style: TextStyle(color: Colors.grey, fontSize: 14),
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
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      );
                    }

                    final customers = Map<String, dynamic>.from(data as Map);

                    return Column(
                      children: customers.entries.map((entry) {
                        final customerId = entry.key;
                        final customer = Map<String, dynamic>.from(
                          entry.value as Map,
                        );

                        final name =
                            customer['name']?.toString() ?? 'Unknown Customer';

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
                              amount: 'Rs 0',
                              badge: 'Active',
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
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
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
              onTap: () {
                setState(() {
                  _selectedTab = 2;
                });
              },
              child: _BottomNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
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
  }
}
