import 'package:csms/helper/database/db_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<List<Map<String, dynamic>>> getVehiclePassRequestsForApproval(
    String adminEmail) async {
  final db = DBService().db;
  final requests = await db.collection('vehicle_pass_requests').find({
    r'$or': [
      {
        r'$and': [
          {'status': 'pending'},
          {'approvalsRequired': adminEmail}
        ]
      },
      {'approvedBy': adminEmail},
      {'rejectedBy': adminEmail},
    ]
  }).toList();
  return requests;
}

Future<void> updateVehiclePassRequest(
    String requestId, String adminEmail, String status) async {
  final db = DBService().db;
  final collection = db.collection('vehicle_pass_requests');

  final request = await collection.findOne(where.id(ObjectId.parse(requestId)));
  if (request == null) throw Exception('Request not found');

  final List<String> approvedBy =
      List<String>.from(request['approvedBy'] ?? []);
  final List<String> rejectedBy =
      List<String>.from(request['rejectedBy'] ?? []);
  final List<String> approvalsRequired =
      List<String>.from(request['approvalsRequired'] ?? []);

  if (status == 'approved') {
    if (!approvedBy.contains(adminEmail)) {
      approvedBy.add(adminEmail);
    }
    rejectedBy.remove(adminEmail);
  } else if (status == 'rejected') {
    if (!rejectedBy.contains(adminEmail)) {
      rejectedBy.add(adminEmail);
    }
    approvedBy.remove(adminEmail);
  }

  approvalsRequired.remove(adminEmail);

  String overallStatus = 'pending';
  if (rejectedBy.isNotEmpty) {
    overallStatus = 'rejected';
  } else if (approvalsRequired.isEmpty && approvedBy.isNotEmpty) {
    overallStatus = 'approved';
  }

  await collection.updateOne(
    where.id(ObjectId.parse(requestId)),
    {
      r'$set': {
        'status': overallStatus,
        'approvedBy': approvedBy,
        'rejectedBy': rejectedBy,
        'approvalsRequired': approvalsRequired,
      }
    },
  );
}

Future<void> createVehiclePassRequest(Map<String, dynamic> request) async {
  final db = DBService().db;
  await db.collection('vehicle_pass_requests').insert(request);
}

Future<bool> hasExistingRequest(String email) async {
  final db = DBService().db;
  final request = await db.collection('vehicle_pass_requests').findOne({
    'email': email,
    'status': {r'$ne': 'completed'}
  });
  return request != null;
}

Future<Map<String, dynamic>> getVehiclePassRequest(String email) async {
  final db = DBService().db;
  final request =
      await db.collection('vehicle_pass_requests').findOne({'email': email});
  if (request == null) throw Exception('No request found');
  return request;
}

Future<void> markRequestCompleted(String email) async {
  final db = DBService().db;
  await db.collection('vehicle_pass_requests').updateOne(
    where.eq('email', email),
    {
      r'$set': {
        'status': 'completed',
      }
    },
  );
}
