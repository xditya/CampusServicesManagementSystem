import 'package:csms/helper/database/db_service.dart';
import 'package:csms/helper/database/vending_db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csms/presentation/providers/vending_provider.dart';
import 'package:csms/helper/vending_items.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VendingProvider(VendingDB(DBService().db))..loadOrders(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: Consumer<VendingProvider>(
          builder: (context, provider, _) {
            if (provider.orders.isEmpty) {
              return const Center(
                child: Text('No orders yet'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                // Convert the items map to a list of item names
                final itemsList = order.items.entries.map((entry) {
                  final item =
                      vendingItems.firstWhere((item) => item.id == entry.key);
                  return '${item.name} x${entry.value}';
                }).toList();

                final status = order.status;
                final isActive = status == 'Placed';
                final isCancelled = status == 'Cancelled';
                final total = order.total;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isActive
                          ? Colors.green
                          : isCancelled
                              ? Colors.red
                              : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _showOrderDetails(context, {
                      'items': itemsList,
                      'total': total,
                      'status': status,
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.green
                                          : isCancelled
                                              ? Colors.red
                                              : Colors.grey,
                                    ),
                              ),
                              Chip(
                                label: Text(status),
                                backgroundColor: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : isCancelled
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                side: BorderSide(
                                  color: isActive
                                      ? Colors.green
                                      : isCancelled
                                          ? Colors.red
                                          : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            itemsList.join(', '),
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final items = (order['items'] as List<String>);
    final total = order['total'] as num;
    final status = order['status'] as String;

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => ListTile(
                title: Text(item),
                leading: Icon(
                  vendingItems
                      .firstWhere(
                        (vItem) => item.startsWith(vItem.name),
                        orElse: () => vendingItems.first,
                      )
                      .icon,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Total'),
              trailing: Text(
                '₹${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              title: const Text('Status'),
              trailing: Chip(
                label: Text(status),
                backgroundColor: status == 'Placed'
                    ? Colors.green.withOpacity(0.1)
                    : status == 'Cancelled'
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                side: BorderSide(
                  color: status == 'Placed'
                      ? Colors.green
                      : status == 'Cancelled'
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
