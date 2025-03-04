import 'package:csms/helper/database/db_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<void> createGatePass(Map<String, dynamic> passData) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('gate_passes');
  await collection.insert(passData);
}

Future<Map<String, dynamic>?> getGatePass(String id) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('gate_passes');
  return await collection.findOne(where.eq('_id', ObjectId.fromHexString(id)));
}

Future<List<Map<String, dynamic>>> getPassesForApproval(
    String facultyEmail) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('gate_passes');

  // Get passes where this faculty's email is in approvalsRequired
  final passes = await collection
      .find(where.eq('approvalsRequired', facultyEmail))
      .toList();

  return passes;
}

@deprecated
Future<void> updatePassStatus(
    String passId, String status, String facultyEmail) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('gate_passes');

  if (status == 'approved') {
    // Add faculty email to approvedBy list
    await collection.update(
      where.eq('_id', ObjectId.fromHexString(passId)),
      modify.push('approvedBy', facultyEmail),
    );
  } else if (status == 'rejected') {
    // Add faculty email to rejectedBy list
    await collection.update(
      where.eq('_id', ObjectId.fromHexString(passId)),
      modify.push('rejectedBy', facultyEmail),
    );
  }

  // Update status if all required approvals are received
  final pass =
      await collection.findOne(where.eq('_id', ObjectId.fromHexString(passId)));
  final approvalsRequired = pass!['approvalsRequired'] as List;
  final approvedBy = pass['approvedBy'] as List;

  if (approvedBy.length == approvalsRequired.length) {
    await collection.update(
      where.eq('_id', ObjectId.fromHexString(passId)),
      modify.set('status', 'approved'),
    );
  }
}

Future<List<Map<String, dynamic>>> getPassesByEmail(String email) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('gate_passes');

  return await collection.find(where.eq('email', email)).toList();
}

Future<void> updateGatePass(String id, String email, String status) async {
  try {
    final dbService = DBService();
    if (!dbService.isConnected) {
      await dbService.connect();
    }
    final collection = dbService.db.collection('gate_passes');
    final doc =
        await collection.findOne(where.eq('_id', ObjectId.fromHexString(id)));
    if (doc == null) {
      throw Exception('Gate pass not found');
    }

    final data = doc as Map<String, dynamic>;
    final List<String> approvalsRequired =
        List<String>.from(data['approvalsRequired'] ?? []);
    final List<String> approvedBy = List<String>.from(data['approvedBy'] ?? []);
    final List<String> rejectedBy = List<String>.from(data['rejectedBy'] ?? []);

    if (status == 'approved') {
      if (!approvedBy.contains(email)) {
        approvedBy.add(email);
      }
      // Remove from approvalsRequired when approved
      approvalsRequired.remove(email);
    } else if (status == 'rejected') {
      if (!rejectedBy.contains(email)) {
        rejectedBy.add(email);
      }
      // When rejected, clear all pending approvals
      approvalsRequired.clear();
    }

    // Update the overall status
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
          .set('status', overallStatus),
    );
  } catch (e) {
    throw Exception('Failed to update gate pass: $e');
  }
}
