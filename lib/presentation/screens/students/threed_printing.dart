import 'package:csms/helper/config.dart';
import 'package:flutter/material.dart';
import 'package:csms/helper/database/balance_db.dart' as balance_db;
import 'package:csms/presentation/widgets/student_info_card.dart';
import 'package:csms/helper/database/threed_print_db.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:csms/helper/database/db_service.dart';

class ThreeDPrintingPage extends StatefulWidget {
  const ThreeDPrintingPage({super.key});

  @override
  State<ThreeDPrintingPage> createState() => _ThreeDPrintingPageState();
}

class _ThreeDPrintingPageState extends State<ThreeDPrintingPage> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _studentNameController = TextEditingController();

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: InkWell(
                onTap: () => _showMyPrintRequests(context),
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
                        'View My Print Requests',
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
                    onNameChanged: (name) =>
                        setState(() => _studentNameController.text = name),
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
          _selectedBatch == null ||
          _studentNameController.text.isEmpty) {
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

        // Get approvers
        final faculties = Faculties();
        final Set<String> approvalsRequired = {};

        // Add HOD email
        final hodEmail =
            faculties.allFacultyEmails[faculties.hods[_selectedBranch]];
        if (hodEmail != null) approvalsRequired.add(hodEmail);

        // Create print request
        final printRequest = {
          'name': _studentNameController.text,
          'email': session.email,
          'branch': _selectedBranch,
          'class': _selectedClass,
          'batch': _selectedBatch,
          'rollNo': _rollNo,
          'hours': double.parse(_hoursController.text),
          'amount': _totalAmount,
          'status': 'pending',
          'approvalsRequired': approvalsRequired.toList(),
          'approvedBy': [],
          'rejectedBy': [],
          'requestDate': DateTime.now().toIso8601String(),
        };

        // Save to database
        await ThreeDPrintDB(DBService().db).createPrintRequest(printRequest);

        // Deduct amount from wallet
        await balance_db.updateBalance(
          session.email,
          -_totalAmount,
          '3D Printing',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('3D Printing request submitted successfully'),
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

  // Add a method to view request history
  Future<void> _showMyPrintRequests(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) =>
            MyPrintRequestsSheet(scrollController: controller),
      ),
    );
  }
}

class MyPrintRequestsSheet extends StatefulWidget {
  final ScrollController scrollController;

  const MyPrintRequestsSheet({super.key, required this.scrollController});

  @override
  State<MyPrintRequestsSheet> createState() => _MyPrintRequestsSheetState();
}

class _MyPrintRequestsSheetState extends State<MyPrintRequestsSheet> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final session = await account.get();
      final requests =
          await ThreeDPrintDB(DBService().db).getRequestsByEmail(session.email);
      if (mounted) {
        setState(() {
          _requests = requests.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading requests: $e'),
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
          title: const Text('My Print Requests'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final status = request['status'] as String;
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${request['hours']} hours',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
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
                                '₹${request['amount'].toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              if (status == 'pending' &&
                                  request['approvalsRequired'] != null) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Waiting for approval from: ${(request['approvalsRequired'] as List).join(", ")}',
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
