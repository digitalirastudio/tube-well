import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tube_well/Services/database_service.dart';

class AddCustomerScreen extends StatefulWidget {
  final String? customerId;

  const AddCustomerScreen({super.key, this.customerId});

  bool get isEditing => customerId != null;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customer = await DatabaseService().getCustomer(widget.customerId!);

      if (!mounted) return;

      _nameController.text = customer['name']?.toString() ?? '';
      _mobileController.text = customer['mobileNumber']?.toString() ?? '';
      _rateController.text = customer['ratePerHour']?.toString() ?? '';
      _noteController.text = customer['note']?.toString() ?? '';
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load customer: ${e.message ?? e.code}'),
        ),
      );
    } on TimeoutException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Database request timed out.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load customer.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must be signed in.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final rate = double.parse(_rateController.text.trim());

      if (widget.isEditing) {
        await DatabaseService().updateCustomer(
          customerId: widget.customerId!,
          name: _nameController.text,
          mobileNumber: _mobileController.text,
          ratePerHour: rate,
          note: _noteController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated successfully.')),
        );
      } else {
        await DatabaseService().addCustomer(
          name: _nameController.text,
          mobileNumber: _mobileController.text,
          ratePerHour: rate,
          note: _noteController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully.')),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save customer: ${e.message ?? e.code}'),
        ),
      );
    } on TimeoutException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Database request timed out.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Unable to update customer.'
                : 'Unable to save customer.',
          ),
        ),
      );
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
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: Icon(icon, color: const Color(0xFF123B5D)),
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

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _rateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF123B5D);
    const lightBlue = Color.fromARGB(255, 201, 232, 247);

    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: lightBlue,
        elevation: 0,
        title: Text(
          isEditing ? 'Update Customer' : 'Add Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEditing
                                ? Icons.edit_rounded
                                : Icons.person_add_rounded,
                            size: 40,
                            color: darkBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          isEditing ? 'Edit Customer' : 'New Customer',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Center(
                        child: Text(
                          isEditing
                              ? 'Update customer account details'
                              : 'Add customer account details',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Customer Name',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: darkBlue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          hintText: 'Enter Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Enter Number',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: darkBlue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          hintText: '03XX XXXXXXX',
                          icon: Icons.phone_outlined,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Rate Per Hour',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: darkBlue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          hintText: '1000',
                          icon: Icons.payments_outlined,
                          prefixText: 'Rs. ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter hourly rate';
                          }

                          final rate = double.tryParse(value.trim());

                          if (rate == null || rate <= 0) {
                            return 'Enter a valid rate';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Note (Optional)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: darkBlue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          hintText: 'Add a note...',
                          icon: Icons.notes_outlined,
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveCustomer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            foregroundColor: lightBlue,
                            disabledBackgroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  isEditing
                                      ? 'Update Customer'
                                      : 'Save Customer',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
