import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/leave_form_db.dart' as leave_form_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:csms/presentation/screens/admins/slips/pass_details_dialog.dart';
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

class LeaveFormsAdmin extends StatefulWidget {
  const LeaveFormsAdmin({super.key});

  @override
  State<LeaveFormsAdmin> createState() => _LeaveFormsAdminState();
}

class _LeaveFormsAdminState extends State<LeaveFormsAdmin> {
  List<Map<String, dynamic>> _forms = [];
  bool _isLoading = true;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    try {
      setState(() => _isLoading = true);
      final session = await account.get();
      _currentUserEmail = session.email;
      final forms = await leave_form_db.getFormsForApproval(_currentUserEmail!);

      // Filter forms based on user's role
      final pendingForms = forms
          .where((form) =>
              form['status'] == 'pending' &&
              (form['approvalsRequired'] as List).contains(_currentUserEmail))
          .toList();

      final approvedForms = forms
          .where((form) =>
              (form['approvedBy'] as List).contains(_currentUserEmail))
          .toList();

      final rejectedForms = forms
          .where((form) =>
              (form['rejectedBy'] as List).contains(_currentUserEmail))
          .toList();

      setState(() {
        _forms = [
          ...pendingForms,
          ...approvedForms,
          ...rejectedForms,
        ];
      });
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

  Future<void> _updateFormStatus(String id, String status) async {
    try {
      setState(() => _isLoading = true);
      final session = await account.get();

      // Get form details before update
      final form = _forms.firstWhere((f) => f['_id'].$oid == id);

      await leave_form_db.updateLeaveForm(id, session.email, status);

      // Send notification to student
      WebSocketService().sendMessage(
        json.encode({
          'type': 'leave_form_update',
          'userEmail': form['email'],
          'status': status,
          'data': {
            'dateFrom': form['dateFrom'],
            'dateTo': form['dateTo'],
            'reason': form['reason'],
            'approvedBy': form['approvedBy'],
            'rejectedBy': form['rejectedBy'],
            'updatedBy': session.email,
          },
        }),
      );

      await _loadForms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave form status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
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
        appBar: AppBar(title: const Text('Leave Forms')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pendingForms = _forms
        .where((form) =>
            form['status'] == 'pending' &&
            (form['approvalsRequired'] as List).contains(_currentUserEmail))
        .toList();

    final approvedForms = _forms
        .where(
            (form) => (form['approvedBy'] as List).contains(_currentUserEmail))
        .toList();

    final rejectedForms = _forms
        .where(
            (form) => (form['rejectedBy'] as List).contains(_currentUserEmail))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Forms'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadForms,
            tooltip: 'Refresh',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarAdmin(),
      body: RefreshIndicator(
        onRefresh: _loadForms,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingForms.isNotEmpty) ...[
              _buildFormSection(
                  'Pending Approvals', pendingForms, Colors.orange),
              const SizedBox(height: 24),
            ],
            if (approvedForms.isNotEmpty) ...[
              _buildFormSection('Approved by You', approvedForms, Colors.green),
              const SizedBox(height: 24),
            ],
            if (rejectedForms.isNotEmpty)
              _buildFormSection('Rejected by You', rejectedForms, Colors.red),
            if (pendingForms.isEmpty &&
                approvedForms.isEmpty &&
                rejectedForms.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No leave forms to show'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(
    String title,
    List<Map<String, dynamic>> forms,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            return Card(
              child: ListTile(
                onTap: () => showPassDetails(context, form),
                title: Text(form['name']),
                subtitle: Text('${form['dateFrom']} to ${form['dateTo']}'),
                trailing: form['status'] == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _updateFormStatus(form['_id'].$oid, 'rejected'),
                            child: const Text('Reject'),
                          ),
                          TextButton(
                            onPressed: () =>
                                _updateFormStatus(form['_id'].$oid, 'approved'),
                            child: const Text('Approve'),
                          ),
                        ],
                      )
                    : Icon(
                        form['status'] == 'approved'
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
