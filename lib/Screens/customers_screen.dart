import 'package:flutter/material.dart';
import 'package:tube_well/Screens/customer_details.dart';
import 'package:tube_well/Screens/home_screen.dart';
import 'package:tube_well/Screens/profile_screen.dart';
import 'package:tube_well/Screens/transaction_screen.dart';
import 'package:tube_well/Services/database_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _customers = [];

  String _selectedFilter = 'All';

  bool _isLoading = true;
  final int _selectedTab = 2;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _databaseService.getCustomers();

      if (!mounted) return;

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load customers: $e')));
    }
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    final searchText = _searchController.text.trim().toLowerCase();

    return _customers.where((customer) {
      final name = customer['name']?.toString().toLowerCase() ?? '';
      final owed = (customer['owed'] as num?)?.toDouble() ?? 0;

      final matchesSearch = name.contains(searchText);

      bool matchesFilter = true;

      if (_selectedFilter == 'Owed') {
        matchesFilter = owed > 0;
      } else if (_selectedFilter == 'Settled') {
        matchesFilter = owed <= 0;
      }

      return matchesSearch && matchesFilter;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 201, 232, 247),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Customers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search customers',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterButton('All'),
                const SizedBox(width: 8),
                _filterButton('Settled'),
                const SizedBox(width: 8),
                _filterButton('Owed'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Customer list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadCustomers,
                    child: _filteredCustomers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 150),
                              Center(
                                child: Text(
                                  'No customers found',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];

                              final customerId = customer['id'].toString();

                              final customerName =
                                  customer['name']?.toString() ?? 'Customer';

                              final owed =
                                  (customer['owed'] as num?)?.toDouble() ?? 0;

                              final isOwed = owed > 0;

                              final avatarColor = _avatarColor(customerName);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomerDetailsScreen(
                                              customerId: customerId,
                                              customerName: customerName,
                                            ),
                                      ),
                                    ).then((_) {
                                      _loadCustomers();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: avatarColor,
                                          child: Text(
                                            customerName.isNotEmpty
                                                ? customerName
                                                      .substring(0, 1)
                                                      .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customerName,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Rs. ${owed.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Text(
                                          isOwed ? 'Owed' : 'Settled',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isOwed
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),

                                        const SizedBox(width: 6),

                                        const Icon(
                                          Icons.chevron_right,
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
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

  Color _avatarColor(String name) {
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

  Widget _filterButton(String filter) {
    final isSelected = _selectedFilter == filter;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF123B5D)
              : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF123B5D),
          side: const BorderSide(color: Color(0xFF123B5D)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(filter),
      ),
    );
  }
}
