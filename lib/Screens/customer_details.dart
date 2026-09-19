import 'package:flutter/material.dart';
import 'package:tube_well/Screens/add_run.dart';
import 'package:tube_well/Screens/add_payment.dart';
import 'package:tube_well/Services/database_service.dart';
import 'package:tube_well/Screens/add_customer_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerDetailsScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  Map<String, dynamic>? _customerData;
  List<Map<String, dynamic>> _runs = [];
  List<Map<String, dynamic>> _payments = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final customer = await DatabaseService().getCustomer(widget.customerId);

      final runs = await DatabaseService().getCustomerRuns(widget.customerId);

      final payments = await DatabaseService().getCustomerPayments(
        widget.customerId,
      );

      if (!mounted) return;

      setState(() {
        _customerData = customer;
        _runs = runs;
        _payments = payments;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load customer: $error')),
      );
    }
  }

  Future<void> _openUpdateCustomer() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customerId: widget.customerId),
      ),
    );

    if (updated == true) {
      await _loadCustomer();
    }
  }

  Future<void> _confirmDeleteCustomer() async {
    final name = _customerData?['name']?.toString() ?? widget.customerName;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text(
          'Delete $name and all of their runs and payments?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await DatabaseService().deleteCustomer(customerId: widget.customerId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted successfully.')),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete customer: $error')),
      );
    }
  }

  Future<void> _openAddRun() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRunScreen(
          customerId: widget.customerId,
          customerName:
              _customerData?['name']?.toString() ?? widget.customerName,
        ),
      ),
    );

    // Refresh Run History after returning.
    await _loadCustomer();
  }

  Future<void> _openAddPayment() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentScreen(
          customerId: widget.customerId,
          customerName:
              _customerData?['name']?.toString() ?? widget.customerName,
        ),
      ),
    );

    // Refresh customer data after returning.
    await _loadCustomer();
  }

  String _formatRate(dynamic value) {
    if (value == null) return 'Not set';

    final rate = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());

    if (rate == null) return 'Not set';

    return rate == rate.roundToDouble()
        ? 'Rs. ${rate.toStringAsFixed(0)} / hour'
        : 'Rs. ${rate.toStringAsFixed(2)} / hour';
  }

  String _formatAmount(dynamic value) {
    if (value == null) return 'Rs. 0';

    final amount = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());

    if (amount == null) return 'Rs. 0';

    return amount == amount.roundToDouble()
        ? 'Rs. ${amount.toStringAsFixed(0)}'
        : 'Rs. ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return 'Unknown date';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(dynamic value) {
    final time = DateTime.tryParse(value?.toString() ?? '');

    if (time == null) return '--';

    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDuration(dynamic value) {
    final minutes = value is num
        ? value.toInt()
        : int.tryParse(value.toString()) ?? 0;

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  String _getTotalRunTime() {
    int totalMinutes = 0;

    for (final run in _runs) {
      final minutes = run['durationMinutes'] is num
          ? (run['durationMinutes'] as num).toInt()
          : int.tryParse(run['durationMinutes']?.toString() ?? '0') ?? 0;

      totalMinutes += minutes;
    }

    return _formatDuration(totalMinutes);
  }

  double _getTotalCharges() {
    double total = 0;

    for (final run in _runs) {
      final amount = run['totalAmount'] is num
          ? (run['totalAmount'] as num).toDouble()
          : double.tryParse(run['totalAmount']?.toString() ?? '0') ?? 0;

      total += amount;
    }

    return total;
  }

  double _getTotalPaid() {
    double total = 0;

    for (final payment in _payments) {
      final amount = payment['amount'] is num
          ? (payment['amount'] as num).toDouble()
          : double.tryParse(payment['amount']?.toString() ?? '0') ?? 0;

      total += amount;
    }

    return total;
  }

  double _getRemainingBalance() {
    return _getTotalCharges() - _getTotalPaid();
  }

  Future<void> _deletePayment(Map<String, dynamic> payment) async {
    final paymentId = payment['id']?.toString();

    if (paymentId == null || paymentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete this payment.')),
      );
      return;
    }

    try {
      await DatabaseService().deletePayment(
        customerId: widget.customerId,
        paymentId: paymentId,
      );

      if (!mounted) return;

      await _loadCustomer();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete payment: $error')),
      );
    }
  }

  Future<void> _deleteRun(Map<String, dynamic> run) async {
    final runId = run['id']?.toString();

    if (runId == null || runId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete this run.')),
      );
      return;
    }

    try {
      await DatabaseService().deleteRun(
        customerId: widget.customerId,
        runId: runId,
      );

      if (!mounted) return;

      await _loadCustomer();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to delete run: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF123B5D);
    const lightBlue = Color.fromARGB(255, 201, 232, 247);

    final name = _customerData?['name']?.toString() ?? widget.customerName;

    final mobile = _customerData?['mobileNumber']?.toString() ?? 'Not provided';

    final note = _customerData?['note']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: lightBlue,
        elevation: 0,
        title: const Text(
          'Customer Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _openUpdateCustomer,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Update Customer',
          ),
          IconButton(
            onPressed: _isLoading ? null : _confirmDeleteCustomer,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Customer',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: lightBlue,
                          child: Text(
                            name.isNotEmpty
                                ? name.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: darkBlue,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: darkBlue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mobile,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 250, 253),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _infoRow(
                                  icon: Icons.timer_outlined,
                                  label: 'Total Run Time',
                                  value: _getTotalRunTime(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _infoRow(
                                  icon: Icons.payments_outlined,
                                  label: 'Rate Per Hour',
                                  value: _formatRate(
                                    _customerData?['ratePerHour'],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (note.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _infoRow(
                              icon: Icons.notes_outlined,
                              label: 'Note',
                              value: note,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openAddRun,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text(
                              'Add Run',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBlue,
                              foregroundColor: lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openAddPayment,
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text(
                              'Add Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightBlue,
                              foregroundColor: darkBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildAccountSummary(),

                    const SizedBox(height: 24),

                    const Text(
                      'Payment History',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _payments.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 245, 250, 253),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'No payments added yet.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            children: _payments
                                .map((payment) => _paymentCard(payment))
                                .toList(),
                          ),

                    const SizedBox(height: 24),

                    const Text(
                      'Run History',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _runs.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 245, 250, 253),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'No runs added yet.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            children: _runs
                                .map((run) => _runCard(run))
                                .toList(),
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _runCard(Map<String, dynamic> run) {
    const darkBlue = Color(0xFF123B5D);
    const lightBlue = Color.fromARGB(255, 201, 232, 247);
    const red = Color(0xFFE53935);

    return Dismissible(
      key: ValueKey(run['id'] ?? '${run['date']}-${run['totalAmount']}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_rounded, color: darkBlue, size: 24),
            SizedBox(width: 10),
            Text(
              'Edit',
              style: TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRunScreen(
                customerId: widget.customerId,
                customerName:
                    _customerData?['name']?.toString() ?? widget.customerName,
                run: run,
              ),
            ),
          );

          if (mounted) {
            await _loadCustomer();
          }

          return false;
        }

        if (direction == DismissDirection.endToStart) {
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete run?'),
              content: Text(
                'Remove this run on ${_formatDate(run['date'])} from ${widget.customerName}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (shouldDelete != true) {
            return false;
          }

          await _deleteRun(run);

          return true;
        }

        return false;
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 250, 253),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightBlue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: darkBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDate(run['date']),
                    style: const TextStyle(
                      color: darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatAmount(run['totalAmount']),
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _runInfo(
                    icon: Icons.play_arrow_rounded,
                    label: 'From',
                    value: _formatTime(run['startTime']),
                  ),
                ),
                Expanded(
                  child: _runInfo(
                    icon: Icons.stop_rounded,
                    label: 'To',
                    value: _formatTime(run['endTime']),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _runInfo(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _formatDuration(run['durationMinutes']),
                  ),
                ),
                Expanded(
                  child: _runInfo(
                    icon: Icons.payments_outlined,
                    label: 'Rate',
                    value: _formatRate(run['ratePerHour']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _runInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    const darkBlue = Color(0xFF123B5D);

    return Row(
      children: [
        Icon(icon, size: 18, color: darkBlue),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    const darkBlue = Color(0xFF123B5D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: darkBlue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSummary() {
    const darkBlue = Color(0xFF123B5D);
    const lightBlue = Color.fromARGB(255, 201, 232, 247);

    final totalCharges = _getTotalCharges();
    final totalPaid = _getTotalPaid();
    final remaining = _getRemainingBalance();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 250, 253),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Summary',
            style: TextStyle(
              color: darkBlue,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _balanceRow(
            label: 'Total Charges',
            value: _formatAmount(totalCharges),
          ),

          const SizedBox(height: 10),

          _balanceRow(
            label: 'Total Paid',
            value: '-${_formatAmount(totalPaid)}',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          _balanceRow(
            label: 'Remaining',
            value: _formatAmount(remaining),
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _balanceRow({
    required String label,
    required String value,
    bool bold = false,
  }) {
    const darkBlue = Color(0xFF123B5D);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: darkBlue,
            fontSize: bold ? 17 : 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _paymentCard(Map<String, dynamic> payment) {
    const darkBlue = Color(0xFF123B5D);
    const lightBlue = Color.fromARGB(255, 201, 232, 247);
    const red = Color(0xFFE53935);

    final amount = _formatAmount(payment['amount']);
    final date = _formatDate(payment['date']);
    final note = payment['note']?.toString() ?? '';

    return Dismissible(
      key: ValueKey(payment['id'] ?? '${payment['date']}-${payment['amount']}'),

      // Allow both directions.
      direction: DismissDirection.horizontal,

      // Swipe RIGHT → EDIT
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_rounded, color: darkBlue, size: 24),
            SizedBox(width: 10),
            Text(
              'Edit',
              style: TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),

      // Swipe LEFT → DELETE
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        // ==========================================
        // SWIPE RIGHT → OPEN EDIT PAYMENT
        // ==========================================
        if (direction == DismissDirection.startToEnd) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPaymentScreen(
                customerId: widget.customerId,
                customerName:
                    _customerData?['name']?.toString() ?? widget.customerName,
                payment: payment,
              ),
            ),
          );

          // Refresh payment history and balance.
          if (mounted) {
            await _loadCustomer();
          }

          // Do NOT remove the card.
          return false;
        }

        // ==========================================
        // SWIPE LEFT → DELETE PAYMENT
        // ==========================================
        if (direction == DismissDirection.endToStart) {
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete payment?'),
              content: Text(
                'Remove this payment of $amount from ${widget.customerName}?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (shouldDelete != true) {
            return false;
          }

          await _deletePayment(payment);

          return true;
        }

        return false;
      },

      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 250, 253),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightBlue),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.payments_outlined,
                color: darkBlue,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paid',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            Text(
              '-$amount',
              style: const TextStyle(
                color: darkBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
