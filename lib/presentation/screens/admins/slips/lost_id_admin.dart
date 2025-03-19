import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/lost_id_db.dart' as id_card_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:csms/presentation/screens/admins/slips/pass_details_dialog.dart';
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

class LostIdAdmin extends StatefulWidget {
  const LostIdAdmin({super.key});

  @override
  State<LostIdAdmin> createState() => _LostIdAdminState();
}

class _LostIdAdminState extends State<LostIdAdmin> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() => _isLoading = true);
      final session = await account.get();
      _currentUserEmail = session.email;
      final requests =
          await id_card_db.getIdRequestsForApproval(_currentUserEmail!);
      setState(() => _requests = requests);
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

  Future<void> _updateRequestStatus(String id, String status) async {
    try {
      await id_card_db.updateIdRequest(
        id,
        _currentUserEmail!,
        status,
      );

      // Send notification through WebSocket
      final request = _requests.firstWhere((r) => r['_id'].$oid == id);
      final notifData = {
        'type': 'id_card_update',
        'userEmail': request['email'],
        'status': status,
        'data': {
          'name': request['name'],
          'updatedBy': _currentUserEmail,
          'date': request['requestDate'],
        },
      };

      WebSocketService().sendMessage(json.encode(notifData));

      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID card request $status successfully'),
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
        appBar: AppBar(title: const Text('ID Card Requests')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pendingRequests = _requests.where((request) =>
        request['status'] == 'pending' &&
        request['approvalsRequired'].contains(_currentUserEmail));

    final approvedRequests = _requests
        .where((request) => request['approvedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['requestDate'].compareTo(a['requestDate']));

    final rejectedRequests = _requests
        .where((request) => request['rejectedBy'].contains(_currentUserEmail))
        .toList()
      ..sort((a, b) => b['requestDate'].compareTo(a['requestDate']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarAdmin(),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingRequests.isNotEmpty) ...[
              _buildRequestSection(
                  'Pending Approvals', pendingRequests.toList(), Colors.orange),
              const SizedBox(height: 24),
            ],
            if (approvedRequests.isNotEmpty) ...[
              _buildRequestSection(
                  'Approved by You', approvedRequests, Colors.green),
              const SizedBox(height: 24),
            ],
            if (rejectedRequests.isNotEmpty)
              _buildRequestSection(
                  'Rejected by You', rejectedRequests, Colors.red),
            if (pendingRequests.isEmpty &&
                approvedRequests.isEmpty &&
                rejectedRequests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No ID card requests to show'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSection(
      String title, List<Map<String, dynamic>> requests, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => showPassDetails(context, request),
                title: Text(request['name']),
                subtitle: Text('Roll No: ${request['rollNo']}'),
                trailing: request['status'] == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _updateRequestStatus(
                                request['_id'].$oid, 'rejected'),
                            child: const Text('Reject'),
                          ),
                          TextButton(
                            onPressed: () => _updateRequestStatus(
                                request['_id'].$oid, 'accepted'),
                            child: const Text('Accept'),
                          ),
                        ],
                      )
                    : Icon(
                        request['status'] == 'accepted'
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
