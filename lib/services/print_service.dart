import 'package:csms/services/websocket_service.dart';

import '../models/print_request.dart';
import '../helper/database/db_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';

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

  Future<List<Map<String, dynamic>>> getAllPrintRequests() async {
    try {
      if (!_dbService.isConnected) {
        await _dbService.connect();
      }

      final collection = _dbService.db.collection(collectionName);
      final cursor = collection.find();
      final documents = await cursor.toList();

      // Transform the data structure to flatten requests with user email
      List<Map<String, dynamic>> allRequests = [];

      for (var doc in documents) {
        final userEmail = doc['_id'] as String;
        final requests = doc['requests'] as List;

        for (var request in requests) {
          // Add the request with user email
          allRequests.add({
            '_id': userEmail,
            ...request as Map<String, dynamic>,
          });
        }
      }

      return allRequests;
    } catch (e) {
      throw Exception('Failed to get print requests: $e');
    }
  }

  Future<void> updatePrintRequestStatus(String userEmail, String status) async {
    try {
      if (!_dbService.isConnected) {
        await _dbService.connect();
      }

      final collection = _dbService.db.collection(collectionName);

      // Get the current document to find the request index
      final doc = await collection.findOne(where.eq('_id', userEmail));
      if (doc == null || !doc.containsKey('requests')) {
        throw Exception('Order not found');
      }

      final requests = doc['requests'] as List;
      final requestIndex =
          requests.indexWhere((req) => req['status'] == 'pending');

      if (requestIndex == -1) {
        throw Exception('No pending request found');
      }

      // Update the specific request in the array
      await collection.update(
        where.eq('_id', userEmail),
        modify.set('requests.$requestIndex.status', status),
      );

      // If status is completed, send WebSocket message
      if (status == 'completed') {
        // Send WebSocket message
        WebSocketService().sendMessage(
          json.encode({
            'type': 'print_completed',
            'userEmail': userEmail,
          }),
        );
      }
    } catch (e) {
      throw Exception('Failed to update print request status: $e');
    }
  }

  Future<List<int>> getFileBytes(String orderId) async {
    try {
      if (!_dbService.isConnected) {
        await _dbService.connect();
      }

      final collection = _dbService.db.collection(collectionName);
      final doc = await collection.findOne(where.eq('_id', orderId));

      if (doc == null || !doc.containsKey('requests')) {
        throw Exception('Order not found');
      }

      final requests = doc['requests'] as List;
      if (requests.isEmpty) {
        throw Exception('No requests found');
      }

      final request = requests[0];
      final fileBytes = (request['fileBytes'] as BsonBinary).byteList;
      return fileBytes;
    } catch (e) {
      throw Exception('Failed to get file bytes: $e');
    }
  }

  Future<Map<String, dynamic>> getPendingRequest(String userEmail) async {
    try {
      if (!_dbService.isConnected) {
        await _dbService.connect();
      }

      final collection = _dbService.db.collection(collectionName);
      final doc = await collection.findOne(where.eq('_id', userEmail));

      if (doc == null || !doc.containsKey('requests')) {
        throw Exception('Order not found');
      }

      final requests = doc['requests'] as List;
      final pendingRequest = requests.firstWhere(
        (req) => req['status'] == 'pending',
        orElse: () => throw Exception('No pending request found'),
      );

      return pendingRequest as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get pending request: $e');
    }
  }
}
