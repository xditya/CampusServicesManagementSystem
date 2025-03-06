import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/widgets/student_info_card.dart';
import 'package:csms/helper/database/pink_slip_db.dart' as pink_slip_db;

class PinkSlipsPage extends StatefulWidget {
  const PinkSlipsPage({super.key});

  @override
  State<PinkSlipsPage> createState() => _PinkSlipsPageState();
}

class _PinkSlipsPageState extends State<PinkSlipsPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _requestSubjectController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _branchController = TextEditingController();
  final _requestController = TextEditingController();
  final _dateController = TextEditingController();
  final _reasonController = TextEditingController();
  final _timeFromController = TextEditingController();
  final _timeToController = TextEditingController();

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  bool _isLoading = false;

  final List<String> _branches = ['EC', 'CS', 'EEE', 'ME', 'CE', 'EL'];
  final List<String> _classes = ['1', '2'];
  late List<String> _batches;

  String? _selectedAdvisor;
  String? _selectedFaculty;
  bool _includePrincipal = false;

  final _faculties = Faculties();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _loadUserName();

    final currentYear = DateTime.now().year;
    _batches = List.generate(4, (index) => (currentYear + index).toString());
  }

  Future<void> _loadUserName() async {
    final session = await account.get();
    setState(() {
      _studentNameController.text = session.name;
    });
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _requestSubjectController.dispose();
    _rollNoController.dispose();
    _requestController.dispose();
    _dateController.dispose();
    _branchController.dispose();
    _reasonController.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    super.dispose();
  }

  void _updateRollNumberPrefix() {
    if (_selectedBatch != null && _selectedBranch != null) {
      // Get last 2 digits of selected year - 4
      final year = int.parse(_selectedBatch!) - 4;
      final yearPrefix = year.toString().substring(year.toString().length - 2);
      // Create roll number prefix
      final rollPrefix = 'B$yearPrefix${_selectedBranch!}';
      // Update roll number field, preserving any text after the prefix
      final currentText = _rollNoController.text;
      final suffixText = currentText.length > rollPrefix.length
          ? currentText.substring(rollPrefix.length)
          : '';
      _rollNoController.text = rollPrefix + suffixText;
      // Place cursor at the end
      _rollNoController.selection = TextSelection.fromPosition(
        TextPosition(offset: _rollNoController.text.length),
      );
    }
  }

  void _updateBranchController() {
    String branchName =
        _selectedBranch != null ? _faculties.hods[_selectedBranch]! : '';
    _branchController.text = branchName;
    // Place cursor at the end
    _branchController.selection = TextSelection.fromPosition(
      TextPosition(offset: branchName.length),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Parse the current selected date from the text field, or use today's date if empty
    final DateTime currentDate = _dateController.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(_dateController.text)
        : DateTime.now();

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate =
            currentDate; // Initialize with current selected date

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
                  initialDate: currentDate, // Use current selected date
                  firstDate: DateTime(currentDate.year - 1),
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
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pink Slip Request'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: InkWell(
                onTap: () => _showMySlips(context),
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
                        'View My Slips',
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
                        _selectedAdvisor = null;
                        _selectedFaculty = null;
                        _updateBranchController();
                      });
                    },
                    onClassChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                        _selectedAdvisor = null;
                      });
                    },
                    onBatchChanged: (value) {
                      setState(() {
                        _selectedBatch = value;
                        _selectedAdvisor = null;
                      });
                    },
                    onRollNumberChanged: (value) =>
                        setState(() => _rollNoController.text = value),
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
                            'Request Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Reason',
                            controller: _reasonController,
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
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.green.withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Pink Slip',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
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
    VoidCallback? onTap,
    int? maxLines,
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
      onTap: onTap ??
          () {
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
        return null;
      },
      maxLines: maxLines,
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

  Future<void> _showMySlips(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => MySlipsSheet(scrollController: controller),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final session = await account.get();
      final faculties = Faculties();
      final slipData = {
        'email': session.email,
        'name': _studentNameController.text,
        'rollNo': _rollNoController.text,
        'branch': _selectedBranch,
        'class': _selectedClass,
        'batch': _selectedBatch,
        'reason': _reasonController.text,
        'date': _dateController.text,
        'timeFrom': _timeFromController.text,
        'timeTo': _timeToController.text,
        'advisor': _selectedAdvisor,
        'faculty': _selectedFaculty,
        'includePrincipal': _includePrincipal,
        'approvalsRequired': {
          faculties.allFacultyEmails[_selectedAdvisor]!,
          if (_selectedFaculty != null)
            faculties.allFacultyEmails[_selectedFaculty]!,
          if (_includePrincipal)
            faculties.allFacultyEmails[faculties.principal]!,
        }.toList(),
        'approvedBy': [],
        'rejectedBy': [],
        'status': 'pending',
        'requestDate': DateTime.now().toIso8601String(),
      };

      await pink_slip_db.createPinkSlip(slipData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pink slip submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class MySlipsSheet extends StatefulWidget {
  final ScrollController scrollController;

  const MySlipsSheet({super.key, required this.scrollController});

  @override
  State<MySlipsSheet> createState() => _MySlipsSheetState();
}

class _MySlipsSheetState extends State<MySlipsSheet> {
  List<Map<String, dynamic>> _slips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlips();
  }

  Future<void> _loadSlips() async {
    try {
      final session = await account.get();
      final slips = await pink_slip_db.getSlipsByEmail(session.email);
      slips.sort((a, b) => DateTime.parse(b['requestDate'])
          .compareTo(DateTime.parse(a['requestDate'])));
      setState(() {
        _slips = slips;
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
            title: const Text('My Pink Slips'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadSlips,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _slips.length,
                      itemBuilder: (context, index) {
                        final slip = _slips[index];
                        final status = slip['status'] as String;
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
                                        slip['date'],
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
                                  slip['reason'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${slip['timeFrom']} - ${slip['timeTo']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (status == 'rejected' &&
                                    slip['rejectedBy'] != null &&
                                    (slip['rejectedBy'] as List)
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rejected by: ${(slip['rejectedBy'] as List).first}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (status == 'pending' &&
                                    slip['approvalsRequired'] != null) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Waiting for approval from: ${(slip['approvalsRequired'] as List).join(", ")}',
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

extension on String {
  toInt() {
    return int.parse(this);
  }
}
