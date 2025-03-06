import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/widgets/student_info_card.dart';
import 'package:csms/helper/database/leave_form_db.dart' as leave_form_db;
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

class LeaveFormPage extends StatefulWidget {
  const LeaveFormPage({super.key});

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _branchController = TextEditingController();

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
  final _hods = Faculties().hods;
  final _principal = Faculties().principal;

  String _studentName = '';

  @override
  void initState() {
    super.initState();
    _dateFromController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _dateToController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _updateBranchController() {
    String branchName = _selectedBranch != null ? _hods[_selectedBranch]! : '';
    _branchController.text = branchName;
    _branchController.selection = TextSelection.fromPosition(
      TextPosition(offset: branchName.length),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime currentDate = controller.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(controller.text)
        : DateTime.now();

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = currentDate;

        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedDate),
                    child: const Text('Done'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: currentDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(currentDate.year + 1),
                  onDateChanged: (DateTime date) {
                    selectedDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Application'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: InkWell(
                onTap: () => _showMyLeaveForms(context),
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
                        'View My Leave Forms',
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
                    onBranchChanged: (value) {
                      setState(() {
                        _selectedBranch = value;
                        _updateBranchController();
                      });
                    },
                    onClassChanged: (value) =>
                        setState(() => _selectedClass = value),
                    onBatchChanged: (value) =>
                        setState(() => _selectedBatch = value),
                    onRollNumberChanged: (value) =>
                        setState(() => _rollNo = value),
                    onAdvisorChanged: (advisor) => _selectedAdvisor = advisor,
                    onFacultyChanged: (faculty) => _selectedFaculty = faculty,
                    onPrincipalChanged: (value) =>
                        setState(() => _includePrincipal = value),
                    onNameChanged: (name) =>
                        setState(() => _studentName = name),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Leave Details',
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
                              labelText: 'Reason for Leave',
                              hintText: 'Enter your reason for leave...',
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'From Date',
                                  controller: _dateFromController,
                                  prefixIcon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () =>
                                      _selectDate(context, _dateFromController),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  label: 'To Date',
                                  controller: _dateToController,
                                  prefixIcon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () =>
                                      _selectDate(context, _dateToController),
                                ),
                              ),
                            ],
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
                            'Head of Department',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _branchController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'HOD *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person_2),
                            ),
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

  // Helper methods from pink_slips.dart
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
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

  Widget _buildSearchableDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: value != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(null),
              )
            : null,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
      selectedItemBuilder: (context) {
        return items.map((item) {
          return SearchAnchor(
            builder: (context, controller) {
              return Text(value ?? '');
            },
            suggestionsBuilder: (context, controller) {
              final keyword = controller.text.toLowerCase();
              return items
                  .where((item) => item.toLowerCase().contains(keyword))
                  .map((item) => ListTile(
                        title: Text(item),
                        onTap: () {
                          onChanged(item);
                          controller.closeView(item);
                        },
                      ));
            },
          );
        }).toList();
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
                'Submit Leave Application',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedBranch == null ||
          _selectedClass == null ||
          _selectedBatch == null ||
          _selectedAdvisor == null ||
          _studentName.isEmpty) {
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
        final faculties = Faculties();
        final Set<String> approvalsRequired = {};

        // Add advisor email
        if (_selectedAdvisor != null) {
          final advisorEmail = faculties.allFacultyEmails[_selectedAdvisor];
          if (advisorEmail != null) approvalsRequired.add(advisorEmail);
        }

        // Add HOD email
        final hodEmail = faculties.allFacultyEmails[_hods[_selectedBranch]];
        if (hodEmail != null) approvalsRequired.add(hodEmail);

        // Add principal email if selected
        if (_includePrincipal) {
          final principalEmail =
              faculties.allFacultyEmails[faculties.principal];
          if (principalEmail != null) approvalsRequired.add(principalEmail);
        }

        final leaveForm = {
          'name': _studentName,
          'email': session.email,
          'branch': _selectedBranch,
          'class': _selectedClass,
          'batch': _selectedBatch,
          'rollNo': _rollNo,
          'reason': _reasonController.text,
          'dateFrom': _dateFromController.text,
          'dateTo': _dateToController.text,
          'status': 'pending',
          'approvalsRequired': approvalsRequired.toList(),
          'approvedBy': [],
          'rejectedBy': [],
          'createdAt': DateTime.now().toIso8601String(),
        };

        await leave_form_db.createLeaveForm(leaveForm);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leave form submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting form: $e'),
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

  Future<void> _showMyLeaveForms(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) =>
            MyLeaveFormsSheet(scrollController: controller),
      ),
    );
  }
}

extension on String {
  toInt() {
    return int.parse(this);
  }
}

class MyLeaveFormsSheet extends StatefulWidget {
  final ScrollController scrollController;

  const MyLeaveFormsSheet({super.key, required this.scrollController});

  @override
  State<MyLeaveFormsSheet> createState() => _MyLeaveFormsSheetState();
}

class _MyLeaveFormsSheetState extends State<MyLeaveFormsSheet> {
  List<Map<String, dynamic>> _forms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    try {
      final session = await account.get();
      final forms = await leave_form_db.getFormsByEmail(session.email);
      if (mounted) {
        setState(() {
          _forms = forms.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading forms: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('My Leave Forms'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadForms,
                  child: ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _forms.length,
                    itemBuilder: (context, index) {
                      final form = _forms[index];
                      final status = form['status'] as String;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: status == 'approved'
                                ? Colors.green
                                : status == 'rejected'
                                    ? Colors.red
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${form['dateFrom']} - ${form['dateTo']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: status == 'approved'
                                          ? Colors.green.withOpacity(0.1)
                                          : status == 'rejected'
                                              ? Colors.red.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: status == 'approved'
                                            ? Colors.green
                                            : status == 'rejected'
                                                ? Colors.red
                                                : Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                form['reason'],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              if (status == 'pending' &&
                                  form['approvalsRequired'] != null) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Waiting for approval from: ${(form['approvalsRequired'] as List).join(", ")}',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
