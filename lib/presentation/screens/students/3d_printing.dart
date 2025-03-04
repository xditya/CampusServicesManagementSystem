import 'package:csms/helper/config.dart';
import 'package:flutter/material.dart';
import 'package:csms/helper/database/balance_db.dart' as balance_db;
import 'package:csms/presentation/widgets/student_info_card.dart';

class ThreeDPrintingPage extends StatefulWidget {
  const ThreeDPrintingPage({super.key});

  @override
  State<ThreeDPrintingPage> createState() => _ThreeDPrintingPageState();
}

class _ThreeDPrintingPageState extends State<ThreeDPrintingPage> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  String _rollNo = '';
  bool _isLoading = false;
  double _totalAmount = 0;
  final double _ratePerHour = 30.0;

  @override
  void initState() {
    super.initState();
    _hoursController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    setState(() {
      if (_hoursController.text.isNotEmpty) {
        try {
          final hours = double.parse(_hoursController.text);
          _totalAmount = hours * _ratePerHour;
        } catch (e) {
          _totalAmount = 0;
        }
      } else {
        _totalAmount = 0;
      }
    });
  }

  void _updateRollNumberPrefix() {
    if (_selectedBatch != null && _selectedBranch != null) {
      final year = int.parse(_selectedBatch!) - 4;
      final yearPrefix = year.toString().substring(year.toString().length - 2);
      final rollPrefix = 'B$yearPrefix${_selectedBranch!}';
      final currentText = _rollNo;
      final suffixText = currentText.length > rollPrefix.length
          ? currentText.substring(rollPrefix.length)
          : '';
      _rollNo = rollPrefix + suffixText;
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Printing Request'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StudentInfoCard(
                    onBranchChanged: (value) {
                      setState(() => _selectedBranch = value);
                    },
                    onClassChanged: (value) {
                      setState(() => _selectedClass = value);
                    },
                    onBatchChanged: (value) {
                      setState(() => _selectedBatch = value);
                    },
                    onRollNumberChanged: (value) {
                      setState(() => _rollNo = value);
                    },
                    onAdvisorChanged: (_) {},
                    onFacultyChanged: (_) {},
                    onPrincipalChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Printing Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Hours Required',
                            controller: _hoursController,
                            prefixIcon: Icons.timer,
                            keyboardType: TextInputType.number,
                            helperText: 'Rate: ₹$_ratePerHour per hour',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${_totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(prefixIcon),
        helperText: helperText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Hours Required') {
          try {
            final hours = double.parse(value);
            if (hours <= 0) {
              return 'Hours must be greater than 0';
            }
          } catch (e) {
            return 'Please enter a valid number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Confirm and Pay',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedBranch == null ||
          _selectedClass == null ||
          _selectedBatch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final session = await account.get();
        final currentBalance = await balance_db.getBalance(session.email);

        if (currentBalance < _totalAmount) {
          throw Exception('Insufficient balance in wallet');
        }

        // Deduct amount from wallet using balance_db
        await balance_db.updateBalance(
          session.email,
          -_totalAmount, // Negative amount for deduction
          '3D Printing',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('3D Printing request confirmed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}

extension on String {
  toInt() {
    return int.parse(this);
  }
}
