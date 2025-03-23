import 'package:mongo_dart/mongo_dart.dart';

class ThreeDPrintDB {
  final Db db;

  ThreeDPrintDB(this.db);

  Future<void> createPrintRequest(Map<String, dynamic> request) async {
    try {
      final collection = db.collection('threed_print_requests');
      await collection.insert(request);
    } catch (e) {
      throw Exception('Failed to create 3D print request: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRequestsByEmail(String email) async {
    try {
      final collection = db.collection('threed_print_requests');
      final requests = await collection.find(where.eq('email', email)).toList();
      return requests;
    } catch (e) {
      throw Exception('Failed to fetch 3D print requests: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPrintRequestsForApproval(
      String adminEmail) async {
    try {
      final collection = db.collection('threed_print_requests');
      final selector = where
          .eq('status', 'pending')
          .and(where.oneFrom('approvalsRequired', [adminEmail]))
          .or(where.oneFrom('approvedBy', [adminEmail]))
          .or(where.oneFrom('rejectedBy', [adminEmail]))
          .sortBy('requestDate', descending: true);

      final requests = await collection.find(selector).toList();
      return requests;
    } catch (e) {
      print('Error fetching requests: $e');
      throw Exception('Failed to fetch 3D print requests: $e');
    }
  }

  Future<void> updatePrintRequest(String id, String adminEmail, String status,
      {String? comment}) async {
    try {
      final collection = db.collection('threed_print_requests');
      final objectId = ObjectId.fromHexString(id);

      final update = {
        '\$set': {
          'status': status,
          'updatedAt': DateTime.now().toIso8601String(),
          if (comment != null) 'comment': comment,
        },
      };

      if (status == 'approved') {
        update['\$addToSet'] = {'approvedBy': adminEmail};
      } else if (status == 'rejected') {
        update['\$addToSet'] = {'rejectedBy': adminEmail};
      }

      await collection.updateOne(
        where.id(objectId),
        update,
      );
    } catch (e) {
      throw Exception('Failed to update 3D print request: $e');
    }
  }
}
