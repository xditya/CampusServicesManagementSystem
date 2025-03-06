import 'package:csms/helper/data/vending_items.dart';
import 'package:flutter/foundation.dart';
import 'package:csms/helper/database/balance_db.dart';
import 'package:csms/helper/database/vending_db.dart';
import 'package:csms/helper/config.dart';
import 'package:flutter/material.dart';

class VendingProvider extends ChangeNotifier {
  final Map<String, int> _selectedItems = {};
  final List<Order> _orders = [];
  double _walletBalance = 0.0;
  final VendingDB _vendingDB;

  VendingProvider(this._vendingDB);

  Map<String, int> get selectedItems => _selectedItems;
  List<Order> get orders => _orders;
  double get walletBalance => _walletBalance;

  double get totalCost {
    double total = 0;
    for (var entry in _selectedItems.entries) {
      final item = vendingItems.firstWhere((i) => i.id == entry.key);
      total += item.price * entry.value;
    }
    return total;
  }

  void updateQuantity(String itemId, int delta) {
    final currentQty = _selectedItems[itemId] ?? 0;
    final newQty = currentQty + delta;

    if (newQty <= 0) {
      _selectedItems.remove(itemId);
    } else {
      _selectedItems[itemId] = newQty;
    }
    notifyListeners();
  }

  Future<void> loadWalletBalance() async {
    final session = await account.get();
    _walletBalance = await getBalance(session.email);
    notifyListeners();
  }

  Future<void> processPurchase() async {
    final session = await account.get();

    if (_selectedItems.isEmpty) {
      throw 'Please select items to purchase.';
    }

    if (totalCost > _walletBalance) {
      throw 'Insufficient balance. Please add funds to continue.';
    }

    try {
      await updateBalance(session.email, -totalCost, "vending machine");
      _walletBalance -= totalCost;

      final orderDetails =
          await _vendingDB.addOrder(session.email, _selectedItems);

      _orders.insert(
          0,
          Order(
            items: Map<String, int>.from(_selectedItems),
            status: 'Placed',
            total: totalCost,
            hash: orderDetails['hash'],
          ));

      _selectedItems.clear();
      notifyListeners();
    } catch (e) {
      if (_walletBalance != walletBalance) {
        await updateBalance(session.email, totalCost, "vending machine refund");
        _walletBalance += totalCost;
      }
      throw 'Failed to process purchase: ${e.toString()}';
    }
  }

  Future<void> loadOrders() async {
    final session = await account.get();
    final dbOrders = await _vendingDB.getAllOrders(session.email);

    _orders.clear();
    _orders.addAll(
      dbOrders.map((order) => Order(
            items: Map<String, int>.from(order['items'] as Map),
            status: (order['status'] is bool)
                ? (order['status'] ? 'Completed' : 'Placed')
                : order['status'] as String? ?? 'Placed',
            total: (order['totalCost'] as num).toDouble(),
            hash: order['hash']?.toString() ?? 'unknown',
          )),
    );
    notifyListeners();
  }
}

class Order {
  final Map<String, int> items;
  final String status;
  final double total;
  final String hash;
  final DateTime timestamp;

  Order({
    required this.items,
    String? status,
    required this.total,
    required this.hash,
    DateTime? timestamp,
  })  : status = status ?? 'Placed',
        timestamp = timestamp ?? DateTime.now();
}
