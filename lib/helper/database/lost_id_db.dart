import 'package:csms/helper/database/db_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<List<Map<String, dynamic>>> getIdRequestsForApproval(
    String adminEmail) async {
  final db = DBService().db;
  final requests = await db.collection('id_card_requests').find({
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

Future<void> updateIdRequest(
    String requestId, String adminEmail, String status) async {
  final db = DBService().db;
  final collection = db.collection('id_card_requests');

  final request = await collection.findOne(where.id(ObjectId.parse(requestId)));
  if (request == null) throw Exception('Request not found');

  final List<String> approvedBy =
      List<String>.from(request['approvedBy'] ?? []);
  final List<String> rejectedBy =
      List<String>.from(request['rejectedBy'] ?? []);
  final List<String> approvalsRequired =
      List<String>.from(request['approvalsRequired'] ?? []);

  if (status == 'accepted') {
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
    overallStatus = 'accepted';
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

Future<void> createIdRequest(Map<String, dynamic> request) async {
  final db = DBService().db;
  await db.collection('id_card_requests').insert(request);
}

Future<bool> hasExistingRequest(String email) async {
  final db = DBService().db;
  final request = await db.collection('id_card_requests').findOne({
    'email': email,
    'status': {r'$ne': 'completed'}
  });
  return request != null;
}

Future<Map<String, dynamic>> getIdRequest(String email) async {
  final db = DBService().db;
  final request =
      await db.collection('id_card_requests').findOne({'email': email});
  if (request == null) throw Exception('No request found');
  return request;
}

Future<void> markRequestCompleted(String email) async {
  final db = DBService().db;
  await db.collection('id_card_requests').updateOne(
    where.eq('email', email),
    {
      r'$set': {
        'status': 'completed',
      }
    },
  );
}
