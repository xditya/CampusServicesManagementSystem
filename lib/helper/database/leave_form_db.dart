import 'package:csms/helper/database/db_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

Future<void> createLeaveForm(Map<String, dynamic> formData) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('leave_forms');
  await collection.insert(formData);
}

Future<List<Map<String, dynamic>>> getFormsForApproval(
    String facultyEmail) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('leave_forms');

  // Get all forms where the faculty is either required to approve, has approved, or has rejected
  final forms = await collection.find({
    r'$or': [
      {'approvalsRequired': facultyEmail},
      {'approvedBy': facultyEmail},
      {'rejectedBy': facultyEmail},
    ]
  }).toList();

  // Sort by date in descending order
  forms.sort((a, b) =>
      DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

  return forms;
}

Future<List<Map<String, dynamic>>> getFormsByEmail(String email) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('leave_forms');
  return await collection.find(where.eq('email', email)).toList();
}

Future<void> updateLeaveForm(String id, String email, String status) async {
  try {
    final dbService = DBService();
    if (!dbService.isConnected) {
      await dbService.connect();
    }
    final collection = dbService.db.collection('leave_forms');
    final doc =
        await collection.findOne(where.eq('_id', ObjectId.fromHexString(id)));
    if (doc == null) {
      throw Exception('Leave form not found');
    }

    final List<String> approvalsRequired =
        List<String>.from(doc['approvalsRequired'] ?? []);
    final List<String> approvedBy = List<String>.from(doc['approvedBy'] ?? []);
    final List<String> rejectedBy = List<String>.from(doc['rejectedBy'] ?? []);

    if (status == 'approved') {
      if (!approvedBy.contains(email)) {
        approvedBy.add(email);
      }
      approvalsRequired.remove(email);
    } else if (status == 'rejected') {
      if (!rejectedBy.contains(email)) {
        rejectedBy.add(email);
      }
      approvalsRequired.clear(); // Clear remaining approvals on rejection
    }

    String overallStatus;
    if (rejectedBy.isNotEmpty) {
      overallStatus = 'rejected';
    } else if (approvalsRequired.isEmpty && approvedBy.isNotEmpty) {
      overallStatus = 'approved';
    } else {
      overallStatus = 'pending';
    }

    await collection.update(
      where.eq('_id', ObjectId.fromHexString(id)),
      modify
          .set('approvalsRequired', approvalsRequired)
          .set('approvedBy', approvedBy)
          .set('rejectedBy', rejectedBy)
          .set('status', overallStatus)
          .set('lastUpdated', DateTime.now().toIso8601String()),
    );
  } catch (e) {
    throw Exception('Failed to update leave form: $e');
  }
}
