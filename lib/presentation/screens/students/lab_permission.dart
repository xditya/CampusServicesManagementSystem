import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:csms/helper/data/labs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/widgets/student_info_card.dart';
import 'package:csms/helper/database/db_service.dart';
import 'package:csms/helper/database/lab_permission_db.dart'
    as lab_permission_db;

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
  String? _selectedFaculty;
  bool? _selectedPrincipal;
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: InkWell(
                onTap: () => _showMyPermissions(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.science),
                      const SizedBox(width: 8),
                      Text(
                        'View My Lab Permissions',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudentInfoCard(
                onBranchChanged: (value) => {
                  setState(() => _selectedBranch = value),
                  _updateLabsList(),
                },
                onClassChanged: (value) =>
                    setState(() => _selectedClass = value),
                onBatchChanged: (value) =>
                    setState(() => _selectedBatch = value),
                onRollNumberChanged: (value) => setState(() => _rollNo = value),
                onAdvisorChanged: (value) =>
                    setState(() => _selectedAdvisor = value.toString()),
                onFacultyChanged: (value) =>
                    setState(() => _selectedFaculty = value.toString()),
                onPrincipalChanged: (value) =>
                    setState(() => _selectedPrincipal = value),
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
          _selectedLab == null ||
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
        final faculties = Faculties();
        final List<String> approvalsRequired = [];

        if (_selectedAdvisor != null) {
          final advisorEmail = faculties.allFacultyEmails[_selectedAdvisor];
          if (advisorEmail != null) approvalsRequired.add(advisorEmail);
        }

        if (_selectedFaculty != null) {
          final facultyEmail = faculties.allFacultyEmails[_selectedFaculty];
          if (facultyEmail != null) approvalsRequired.add(facultyEmail);
        }

        if (_selectedPrincipal == true) {
          final principalEmail =
              faculties.allFacultyEmails[faculties.principal];
          if (principalEmail != null) approvalsRequired.add(principalEmail);
        }

        final labPermission = {
          'name': session.name,
          'email': session.email,
          'branch': _selectedBranch,
          'class': _selectedClass,
          'batch': _selectedBatch,
          'rollNo': _rollNo,
          'lab': _selectedLab,
          'purpose': _purposeController.text,
          'date': _dateController.text,
          'timeFrom': _timeFromController.text,
          'timeTo': _timeToController.text,
          'status': 'pending',
          'approvalsRequired': approvalsRequired,
          'approvedBy': [],
          'rejectedBy': [],
          'createdAt': DateTime.now().toIso8601String(),
        };

        await lab_permission_db.createLabPermission(labPermission);

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

  Future<void> _showMyPermissions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) =>
            MyLabPermissionsSheet(scrollController: controller),
      ),
    );
  }
}

class MyLabPermissionsSheet extends StatefulWidget {
  final ScrollController scrollController;

  const MyLabPermissionsSheet({super.key, required this.scrollController});

  @override
  State<MyLabPermissionsSheet> createState() => _MyLabPermissionsSheetState();
}

class _MyLabPermissionsSheetState extends State<MyLabPermissionsSheet> {
  List<Map<String, dynamic>> _permissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      final session = await account.get();
      final permissions =
          await lab_permission_db.getLabPermissionsByEmail(session.email);
      permissions.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));

      setState(() {
        _permissions = permissions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          AppBar(
            title: const Text('My Lab Permissions'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadPermissions,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _permissions.length,
                      itemBuilder: (context, index) {
                        final permission = _permissions[index];
                        final status = permission['status'] as String;
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
                                        permission['date'],
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
                                                : Colors.orange
                                                    .withOpacity(0.1),
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
                                  'Lab: ${permission['lab']}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  permission['purpose'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${permission['timeFrom']} - ${permission['timeTo']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (status == 'rejected' &&
                                    permission['rejectedBy'] != null &&
                                    (permission['rejectedBy'] as List)
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rejected by: ${(permission['rejectedBy'] as List).first}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (status == 'pending' &&
                                    permission['approvalsRequired'] !=
                                        null) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Waiting for approval from: ${(permission['approvalsRequired'] as List).join(", ")}',
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
      ),
    );
  }
}
