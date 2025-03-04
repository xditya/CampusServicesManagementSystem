import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/pink_slip_db.dart' as pink_slip_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:csms/presentation/screens/admins/slips/pass_details_dialog.dart';

class PinkSlipsAdmin extends StatefulWidget {
  const PinkSlipsAdmin({super.key});

  @override
  State<PinkSlipsAdmin> createState() => _PinkSlipsAdminState();
}

class _PinkSlipsAdminState extends State<PinkSlipsAdmin> {
  List<Map<String, dynamic>> _passes = [];
  bool _isLoading = true;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadSlips();
  }

  Future<void> _loadSlips() async {
    try {
      setState(() => _isLoading = true);
      final session = await account.get();
      _currentUserEmail = session.email;
      final slips = await pink_slip_db.getSlipsForApproval(session.email);

      setState(() => _passes = slips);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSlipStatus(String id, String status) async {
    try {
      await pink_slip_db.updatePinkSlip(
        id,
        _currentUserEmail!,
        status,
      );
      await _loadSlips();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pink slip $status successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pink Slips'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadSlips,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pendingSlips = _passes.where((slip) =>
        slip['status'] == 'pending' &&
        slip['approvalsRequired'].contains(_currentUserEmail));

    // Sort approved and rejected slips by date in descending order
    final approvedSlips = _passes
        .where((slip) => slip['approvedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));

    final rejectedSlips = _passes
        .where((slip) => slip['rejectedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pink Slips'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSlips,
            tooltip: 'Refresh',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarAdmin(),
      body: RefreshIndicator(
        onRefresh: _loadSlips,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingSlips.isNotEmpty) ...[
              _buildPassSection(
                  'Pending Approvals', pendingSlips.toList(), Colors.orange),
              const SizedBox(height: 24),
            ],
            if (approvedSlips.isNotEmpty) ...[
              _buildPassSection('Approved by You', approvedSlips, Colors.green),
              const SizedBox(height: 24),
            ],
            if (rejectedSlips.isNotEmpty)
              _buildPassSection('Rejected by You', rejectedSlips, Colors.red),
            if (pendingSlips.isEmpty &&
                approvedSlips.isEmpty &&
                rejectedSlips.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pink slips to show'),
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
                                _updateSlipStatus(pass['_id'].$oid, 'rejected'),
                            child: const Text('Reject'),
                          ),
                          TextButton(
                            onPressed: () =>
                                _updateSlipStatus(pass['_id'].$oid, 'approved'),
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
}
