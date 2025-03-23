import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/db_service.dart';
import 'package:csms/helper/database/threed_print_db.dart';
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

class PrintRequestsAdmin extends StatefulWidget {
  const PrintRequestsAdmin({super.key});

  @override
  State<PrintRequestsAdmin> createState() => _PrintRequestsAdminState();
}

class _PrintRequestsAdminState extends State<PrintRequestsAdmin> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _currentUserEmail;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() => _isLoading = true);
      final session = await account.get();
      _currentUserEmail = session.email;
      final requests = await ThreeDPrintDB(DBService().db)
          .getPrintRequestsForApproval(session.email);
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
      final comment = _commentController.text.trim();
      await ThreeDPrintDB(DBService().db).updatePrintRequest(
        id,
        _currentUserEmail!,
        status,
        comment: comment.isNotEmpty ? comment : null,
      );

      // Send notification through WebSocket
      final request = _requests.firstWhere((r) => r['_id'].$oid == id);
      final notifData = {
        'type': '3d_print_update',
        'userEmail': request['email'],
        'status': status,
        'data': {
          'fileName': request['fileName'],
          'updatedBy': _currentUserEmail,
          'comment': comment,
          'date': request['requestDate'],
        },
      };

      WebSocketService().sendMessage(json.encode(notifData));

      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print request $status successfully'),
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

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${request['name']}'),
              const SizedBox(height: 8),
              Text('Hours: ${request['hours']}'),
              const SizedBox(height: 8),
              Text('Amount: ₹${request['amount'].toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              if (request['status'] == 'pending') ...[
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Add Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (request['status'] == 'pending') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request['_id'].$oid, 'rejected');
              },
              child: const Text('Reject'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request['_id'].$oid, 'approved');
              },
              child: const Text('Approve'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('3D Print Requests')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pendingRequests = _requests.where((request) =>
        request['status'] == 'pending' &&
        (request['approvalsRequired'] as List?)!.contains(_currentUserEmail));

    final approvedRequests = _requests
        .where((request) =>
            (request['approvedBy'] as List?)?.contains(_currentUserEmail) ??
            false)
        .toList()
      ..sort((a, b) => b['requestDate'].compareTo(a['requestDate']));

    final rejectedRequests = _requests
        .where((request) =>
            (request['rejectedBy'] as List?)?.contains(_currentUserEmail) ??
            false)
        .toList()
      ..sort((a, b) => b['requestDate'].compareTo(a['requestDate']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Print Requests'),
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
                  child: Text('No print requests to show'),
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
                onTap: () => _showRequestDetails(request),
                title: Text(request['name'] ?? 'Unknown'),
                subtitle: Text(
                    'Hours: ${request['hours']} | ₹${request['amount'].toStringAsFixed(2)}'),
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
                                request['_id'].$oid, 'approved'),
                            child: const Text('Approve'),
                          ),
                        ],
                      )
                    : Icon(
                        request['status'] == 'approved'
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
