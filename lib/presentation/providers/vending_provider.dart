import 'package:csms/helper/vending_items.dart';
import 'package:flutter/foundation.dart';
import 'package:csms/helper/database/balance_db.dart';
import 'package:csms/helper/config.dart';

class VendingProvider extends ChangeNotifier {
  final Map<String, int> _selectedItems = {};
  final List<Order> _orders = [];
  double _walletBalance = 0.0;

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

    if (totalCost > _walletBalance) {
      throw Exception('Insufficient balance');
    }

    try {
      await updateBalance(session.email, -totalCost, "vending machine");
      _walletBalance -= totalCost;
      _orders.add(
        Order(
          items: _selectedItems.entries
              .map((e) =>
                  vendingItems.firstWhere((item) => item.id == e.key).name)
              .toList(),
          status: 'Processing',
          total: totalCost,
        ),
      );
      _selectedItems.clear();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to process purchase: $e');
    }
  }
}

class Order {
  final List<String> items;
  final String status;
  final double total;

  Order({
    required this.items,
    required this.status,
    required this.total,
  });
}
