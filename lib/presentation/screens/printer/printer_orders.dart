import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../helper/config.dart';
import '../../../helper/database/db_service.dart';
import '../../../models/print_request.dart';
import '../../../services/print_service.dart';
import '../../widgets/bottom_navbar_printer.dart';
import '../../screens/printer/print_order_details.dart';

class PrinterOrders extends StatefulWidget {
  const PrinterOrders({super.key});

  @override
  State<PrinterOrders> createState() => _PrinterOrdersState();
}

class _PrinterOrdersState extends State<PrinterOrders> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final printService = PrintService();
      final allOrders = await printService.getAllPrintRequests();

      setState(() {
        _orders = allOrders;
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
        _orders.where((order) => order['status'] == 'pending').toList();
    final completedOrders =
        _orders.where((order) => order['status'] == 'completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarPrinter(),
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
                    'Pending Orders', pendingOrders, Colors.blue),
                const SizedBox(height: 20),
                _buildOrderSection(
                    'Completed Orders', completedOrders, Colors.green),
                if (_orders.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No print orders found'),
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ordersList.length,
          itemBuilder: (context, index) {
            final order = ordersList[index];
            final orderId = order['_id'].toString();
            final request = PrintRequest.fromJson(order);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(request.processName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderId.substring(0, 8)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Email: $orderId',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: Text(
                  '₹${request.totalCost.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                leading: Icon(
                  Icons.circle,
                  color: statusColor,
                  size: 12,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrintOrderDetails(
                        orderId: orderId,
                        userEmail: orderId,
                        request: request,
                      ),
                    ),
                  ).then((_) => _loadOrders());
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final printService = PrintService();
      await printService.updatePrintRequestStatus(orderId, status);
      await _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
