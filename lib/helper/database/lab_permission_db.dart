import 'package:mongo_dart/mongo_dart.dart';
import 'db_service.dart';

Future<List<Map<String, dynamic>>> getPermissionsForApproval(
    String facultyEmail) async {
  final db = DBService().db;
  final permissions = await db.collection('lab_permissions').find({
    r'$or': [
      {
        r'$and': [
          {'status': 'pending'},
          {'approvalsRequired': facultyEmail}
        ]
      },
      {'approvedBy': facultyEmail},
      {'rejectedBy': facultyEmail},
    ]
  }).toList();
  return permissions;
}

Future<void> updateLabPermission(
    String permissionId, String facultyEmail, String status) async {
  final db = DBService().db;
  final collection = db.collection('lab_permissions');

  // Get the current permission document
  final permission =
      await collection.findOne(where.id(ObjectId.parse(permissionId)));
  if (permission == null) throw Exception('Permission not found');

  final List<String> approvedBy =
      List<String>.from(permission['approvedBy'] ?? []);
  final List<String> rejectedBy =
      List<String>.from(permission['rejectedBy'] ?? []);
  final List<String> approvalsRequired =
      List<String>.from(permission['approvalsRequired'] ?? []);

  // Update the appropriate lists based on the status
  if (status == 'approved') {
    if (!approvedBy.contains(facultyEmail)) {
      approvedBy.add(facultyEmail);
    }
    rejectedBy.remove(facultyEmail);
  } else if (status == 'rejected') {
    if (!rejectedBy.contains(facultyEmail)) {
      rejectedBy.add(facultyEmail);
    }
    approvedBy.remove(facultyEmail);
  }

  // Remove the faculty from approvalsRequired
  approvalsRequired.remove(facultyEmail);

  // Determine the overall status
  String overallStatus = 'pending';
  if (rejectedBy.isNotEmpty) {
    overallStatus = 'rejected';
  } else if (approvalsRequired.isEmpty && approvedBy.isNotEmpty) {
    overallStatus = 'approved';
  }

  // Update the document
  await collection.updateOne(
    where.id(ObjectId.parse(permissionId)),
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

Future<void> createLabPermission(Map<String, dynamic> permission) async {
  final db = DBService().db;
  await db.collection('lab_permissions').insert(permission);
}

Future<List<Map<String, dynamic>>> getLabPermissionsByEmail(
    String email) async {
  final db = DBService().db;
  return await db.collection('lab_permissions').find({'email': email}).toList();
}
