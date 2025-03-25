import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/vehicle_pass_db.dart' as vehicle_pass_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

class VehiclePassAdmin extends StatefulWidget {
  const VehiclePassAdmin({super.key});

  @override
  State<VehiclePassAdmin> createState() => _VehiclePassAdminState();
}

class _VehiclePassAdminState extends State<VehiclePassAdmin> {
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
      final requests = await vehicle_pass_db
          .getVehiclePassRequestsForApproval(session.email);
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
      await vehicle_pass_db.updateVehiclePassRequest(
        id,
        _currentUserEmail!,
        status,
      );

      // Send notification through WebSocket
      final request = _requests.firstWhere((r) => r['_id'].$oid == id);
      final notifData = {
        'type': 'vehicle_pass_update',
        'userEmail': request['email'],
        'status': status,
        'data': {
          'vehicleNumber': request['vehicleNumber'],
          'time': request['timeFrom'],
          'updatedBy': _currentUserEmail,
          'date': request['requestDate'],
        },
      };

      WebSocketService().sendMessage(json.encode(notifData));

      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle pass request $status successfully'),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        title: const Text('Vehicle Pass Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
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
                  child: Text('No vehicle pass requests to show'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSection(
      String title, List<dynamic> requests, Color color) {
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
        ...requests.map((request) => _buildRequestCard(request)),
      ],
    );
  }

  Widget _buildRequestCard(dynamic request) {
    // Implement the logic to build a request card based on the request type
    // This is a placeholder and should be replaced with the actual implementation
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(request['vehicleNumber']),
        subtitle: Text(request['requestDate']),
        trailing: Text(request['status']),
        onTap: () => _handleRequestTap(request),
      ),
    );
  }

  void _handleRequestTap(dynamic request) {
    // Implement the logic to handle request tap
    // This is a placeholder and should be replaced with the actual implementation
  }
}
