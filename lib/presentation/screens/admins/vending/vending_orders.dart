import 'package:csms/helper/database/db_service.dart';
import 'package:csms/helper/database/vending_db.dart';
import 'package:csms/helper/data/vending_items.dart';
import 'package:csms/presentation/widgets/bottom_navbar_vending.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VendingOrders extends StatefulWidget {
  const VendingOrders({super.key});

  @override
  State<VendingOrders> createState() => _VendingOrdersState();
}

class _VendingOrdersState extends State<VendingOrders> {
  Map<String, bool> _isExpanded = {};
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final vendingDB = VendingDB(DBService().db);
      final orders = await vendingDB.getAllOrders();

      setState(() {
        _orders = orders;
        _isExpanded = {
          for (var order in orders) order['hash'].toString(): false
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getItemName(String itemId, int quantity) {
    final item = vendingItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => const VendingItem(
        id: "unknown",
        name: "Unknown Item",
        price: 0,
        icon: Icons.error,
      ),
    );
    return '${item.name} x$quantity';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pendingOrders =
        _orders.where((order) => order['status'] == 'Placed').toList();
    final completedOrders = _orders
        .where((order) =>
            order['status'] == 'Completed' || order["status"] == "Done")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vending Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarVending(),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSection(
                    'Pending Orders', pendingOrders, Colors.orange),
                const SizedBox(height: 20),
                _buildOrderSection(
                    'Completed Orders', completedOrders, Colors.green),
                if (_orders.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No orders found'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSection(
      String title, List<Map<String, dynamic>> ordersList, Color statusColor) {
    if (ordersList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No orders in this section'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ExpansionPanelList(
          elevation: 1,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              final orderHash = ordersList[index]['hash'].toString();
              _isExpanded[orderHash] = !(_isExpanded[orderHash] ?? false);
            });
          },
          children: ordersList.map<ExpansionPanel>((order) {
            final orderHash = order['hash'].toString();
            final items = (order['items'] as Map<String, dynamic>)
                .entries
                .map((entry) => _getItemName(entry.key, entry.value as int))
                .toList();
            final timestamp = DateTime.fromMillisecondsSinceEpoch(
                int.parse(order['timestamp']));

            return ExpansionPanel(
              isExpanded: _isExpanded[orderHash] ?? false,
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text('Order #${orderHash.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy HH:mm').format(timestamp)} - ₹${order['totalCost'].toStringAsFixed(2)}',
                      ),
                      Text(
                        'User: ${order['userEmail']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.circle,
                    color: statusColor,
                    size: 12,
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${order['status'].toUpperCase()}'),
                    const SizedBox(height: 8),
                    const Text('Items:'),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text('• $item'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Total Cost: ₹${order['totalCost'].toStringAsFixed(2)}'),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
