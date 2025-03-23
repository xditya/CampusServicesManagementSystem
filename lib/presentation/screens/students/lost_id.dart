import 'package:csms/helper/config.dart';
import 'package:csms/helper/data/faculties.dart';
import 'package:csms/helper/database/balance_db.dart' as balance_db;
import 'package:csms/helper/database/lost_id_db.dart' as id_card_db;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/widgets/student_info_card.dart';

class LostIdPage extends StatefulWidget {
  const LostIdPage({super.key});

  @override
  State<LostIdPage> createState() => _LostIdPageState();
}

class _LostIdPageState extends State<LostIdPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;
  String _rollNo = '';
  bool _isLoading = false;
  bool _hasExistingRequest = false;
  Map<String, dynamic>? _receipt;

  final double _idCardFee = 300.0;

  String? _selectedAdvisor;
  String? _selectedFaculty;
  bool _includePrincipal = false;

  final faculties = Faculties();

  @override
  void initState() {
    super.initState();
    _checkExistingRequest();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingRequest() async {
    setState(() => _isLoading = true);
    try {
      final session = await account.get();
      final hasRequest = await id_card_db.hasExistingRequest(session.email);
      if (hasRequest) {
        final receipt = await id_card_db.getIdRequest(session.email);
        setState(() {
          _hasExistingRequest = true;
          _receipt = receipt;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking request status: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost ID Card Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasExistingRequest) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    StudentInfoCard(
                      onNameChanged: (name) =>
                          setState(() => _studentNameController.text = name),
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
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ID Card Fee',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Amount to be paid: ₹${_idCardFee.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                onPressed: _isLoading ? null : _submitRequest,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      Colors.green.withOpacity(0.6),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Pay and Submit Request',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_receipt != null) ...[
              _buildReceipt(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt() {
    final bool isRejected = _receipt!['status'] == 'rejected';
    final bool isApproved = _receipt!['status'] == 'approved';
    final bool showApplyAgain = isRejected || isApproved;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ID Card Request Receipt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRejected
                        ? Colors.red.withOpacity(0.1)
                        : isApproved
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _receipt!['status'].toUpperCase(),
                    style: TextStyle(
                      color: isRejected
                          ? Colors.red
                          : isApproved
                              ? Colors.green
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _receiptRow('Name', _receipt!['name']),
            _receiptRow('Email', _receipt!['email']),
            _receiptRow('Roll Number', _receipt!['rollNo']),
            _receiptRow('Branch', _receipt!['branch']),
            _receiptRow('Class', _receipt!['class']),
            _receiptRow('Batch', _receipt!['batch']),
            _receiptRow('Year of Passing', _receipt!['yearOfPassing']),
            _receiptRow(
                'Request Date',
                DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(_receipt!['requestDate']))),
            _receiptRow('Amount Paid', '₹${_receipt!['amountPaid']}'),
            if (showApplyAgain) ...[
              const Divider(height: 32),
              if (isRejected)
                Text(
                  'Rejected by: ${(_receipt!['rejectedBy'] as List).first}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await id_card_db.markRequestCompleted(_receipt!['email']);
                      setState(() {
                        _hasExistingRequest = false;
                        _receipt = null;
                      });
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
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

        if (currentBalance < _idCardFee) {
          throw Exception('Insufficient balance in wallet');
        }

        // Deduct amount from wallet
        await balance_db.updateBalance(
          session.email,
          -_idCardFee,
          'ID Card Request',
        );

        // Create ID card request using entered name from StudentInfoCard
        final requestData = {
          'email': session.email,
          'name': _studentNameController.text,
          'rollNo': _rollNo,
          'branch': _selectedBranch,
          'class': _selectedClass,
          'batch': _selectedBatch,
          'yearOfPassing': _selectedBatch,
          'requestDate': DateTime.now().toString(),
          'amountPaid': _idCardFee,
          'status': 'pending',
          'approvalsRequired': [
            if (_selectedAdvisor != null)
              faculties.allFacultyEmails[_selectedAdvisor]!,
            if (_selectedFaculty != null)
              faculties.allFacultyEmails[_selectedFaculty]!,
            if (_includePrincipal)
              faculties.allFacultyEmails[faculties.principal]!,
          ],
          'approvedBy': [],
          'rejectedBy': [],
        };

        await id_card_db.createIdRequest(requestData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID card request submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _checkExistingRequest(); // Refresh to show receipt
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
