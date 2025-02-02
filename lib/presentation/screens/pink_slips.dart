import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  final _advisors = Faculties().advisors;
  final _allFaculty = Faculties().allFaculty;
  final _hods = Faculties().hods;
  final _principal = Faculties().principal;

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
    String branchName = _selectedBranch != null ? _hods[_selectedBranch]! : '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pink Slip Request'),
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
                                _updateBranchController();
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
                            'Request Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Request Subject',
                            controller: _requestSubjectController,
                            prefixIcon: Icons.subject,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _requestController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Request',
                              hintText: 'Enter your request details...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.description),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your request';
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
                            onTap: () => _selectDate(context),
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
                          const SizedBox(height: 16),
                          _buildSearchableDropdown(
                            label: 'Faculty (Optional)',
                            value: _selectedFaculty,
                            items: _allFaculty,
                            onChanged: (value) {
                              setState(() => _selectedFaculty = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _branchController,
                            // initialValue: _selectedBranch != null
                            //     ? _hods[_selectedBranch]
                            //     : '',
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'HOD *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person_2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text('Include Principal Approval'),
                            subtitle: Text(_principal),
                            value: _includePrincipal,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (bool? value) {
                              setState(() {
                                _includePrincipal = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildButtons(),
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

  Widget _buildButtons() {
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
                'Submit Request',
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
              content: Text('Pink slip request submitted successfully'),
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
