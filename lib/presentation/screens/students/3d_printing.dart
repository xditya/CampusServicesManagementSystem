import 'package:csms/helper/config.dart';
import 'package:flutter/material.dart';
import 'package:csms/helper/database/balance_db.dart' as balance_db;
import 'package:csms/helper/data/faculties.dart';

class ThreeDPrintingPage extends StatefulWidget {
  const ThreeDPrintingPage({super.key});

  @override
  State<ThreeDPrintingPage> createState() => _ThreeDPrintingPageState();
}

class _ThreeDPrintingPageState extends State<ThreeDPrintingPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _hoursController = TextEditingController();

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  bool _isLoading = false;
  double _totalAmount = 0;

  final List<String> _branches = ['EC', 'CS', 'EEE', 'ME', 'CE', 'EL'];
  final double _ratePerHour = 30.0;
  final List<String> _classes = ['1', '2'];
  late List<String> _batches;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _hoursController.addListener(_calculateTotal);

    final currentYear = DateTime.now().year;
    _batches = List.generate(4, (index) => (currentYear + index).toString());
  }

  Future<void> _loadUserName() async {
    final session = await account.get();
    setState(() {
      _studentNameController.text = session.name;
    });
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
      final currentText = _rollNoController.text;
      final suffixText = currentText.length > rollPrefix.length
          ? currentText.substring(rollPrefix.length)
          : '';
      _rollNoController.text = rollPrefix + suffixText;
      _rollNoController.selection = TextSelection.fromPosition(
        TextPosition(offset: _rollNoController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _rollNoController.dispose();
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Student Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Student Name',
                            controller: _studentNameController,
                            prefixIcon: Icons.person,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Branch',
                            value: _selectedBranch,
                            items: _branches,
                            prefixIcon: Icons.category,
                            onChanged: (value) {
                              setState(() {
                                _selectedBranch = value;
                                _updateRollNumberPrefix();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Class',
                            value: _selectedClass,
                            items: _classes,
                            prefixIcon: Icons.class_,
                            onChanged: (value) {
                              setState(() {
                                _selectedClass = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Batch',
                            value: _selectedBatch,
                            items: _batches,
                            prefixIcon: Icons.calendar_view_month,
                            onChanged: (value) {
                              setState(() {
                                _selectedBatch = value;
                                _updateRollNumberPrefix();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Roll No.',
                            controller: _rollNoController,
                            prefixIcon: Icons.numbers,
                            readOnly: false,
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
    bool readOnly = false,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    final bool isRollNumberEnabled = label == 'Roll No.'
        ? (_selectedBatch != null && _selectedBranch != null)
        : true;

    return TextFormField(
      controller: controller,
      readOnly: readOnly || (label == 'Roll No.' && !isRollNumberEnabled),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(prefixIcon),
        helperText: label == 'Roll No.'
            ? isRollNumberEnabled
                ? 'Auto-filled prefix must be preserved'
                : 'Select batch and branch first'
            : helperText,
      ),
      onTap: () {
        if (label == 'Roll No.' && !isRollNumberEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select batch and branch first'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Roll No.' &&
            _selectedBatch != null &&
            _selectedBranch != null) {
          final year = int.parse(_selectedBatch!) - 4;
          final yearPrefix =
              year.toString().substring(year.toString().length - 2);
          final expectedPrefix = 'B$yearPrefix${_selectedBranch!}';
          if (!value.startsWith(expectedPrefix)) {
            return 'Roll number must start with $expectedPrefix';
          }
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData prefixIcon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(prefixIcon),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
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
