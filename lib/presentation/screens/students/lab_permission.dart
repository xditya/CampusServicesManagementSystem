import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:csms/helper/data/labs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/widgets/student_info_card.dart';

class LabPermissionPage extends StatefulWidget {
  const LabPermissionPage({super.key});

  @override
  State<LabPermissionPage> createState() => _LabPermissionPageState();
}

class _LabPermissionPageState extends State<LabPermissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeFromController = TextEditingController();
  final _timeToController = TextEditingController();

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  String? _selectedLab;
  String _rollNo = '';
  bool _isLoading = false;

  late List<String> _labs = [];
  String? _selectedAdvisor;
  final _advisors = Faculties().advisors;
  final _departmentLabs = Labs().departmentLabs;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  void _updateLabsList() {
    if (_selectedBranch != null) {
      setState(() {
        _labs = _departmentLabs[_selectedBranch] ?? [];
        _selectedLab = null;
      });
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _dateController.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Permission Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudentInfoCard(
                onBranchChanged: (value) =>
                    setState(() => _selectedBranch = value),
                onClassChanged: (value) =>
                    setState(() => _selectedClass = value),
                onBatchChanged: (value) =>
                    setState(() => _selectedBatch = value),
                onRollNumberChanged: (value) => setState(() => _rollNo = value),
                onAdvisorChanged: (_) {},
                onFacultyChanged: (_) {},
                onPrincipalChanged: (_) {},
              ),
              const SizedBox(height: 16),
              // Lab Request Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lab Request Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Select Lab',
                        value: _selectedLab,
                        items: _labs,
                        prefixIcon: Icons.science,
                        onChanged: (value) {
                          setState(() => _selectedLab = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Purpose',
                        controller: _purposeController,
                        prefixIcon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Date',
                        controller: _dateController,
                        prefixIcon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'From Time',
                              controller: _timeFromController,
                              prefixIcon: Icons.access_time,
                              readOnly: true,
                              onTap: () =>
                                  _selectTime(context, _timeFromController),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'To Time',
                              controller: _timeToController,
                              prefixIcon: Icons.access_time,
                              readOnly: true,
                              onTap: () =>
                                  _selectTime(context, _timeToController),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Approvals Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Approvals Required',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Advisor *',
                        value: _selectedAdvisor,
                        items: _selectedBranch != null &&
                                _selectedBatch != null &&
                                _selectedClass != null
                            ? _advisors[_selectedBranch]![_selectedBatch!
                                .toInt()]![_selectedClass!.toInt()]!
                            : [],
                        prefixIcon: Icons.person,
                        onChanged: (value) {
                          setState(() => _selectedAdvisor = value);
                        },
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
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool readOnly = false,
    int? maxLines,
    VoidCallback? onTap,
  }) {
    final bool isRollNumberEnabled = label == 'Roll No.'
        ? (_selectedBatch != null && _selectedBranch != null)
        : true;

    return TextFormField(
      controller: controller,
      readOnly: readOnly || (label == 'Roll No.' && !isRollNumberEnabled),
      maxLines: maxLines ?? 1,
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
            : null,
      ),
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
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
                'Submit Lab Permission Request',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedBranch == null ||
          _selectedClass == null ||
          _selectedBatch == null ||
          _selectedLab == null) {
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
              content: Text('Lab permission request submitted successfully'),
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

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay initialTime = controller.text.isNotEmpty
        ? TimeOfDay.fromDateTime(DateFormat.jm().parse(controller.text))
        : TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }
}

extension on String {
  toInt() {
    return int.parse(this);
  }
}
