import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tube_well/Services/database_service.dart';

class AddRunScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const AddRunScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<AddRunScreen> createState() => _AddRunScreenState();
}

class _AddRunScreenState extends State<AddRunScreen> {
  final _formKey = GlobalKey<FormState>();

  double? _ratePerHour;
  bool _isLoadingRate = true;
  bool _isSaving = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 40);

  @override
  void initState() {
    super.initState();
    _loadCustomerRate();
  }

  Future<void> _loadCustomerRate() async {
    try {
      final customerData = await DatabaseService().getCustomer(
        widget.customerId,
      );

      final rateValue = customerData['ratePerHour'];

      final rate = rateValue is num
          ? rateValue.toDouble()
          : double.tryParse(rateValue.toString());

      if (!mounted) return;

      setState(() {
        _ratePerHour = rate;
        _isLoadingRate = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingRate = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load customer rate: $error')),
      );
    }
  }

  DateTime _asDateTime(TimeOfDay time) => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    time.hour,
    time.minute,
  );

  int get _durationMinutes {
    var minutes = _asDateTime(_endTime)
        .difference(_asDateTime(_startTime))
        .inMinutes;

    if (minutes <= 0) {
      minutes += 24 * 60;
    }

    return minutes;
  }

  double get _totalAmount {
    if (_ratePerHour == null) return 0;

    final hours = _durationMinutes / 60;

    return _ratePerHour! * hours;
  }

  String _formatTime(TimeOfDay time) => time.format(context);

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String _formatAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  String _formatRate(double rate) {
    return rate == rate.roundToDouble()
        ? rate.toStringAsFixed(0)
        : rate.toStringAsFixed(2);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (time == null) return;

    setState(() {
      if (isStart) {
        _startTime = time;
      } else {
        _endTime = time;
      }
    });
  }

  Future<void> _saveRun() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ratePerHour == null || _ratePerHour! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer hourly rate is not available.')),
      );
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to save a run.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await DatabaseService().addRun(
        customerId: widget.customerId,
        date: _selectedDate,
        startTime: _asDateTime(_startTime),
        endTime: _asDateTime(_endTime),
        durationMinutes: _durationMinutes,
        ratePerHour: _ratePerHour!,
        totalAmount: _totalAmount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Run saved successfully.')));

      Navigator.pop(context);
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to save run: ${error.message ?? error.code}'),
          ),
        );
      }
    } on TimeoutException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Database request timed out.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to save run: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(
        Icons.access_time_rounded,
        color: Color(0xFF123B5D),
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 245, 250, 253),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF123B5D), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _timeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF123B5D),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: _inputDecoration(
                hintText: '',
                icon: Icons.access_time_rounded,
              ),
              child: Text(
                _formatTime(time),
                style: const TextStyle(fontSize: 16, color: Color(0xFF123B5D)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rateCard() {
    const darkBlue = Color(0xFF123B5D);
    const lightBlue = Color.fromARGB(255, 201, 232, 247);

    if (_isLoadingRate) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightBlue.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Loading customer rate...',
              style: TextStyle(color: darkBlue, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_ratePerHour == null || _ratePerHour! <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Customer hourly rate could not be loaded.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: darkBlue),
          const SizedBox(width: 12),
          const Text(
            'Rate Per Hour',
            style: TextStyle(
              fontSize: 15,
              color: darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Rs. ${_formatRate(_ratePerHour!)} / h',
            style: const TextStyle(
              fontSize: 17,
              color: darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF123B5D);
    const lightBlue = Color.fromARGB(255, 201, 232, 247);

    final hours = _durationMinutes ~/ 60;
    final minutes = _durationMinutes % 60;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: lightBlue,
        elevation: 0,
        title: const Text(
          'Add Run',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Customer Run',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      hintText: '',
                      icon: Icons.calendar_month_outlined,
                    ),
                    child: Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(fontSize: 16, color: darkBlue),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    _timeField(
                      label: 'From',
                      time: _startTime,
                      onTap: () => _pickTime(isStart: true),
                    ),
                    const SizedBox(width: 12),
                    _timeField(
                      label: 'To',
                      time: _endTime,
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Calculation (Automatic)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 14),

                _summaryRow(
                  'Total Time',
                  '$hours H and $minutes m (${_durationMinutes}m)',
                ),

                const SizedBox(height: 18),

                _rateCard(),

                const SizedBox(height: 18),

                _summaryRow(
                  'Total Amount',
                  'Rs. ${_formatAmount(_totalAmount)}',
                  large: true,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving || _isLoadingRate ? null : _saveRun,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: lightBlue,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text(
                            'Save Run',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Color(0xFF123B5D)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF123B5D),
          ),
        ),
      ],
    );
  }
}
