import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/gate_pass_db.dart' as gate_pass_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csms/presentation/screens/admins/slips/pass_details_dialog.dart';

class GatePassAdmin extends StatefulWidget {
  const GatePassAdmin({super.key});

  @override
  State<GatePassAdmin> createState() => _GatePassAdminState();
}

class _GatePassAdminState extends State<GatePassAdmin> {
  List<Map<String, dynamic>> _passes = [];
  bool _isLoading = true;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadPasses();
  }

  Future<void> _loadPasses() async {
    try {
      setState(() => _isLoading = true);

      // Get current faculty email
      final session = await account.get();
      _currentUserEmail = session.email;

      // Get all passes that need this faculty's approval
      final passes =
          await gate_pass_db.getPassesForApproval(_currentUserEmail!);

      setState(() {
        _passes = passes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading passes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassStatus(String passId, String status) async {
    setState(() => _isLoading = true);
    try {
      final session = await account.get();

      // Use the new updateGatePass function instead of updatePassStatus
      await gate_pass_db.updateGatePass(passId, session.email, status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gate pass ${status.toLowerCase()} successfully'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
        // Refresh the list after update
        _loadPasses();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gate Passes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPasses,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pendingPasses = _passes.where((pass) =>
        pass['status'] == 'pending' &&
        pass['approvalsRequired'].contains(_currentUserEmail));

    // Sort approved and rejected passes by date in descending order
    final approvedPasses = _passes
        .where((pass) => pass['approvedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));

    final rejectedPasses = _passes
        .where((pass) => pass['rejectedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Passes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPasses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarAdmin(),
      body: RefreshIndicator(
        onRefresh: _loadPasses,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingPasses.isNotEmpty) ...[
              _buildPassSection(
                  'Pending Approvals', pendingPasses.toList(), Colors.orange),
              const SizedBox(height: 24),
            ],
            if (approvedPasses.isNotEmpty) ...[
              _buildPassSection(
                  'Approved by You', approvedPasses.toList(), Colors.green),
              const SizedBox(height: 24),
            ],
            if (rejectedPasses.isNotEmpty)
              _buildPassSection(
                  'Rejected by You', rejectedPasses.toList(), Colors.red),
            if (pendingPasses.isEmpty &&
                approvedPasses.isEmpty &&
                rejectedPasses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No gate passes to show'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassSection(
      String title, List<Map<String, dynamic>> passes, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: passes.length,
          itemBuilder: (context, index) {
            final pass = passes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => showPassDetails(context, pass),
                title: Text(pass['name']),
                subtitle: Text(
                    '${pass['date']} (${pass['timeFrom']} - ${pass['timeTo']})'),
                trailing: pass['status'] == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _updatePassStatus(pass['_id'].$oid, 'rejected'),
                            child: const Text('Reject'),
                          ),
                          TextButton(
                            onPressed: () =>
                                _updatePassStatus(pass['_id'].$oid, 'approved'),
                            child: const Text('Approve'),
                          ),
                        ],
                      )
                    : Icon(
                        pass['status'] == 'approved'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: statusColor,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
