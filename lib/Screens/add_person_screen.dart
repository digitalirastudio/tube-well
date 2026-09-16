import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PersonEntry {
  final String category;
  final String name;
  final String mobileNumber;
  final String date;
  final String startTime;
  final String endTime;
  final String amount;
  final String note;

  const PersonEntry({
    required this.category,
    required this.name,
    required this.mobileNumber,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'name': name,
      'mobileNumber': mobileNumber,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'amount': amount,
      'note': note,
    };
  }

  factory PersonEntry.fromMap(Map<dynamic, dynamic> map) {
    return PersonEntry(
      category: map['category']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      mobileNumber: map['mobileNumber']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      startTime: map['startTime']?.toString() ?? '',
      endTime: map['endTime']?.toString() ?? '',
      amount: map['amount']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
    );
  }
}

class PersonEntryStore {
  static final List<PersonEntry> entries = [];

  static void add(PersonEntry entry) {
    entries.insert(0, entry);
  }
}

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = 'Water Supply';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 20);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 15);

  final List<String> _categories = [
    'Water Supply',
    'Tube Well',
    'Maintenance',
    'Service',
    'Other',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 232, 247),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Person',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF123B5D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF123B5D).withValues(alpha: 0.12),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCategory,
                      items: _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildFieldLabel('Add Person Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter person name',
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 18),
                _buildFieldLabel('Mobile Number'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _mobileController,
                  hintText: 'Enter mobile number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),
                _buildFieldLabel('Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: _buildSelector(
                    text: _formatDate(_selectedDate),
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Start Time'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _pickTime(isStart: true),
                            child: _buildSelector(
                              text: _formatTime(_startTime),
                              icon: Icons.access_time_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('End Time'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _pickTime(isStart: false),
                            child: _buildSelector(
                              text: _formatTime(_endTime),
                              icon: Icons.access_time_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildFieldLabel('Rs'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _amountController,
                  hintText: 'Enter amount',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixText: 'Rs ',
                ),
                const SizedBox(height: 18),
                _buildFieldLabel('Optional Note'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add notes if needed',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: const Color(0xFF123B5D).withValues(alpha: 0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: const Color(0xFF123B5D).withValues(alpha: 0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF123B5D),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You must be signed in to save data.',
                              ),
                            ),
                          );
                          return;
                        }

                        final entry = PersonEntry(
                          category: _selectedCategory,
                          name: _nameController.text.trim(),
                          mobileNumber: _mobileController.text.trim(),
                          date: _formatDate(_selectedDate),
                          startTime: _formatTime(_startTime),
                          endTime: _formatTime(_endTime),
                          amount: _amountController.text.trim(),
                          note: _noteController.text.trim(),
                        );

                        PersonEntryStore.add(entry);

                        try {
                          await FirebaseDatabase.instance
                              .ref('transactions/${user.uid}')
                              .push()
                              .set(entry.toMap());

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Person saved successfully.'),
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Unable to save: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF123B5D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save',
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

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF123B5D),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please fill this field';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF123B5D).withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF123B5D).withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF123B5D), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSelector({required String text, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF123B5D).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF123B5D)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF123B5D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF123B5D)),
        ],
      ),
    );
  }
}
