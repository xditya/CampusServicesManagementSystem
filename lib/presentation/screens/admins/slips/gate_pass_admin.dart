import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/gate_pass_db.dart' as gate_pass_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      if (session == null) throw Exception('No session found');

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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pendingPasses =
        _passes.where((pass) => pass['status'] == 'pending').toList();
    final approvedPasses =
        _passes.where((pass) => pass['status'] == 'approved').toList();
    final rejectedPasses =
        _passes.where((pass) => pass['status'] == 'rejected').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Pass Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPasses,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarAdmin(),
      body: RefreshIndicator(
        onRefresh: _loadPasses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPassSection(
                    'Pending Approvals', pendingPasses, Colors.orange),
                const SizedBox(height: 20),
                _buildPassSection(
                    'Approved Passes', approvedPasses, Colors.green),
                const SizedBox(height: 20),
                _buildPassSection(
                    'Rejected Passes', rejectedPasses, Colors.red),
                if (_passes.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No gate passes found'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassSection(
      String title, List<Map<String, dynamic>> passes, Color statusColor) {
    if (passes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No passes in this section'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: passes.length,
          itemBuilder: (context, index) {
            final pass = passes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: Icon(Icons.circle, color: statusColor, size: 12),
                title: Text('${pass['name']} (${pass['rollNo']})'),
                subtitle: Text(
                  'Date: ${pass['date']} | ${pass['timeFrom']} - ${pass['timeTo']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Branch & Class',
                            '${pass['branch']} - ${pass['class']}'),
                        _buildInfoRow('Batch', pass['batch']),
                        _buildInfoRow('Reason', pass['reason']),
                        _buildInfoRow(
                            'Request Date',
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(DateTime.parse(pass['requestDate']))),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        // Show approvals (with unique emails)
                        if ((pass['approvedBy'] as List).isNotEmpty) ...[
                          const Text(
                            'Approved by:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...<String>{...pass['approvedBy'] as List}.map(
                            (email) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 4.0),
                              child: Text('• $email'),
                            ),
                          ),
                        ],
                        // Show rejections with timestamp if available
                        if ((pass['rejectedBy'] as List).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Rejected by:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...(pass['rejectedBy'] as List).map(
                            (email) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 4.0),
                              child: Text(
                                '• $email',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                        // Show pending approvals (with unique emails)
                        if (pass['status'] == 'pending') ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Pending approvals from:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...<String>{...pass['approvalsRequired'] as List}
                              .map((email) {
                            final isApproved =
                                (pass['approvedBy'] as List).contains(email);
                            final isRejected =
                                (pass['rejectedBy'] as List).contains(email);
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 4.0),
                              child: Text(
                                '• $email',
                                style: TextStyle(
                                  color: isApproved
                                      ? Colors.green
                                      : isRejected
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                            );
                          }),
                        ],
                        if (pass['status'] == 'pending')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _updatePassStatus(
                                  pass['_id'].$oid,
                                  'rejected',
                                ),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: () => _updatePassStatus(
                                  pass['_id'].$oid,
                                  'approved',
                                ),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
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
