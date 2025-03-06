import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/lab_permission_db.dart'
    as lab_permission_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:csms/presentation/screens/admins/slips/pass_details_dialog.dart';
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

class LabPermissionAdmin extends StatefulWidget {
  const LabPermissionAdmin({super.key});

  @override
  State<LabPermissionAdmin> createState() => _LabPermissionAdminState();
}

class _LabPermissionAdminState extends State<LabPermissionAdmin> {
  List<Map<String, dynamic>> _permissions = [];
  bool _isLoading = true;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      setState(() => _isLoading = true);
      final session = await account.get();
      _currentUserEmail = session.email;
      final permissions =
          await lab_permission_db.getPermissionsForApproval(_currentUserEmail!);
      setState(() => _permissions = permissions);
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

  Future<void> _updatePermissionStatus(String id, String status) async {
    try {
      await lab_permission_db.updateLabPermission(
        id,
        _currentUserEmail!,
        status,
      );

      // Send notification through WebSocket
      final permission = _permissions.firstWhere((p) => p['_id'].$oid == id);
      final notifData = {
        'type': 'lab_permission_update',
        'userEmail': permission['email'],
        'status': status,
        'data': {
          'lab': permission['lab'],
          'date': permission['date'],
          'updatedBy': _currentUserEmail,
        },
      };

      WebSocketService().sendMessage(json.encode(notifData));

      await _loadPermissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lab permission $status successfully'),
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
          title: const Text('Lab Permissions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPermissions,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pendingPermissions = _permissions.where((permission) =>
        permission['status'] == 'pending' &&
        permission['approvalsRequired'].contains(_currentUserEmail));

    final approvedPermissions = _permissions
        .where((permission) =>
            permission['approvedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));

    final rejectedPermissions = _permissions
        .where((permission) =>
            permission['rejectedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Permissions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPermissions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarAdmin(),
      body: RefreshIndicator(
        onRefresh: _loadPermissions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingPermissions.isNotEmpty) ...[
              _buildPermissionSection('Pending Approvals',
                  pendingPermissions.toList(), Colors.orange),
              const SizedBox(height: 24),
            ],
            if (approvedPermissions.isNotEmpty) ...[
              _buildPermissionSection(
                  'Approved by You', approvedPermissions, Colors.green),
              const SizedBox(height: 24),
            ],
            if (rejectedPermissions.isNotEmpty)
              _buildPermissionSection(
                  'Rejected by You', rejectedPermissions, Colors.red),
            if (pendingPermissions.isEmpty &&
                approvedPermissions.isEmpty &&
                rejectedPermissions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No lab permissions to show'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(
      String title, List<Map<String, dynamic>> permissions, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: permissions.length,
          itemBuilder: (context, index) {
            final permission = permissions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => showPassDetails(context, permission),
                title: Text(permission['name']),
                subtitle: Text(
                    '${permission['date']} (${permission['timeFrom']} - ${permission['timeTo']})'),
                trailing: permission['status'] == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _updatePermissionStatus(
                                permission['_id'].$oid, 'rejected'),
                            child: const Text('Reject'),
                          ),
                          TextButton(
                            onPressed: () => _updatePermissionStatus(
                                permission['_id'].$oid, 'approved'),
                            child: const Text('Approve'),
                          ),
                        ],
                      )
                    : Icon(
                        permission['status'] == 'approved'
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
