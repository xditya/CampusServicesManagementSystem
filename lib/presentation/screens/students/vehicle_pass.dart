import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/widgets/student_info_card.dart';

class VehiclePassPage extends StatefulWidget {
  const VehiclePassPage({super.key});

  @override
  State<VehiclePassPage> createState() => _VehiclePassPageState();
}

class _VehiclePassPageState extends State<VehiclePassPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _hoursController = TextEditingController();
  final _timeFromController = TextEditingController();

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  String _rollNo = '';
  bool _isLoading = false;

  final List<String> _branches = ['EC', 'CS', 'EEE', 'ME', 'CE', 'EL'];
  final List<String> _classes = ['1', '2'];
  late List<String> _batches;

  @override
  void initState() {
    super.initState();

    final currentYear = DateTime.now().year;
    _batches = List.generate(4, (index) => (currentYear + index).toString());
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _hoursController.dispose();
    _timeFromController.dispose();
    super.dispose();
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = _timeFromController.text.isNotEmpty
        ? TimeOfDay.fromDateTime(
            DateFormat.jm().parse(_timeFromController.text))
        : TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _timeFromController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Pass Request'),
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
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicle Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Vehicle Number',
                            controller: _vehicleNumberController,
                            prefixIcon: Icons.directions_car,
                            helperText: 'Enter vehicle registration number',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Entry Time',
                            controller: _timeFromController,
                            prefixIcon: Icons.access_time,
                            readOnly: true,
                            onTap: () => _selectTime(context),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Hours Required',
                            controller: _hoursController,
                            prefixIcon: Icons.timer,
                            keyboardType: TextInputType.number,
                            helperText:
                                'Number of hours vehicle will be in campus',
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
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(prefixIcon),
        helperText: helperText,
      ),
      onTap: onTap,
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
        if (label == 'Vehicle Number' && value.trim().isEmpty) {
          return 'Please enter a valid vehicle number';
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
                'Submit Vehicle Pass Request',
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
        // TODO: Implement form submission
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle pass request submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting request: $e'),
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
