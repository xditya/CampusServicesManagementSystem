import 'package:csms/helper/database/db_service.dart';
import 'package:csms/helper/database/vending_db.dart';
import 'package:csms/helper/data/vending_items.dart';
import 'package:csms/presentation/widgets/bottom_navbar_vending.dart';
import 'package:flutter/material.dart';

class VendingDashboard extends StatefulWidget {
  const VendingDashboard({super.key});

  @override
  State<VendingDashboard> createState() => _VendingDashboardState();
}

class _VendingDashboardState extends State<VendingDashboard> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  final VendingDB _vendingDB = VendingDB(DBService().db);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _vendingDB.getAllOrders();
      setState(() {
        _orders = orders;
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

  Map<String, int> _calculatePendingItems() {
    Map<String, int> pendingItems = {};

    // Get only pending orders
    final activeOrders = _orders.where((order) => order['status'] == 'Placed');

    // Sum up quantities for each item
    for (var order in activeOrders) {
      final items = order['items'] as Map<String, dynamic>;
      items.forEach((itemId, quantity) {
        pendingItems[itemId] = (pendingItems[itemId] ?? 0) + (quantity as int);
      });
    }

    return pendingItems;
  }

  void _showItemDetails(VendingItem item, int pendingCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₹${item.price.toStringAsFixed(2)}'),
            if (pendingCount > 0) ...[
              const SizedBox(height: 8),
              Text('Pending Orders: $pendingCount'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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

    // Calculate order statistics
    final pendingOrders =
        _orders.where((order) => order['status'] == 'Placed').length;
    final completedOrders = _orders
        .where((order) =>
            order['status'] == 'Completed' || order['status'] == 'Done')
        .length;
    final totalRevenue = _orders
        .where((order) =>
            order['status'] == 'Completed' || order['status'] == 'Done')
        .fold(0.0, (sum, order) => sum + (order['totalCost'] as num));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vending Dashboard'),
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
                // Statistics Cards
                _buildStatisticsSection(
                    pendingOrders, completedOrders, totalRevenue),
                const SizedBox(height: 24),

                // Available Items Section
                const Text(
                  'Available Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildItemsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(int pending, int completed, double revenue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Pending Orders',
                  pending.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Completed',
                  completed.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatCard(
                  'Revenue',
                  '₹${revenue.toStringAsFixed(2)}',
                  Icons.currency_rupee,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsGrid() {
    final pendingItems = _calculatePendingItems();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: vendingItems.length,
      itemBuilder: (context, index) {
        final item = vendingItems[index];
        final pendingCount = pendingItems[item.id] ?? 0;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Card(
          child: InkWell(
            onTap: () => _showItemDetails(item, pendingCount),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    12.0,
                    pendingCount > 0 ? 20.0 : 12.0,
                    12.0,
                    12.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        item.icon,
                        size: 40,
                        color: isDark
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (pendingCount > 0) ...[
                        const SizedBox(height: 8),
                        FittedBox(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$pendingCount in pending orders',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (pendingCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        pendingCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
