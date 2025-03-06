import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/widgets/student_info_card.dart';
import 'package:csms/helper/database/gate_pass_db.dart' as gate_pass_db;
import 'my_passes.dart';

class GatePassPage extends StatefulWidget {
  const GatePassPage({super.key});

  @override
  State<GatePassPage> createState() => _GatePassPageState();
}

class _GatePassPageState extends State<GatePassPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _reasonController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeFromController = TextEditingController();
  final _timeToController = TextEditingController();

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  String _rollNo = '';
  bool _isLoading = false;

  String? _selectedAdvisor;
  String? _selectedFaculty;
  bool _includePrincipal = false;

  final _advisors = Faculties().advisors;
  final _allFaculty = Faculties().allFaculty;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _reasonController.dispose();
    _dateController.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Pass Request'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: InkWell(
                onTap: () => _showMyPasses(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long),
                      const SizedBox(width: 8),
                      Text(
                        'View My Passes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
                    onBranchChanged: (value) =>
                        setState(() => _selectedBranch = value),
                    onClassChanged: (value) =>
                        setState(() => _selectedClass = value),
                    onBatchChanged: (value) =>
                        setState(() => _selectedBatch = value),
                    onRollNumberChanged: (value) =>
                        setState(() => _rollNo = value),
                    onAdvisorChanged: (value) =>
                        setState(() => _selectedAdvisor = value),
                    onFacultyChanged: (value) =>
                        setState(() => _selectedFaculty = value),
                    onPrincipalChanged: (value) =>
                        setState(() => _includePrincipal = value),
                    onNameChanged: (name) =>
                        setState(() => _studentNameController.text = name),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gate Pass Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _reasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Reason for Gate Pass',
                              hintText: 'Enter your reason...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.description),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your reason';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Date',
                            controller: _dateController,
                            prefixIcon: Icons.calendar_today,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _timeFromController,
                                  decoration: const InputDecoration(
                                    labelText: 'From Time',
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true,
                                  onTap: () => _selectTime(context, true),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _timeToController,
                                  decoration: const InputDecoration(
                                    labelText: 'To Time',
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true,
                                  onTap: () => _selectTime(context, false),
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
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(prefixIcon),
      ),
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
                'Submit Gate Pass Request',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  String formatDateForStorage(String dateStr) {
    // First try to parse as dd/MM/yyyy
    try {
      final dateParts = dateStr.split('/');
      if (dateParts.length == 3) {
        return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
      }
    } catch (_) {
      // If splitting fails, continue to next attempt
    }

    // Then try to parse as existing yyyy-MM-dd
    try {
      DateTime.parse(
          dateStr); // If this succeeds, it's already in correct format
      return dateStr;
    } catch (_) {
      // If both attempts fail, return current date in correct format
      return DateTime.now().toIso8601String().split('T')[0];
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedBranch == null ||
          _selectedClass == null ||
          _selectedBatch == null ||
          _selectedAdvisor == null) {
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
        if (session == null) {
          throw Exception('Session not found');
        }

        final formattedDate = formatDateForStorage(_dateController.text);

        final faculties = Faculties();
        final Set<String> approvalsRequired = {};

        // Add advisor email
        final advisorEmail = faculties.allFacultyEmails[_selectedAdvisor];
        if (advisorEmail == null) {
          throw Exception('Advisor email not found');
        }
        approvalsRequired.add(advisorEmail);

        // Add selected faculty email if any
        if (_selectedFaculty != null) {
          final facultyEmail = faculties.allFacultyEmails[_selectedFaculty];
          if (facultyEmail != null) {
            approvalsRequired.add(facultyEmail);
          }
        }

        // Add HOD email
        final hodName = faculties.hods[_selectedBranch];
        if (hodName == null) {
          throw Exception('HOD not found for branch');
        }
        final hodEmail = faculties.allFacultyEmails[hodName];
        if (hodEmail == null) {
          throw Exception('HOD email not found');
        }
        approvalsRequired.add(hodEmail);

        // Add principal email if selected
        if (_includePrincipal) {
          final principalEmail =
              faculties.allFacultyEmails[faculties.principal];
          if (principalEmail != null) {
            approvalsRequired.add(principalEmail);
          }
        }

        // Create gate pass request with unique approvals
        final passData = {
          'email': session.email,
          'name': _studentNameController.text,
          'rollNo': _rollNo,
          'branch': _selectedBranch,
          'class': _selectedClass,
          'batch': _selectedBatch,
          'reason': _reasonController.text,
          'date': formattedDate,
          'timeFrom': _timeFromController.text,
          'timeTo': _timeToController.text,
          'advisor': _selectedAdvisor,
          'faculty': _selectedFaculty,
          'includePrincipal': _includePrincipal,
          'approvalsRequired': approvalsRequired.toList(),
          'approvedBy': [],
          'rejectedBy': [],
          'status': 'pending',
          'requestDate': DateTime.now().toIso8601String(),
        };

        await gate_pass_db.createGatePass(passData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gate pass request submitted successfully'),
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

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isFromTime) {
          _timeFromController.text = picked.format(context);
        } else {
          _timeToController.text = picked.format(context);
        }
      });
    }
  }

  Future<void> _showMyPasses(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MyPassesSheet(),
      isScrollControlled: true,
      useSafeArea: true,
    );
  }
}

extension on String {
  toInt() {
    return int.parse(this);
  }
}
