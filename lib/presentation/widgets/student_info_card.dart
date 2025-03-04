import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';

class StudentInfoCard extends StatefulWidget {
  final void Function(String?) onBranchChanged;
  final void Function(String?) onClassChanged;
  final void Function(String?) onBatchChanged;
  final void Function(String) onRollNumberChanged;
  final void Function(String?) onAdvisorChanged;
  final void Function(String?) onFacultyChanged;
  final void Function(bool) onPrincipalChanged;

  const StudentInfoCard({
    super.key,
    required this.onBranchChanged,
    required this.onClassChanged,
    required this.onBatchChanged,
    required this.onRollNumberChanged,
    required this.onAdvisorChanged,
    required this.onFacultyChanged,
    required this.onPrincipalChanged,
  });

  @override
  State<StudentInfoCard> createState() => _StudentInfoCardState();
}

class _StudentInfoCardState extends State<StudentInfoCard> {
  final _studentNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollNoController = TextEditingController();

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  String? _selectedAdvisor;
  String? _selectedFaculty;
  bool _includePrincipal = false;

  final List<String> _branches = ['EC', 'CS', 'EEE', 'ME', 'CE', 'EL', 'ADMIN'];
  final List<String> _classes = ['1', '2'];
  late List<String> _batches;

  final _faculties = Faculties();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    final currentYear = DateTime.now().year;
    _batches = List.generate(4, (index) => (currentYear + index).toString());
  }

  Future<void> _loadUserName() async {
    final session = await account.get();
    if (mounted) {
      setState(() {
        _studentNameController.text = session.name;
        _emailController.text = session.email;
      });
    }
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _emailController.dispose();
    _rollNoController.dispose();
    super.dispose();
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
      widget.onRollNumberChanged(_rollNoController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
              readOnly: _studentNameController.text.isNotEmpty,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email,
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
                widget.onBranchChanged(value);
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
                widget.onClassChanged(value);
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
                widget.onBatchChanged(value);
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Roll No.',
              controller: _rollNoController,
              prefixIcon: Icons.numbers,
              readOnly: false,
              onChanged: (value) => widget.onRollNumberChanged(value),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Advisor',
              value: _selectedAdvisor,
              items: _faculties.advisorsList,
              prefixIcon: Icons.person_outline,
              onChanged: (value) {
                setState(() => _selectedAdvisor = value);
                widget.onAdvisorChanged(value);
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Faculty',
              value: _selectedFaculty,
              items: _faculties.allFacultyList,
              prefixIcon: Icons.school,
              onChanged: (value) {
                setState(() => _selectedFaculty = value);
                widget.onFacultyChanged(value);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Principal'),
              value: _includePrincipal,
              onChanged: (value) {
                setState(() => _includePrincipal = value);
                widget.onPrincipalChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool readOnly = false,
    void Function(String)? onChanged,
  }) {
    final bool isRollNumberEnabled = label == 'Roll No.'
        ? (_selectedBatch != null && _selectedBranch != null)
        : true;

    return TextFormField(
      controller: controller,
      readOnly: readOnly || (label == 'Roll No.' && !isRollNumberEnabled),
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
      onChanged: onChanged,
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
}
