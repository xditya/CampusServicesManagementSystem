import 'package:csms/helper/vending_items.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class VendingDB {
  static const String _collectionName = 'vending_orders';
  final Db _db;

  VendingDB(this._db);

  Future<void> _ensureConnection() async {
    if (_db.state != State.open) {
      await _db.open();
    }
  }

  Future<Map<String, dynamic>> addOrder(
      String email, Map<String, int> items) async {
    await _ensureConnection();
    final collection = _db.collection(_collectionName);

    // Calculate total cost
    final totalCost = items.entries.fold(
        0.0,
        (total, entry) =>
            total +
            (vendingItems.firstWhere((item) => item.id == entry.key).price *
                entry.value));

    // Generate a unique hash for this order
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hashInput = '$email$timestamp${items.toString()}';
    final orderHash = sha256.convert(utf8.encode(hashInput)).toString();

    // Create the order entry
    final orderDetails = {
      'hash': orderHash,
      'items': items,
      'timestamp': timestamp,
      'status': 'Placed',
      'totalCost': totalCost,
    };

    // Update the document, creating if it doesn't exist
    await collection.updateOne(
      where.eq('email', email),
      {
        '\$push': {'orders': orderDetails}
      },
      upsert: true,
    );
    return orderDetails;
  }

  Future<Map<String, dynamic>?> getOrders(String email) async {
    final collection = _db.collection(_collectionName);

    final result = await collection.findOne(where.eq('email', email));
    return result?['orders'] as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getAllOrders(String email) async {
    await _ensureConnection();
    final collection = _db.collection(_collectionName);

    final result = await collection.findOne(where.eq('email', email));
    if (result == null || !result.containsKey('orders')) {
      return [];
    }

    final orders = result['orders'] as Map;

    // Extract orders and include the hash key
    final allOrders = orders.entries.map((entry) {
      final order = (entry.value as List).first as Map<String, dynamic>;
      order['hash'] = entry.key;
      return order;
    }).toList();

    return allOrders;
  }

  Future<Map<String, dynamic>?> getOrderByHash(
      String email, String hash) async {
    await _ensureConnection();
    final collection = _db.collection(_collectionName);

    final result = await collection.findOne(
      where.eq('email', email).and(where.eq('orders.hash', hash)),
    );

    if (result == null || !result.containsKey('orders')) {
      return null;
    }

    final orders = result['orders'] as List;
    return orders.firstWhere(
      (order) => order['hash'] == hash,
      orElse: () => null,
    ) as Map<String, dynamic>?;
  }

  Future<void> deleteOrder(String email, String hash) async {
    final collection = _db.collection(_collectionName);

    await collection.updateOne(
      where.eq('email', email),
      {
        '\$unset': {'orders.$hash': 1}
      },
    );
  }

  Future<void> clearAllOrders(String email) async {
    final collection = _db.collection(_collectionName);

    await collection.updateOne(
      where.eq('email', email),
      {
        '\$set': {'orders': {}}
      },
    );
  }
}
