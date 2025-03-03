import 'package:csms/helper/database/db_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<bool> hasExistingRequest(String email) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('id_requests');
  var request = await collection.findOne(where.eq('email', email));
  return request != null;
}

Future<void> createIdRequest(Map<String, dynamic> requestData) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('id_requests');
  await collection.insert(requestData);
}

Future<Map<String, dynamic>?> getIdRequest(String email) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('id_requests');
  return await collection.findOne(where.eq('email', email));
}
