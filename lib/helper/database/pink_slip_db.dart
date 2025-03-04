import 'package:csms/helper/database/db_service.dart';
import 'package:csms/models/pink_slip.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:csms/services/websocket_service.dart';
import 'dart:convert';

Future<void> createPinkSlip(Map<String, dynamic> slipData) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('pink_slips');
  await collection.insert(slipData);
}

Future<Map<String, dynamic>?> getPinkSlip(String id) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('pink_slips');
  return await collection.findOne(where.eq('_id', ObjectId.fromHexString(id)));
}

Future<List<Map<String, dynamic>>> getSlipsForApproval(
    String facultyEmail) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('pink_slips');

  // Get all slips where the faculty:
  // 1. Is in approvalsRequired, OR
  // 2. Has already approved (in approvedBy), OR
  // 3. Has already rejected (in rejectedBy), OR
  // 4. Is principal and slip needs principal approval
  return await collection.find({
    r'$or': [
      {'approvalsRequired': facultyEmail},
      {'approvedBy': facultyEmail},
      {'rejectedBy': facultyEmail},
      {'faculty': facultyEmail, 'includePrincipal': true}
    ]
  }).toList();
}

Future<List<Map<String, dynamic>>> getSlipsByEmail(String email) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('pink_slips');
  return await collection.find(where.eq('email', email)).toList();
}

Future<void> updatePinkSlip(String id, String email, String status) async {
  try {
    final dbService = DBService();
    if (!dbService.isConnected) {
      await dbService.connect();
    }
    final collection = dbService.db.collection('pink_slips');
    final doc =
        await collection.findOne(where.eq('_id', ObjectId.fromHexString(id)));
    if (doc == null) {
      throw Exception('Pink slip not found');
    }

    final pinkSlip = PinkSlip.fromJson(doc);
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
      approvalsRequired.clear();
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
          .set('status', overallStatus),
    );

    if (overallStatus == 'approved' || overallStatus == 'rejected') {
      WebSocketService().sendMessage(
        json.encode({
          'type': 'pink_slip_update',
          'userEmail': pinkSlip.email,
          'status': overallStatus,
          'data': {
            'date': pinkSlip.date,
            'timeFrom': pinkSlip.timeFrom,
            'timeTo': pinkSlip.timeTo,
            'reason': pinkSlip.reason,
            'approvedBy': approvedBy,
            'rejectedBy': rejectedBy,
            'updatedBy': email,
          },
        }),
      );
    }
  } catch (e) {
    throw Exception('Failed to update pink slip: $e');
  }
}

Future<void> updateSlipStatus(
    String id, String status, String userEmail) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final slips = dbService.db.collection('pink_slips');

  final updateData = {
    if (status == 'approved')
      r'$push': {'approvedBy': userEmail}
    else if (status == 'rejected')
      r'$push': {'rejectedBy': userEmail}
  };

  await slips.updateOne(
    where.id(ObjectId.fromHexString(id)),
    {
      ...updateData,
      r'$set': {'status': status},
    },
  );
}

Future<Map<String, int>> getSlipCounts(String facultyEmail) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('pink_slips');

  final slips = await collection.find({
    r'$or': [
      {'approvalsRequired': facultyEmail},
      {'approvedBy': facultyEmail},
      {'rejectedBy': facultyEmail},
      {'faculty': facultyEmail, 'includePrincipal': true}
    ]
  }).toList();

  return {
    'pending': slips
        .where((slip) =>
            slip['status'] == 'pending' &&
            slip['approvalsRequired'].contains(facultyEmail))
        .length,
    'approved':
        slips.where((slip) => slip['approvedBy'].contains(facultyEmail)).length,
    'rejected':
        slips.where((slip) => slip['rejectedBy'].contains(facultyEmail)).length,
  };
}
