import '../models/print_request.dart';
import '../helper/database/db_service.dart';

class PrintService {
  static const String collectionName = 'print_requests';
  final DBService _dbService = DBService();

  Future<void> savePrintRequest(String email, PrintRequest request) async {
    try {
      if (!_dbService.isConnected) {
        await _dbService.connect();
      }

      final collection = _dbService.db.collection(collectionName);

      // Check if user already has print requests
      final existingDoc = await collection.findOne({'_id': email});

      if (existingDoc != null) {
        // Add new request to existing array
        await collection.update(
          {'_id': email},
          {
            '\$push': {
              'requests': request.toJson(),
            }
          },
        );
      } else {
        // Create new document with first request
        await collection.insert({
          '_id': email,
          'requests': [request.toJson()],
        });
      }
    } catch (e) {
      throw Exception('Failed to save print request: $e');
    }
  }

  Future<List<PrintRequest>> getUserPrintRequests(String email) async {
    try {
      if (!_dbService.isConnected) {
        await _dbService.connect();
      }

      final collection = _dbService.db.collection(collectionName);
      final doc = await collection.findOne({'_id': email});

      if (doc == null || !doc.containsKey('requests')) {
        return [];
      }

      final requests = doc['requests'] as List;
      return requests.map((request) => PrintRequest.fromJson(request)).toList();
    } catch (e) {
      throw Exception('Failed to get print requests: $e');
    }
  }
}
