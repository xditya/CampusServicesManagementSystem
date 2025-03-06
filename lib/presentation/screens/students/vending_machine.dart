import 'package:csms/helper/database/vending_db.dart';
import 'package:csms/presentation/screens/common/success_animation.dart';
import 'package:flutter/material.dart';
import 'package:csms/presentation/providers/vending_provider.dart';
import 'package:csms/helper/data/vending_items.dart';
import 'package:provider/provider.dart';
import 'package:csms/helper/database/db_service.dart';

class VendingMachineScreen extends StatelessWidget {
  const VendingMachineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VendingProvider(VendingDB(DBService().db))
        ..loadWalletBalance()
        ..loadOrders(),
      child: const VendingMachineView(),
    );
  }
}

class VendingMachineView extends StatelessWidget {
  const VendingMachineView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vending Machine'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/my-orders'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.receipt_long),
                            const SizedBox(width: 8),
                            Text(
                              'My Orders',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wallet),
                        const SizedBox(width: 8),
                        Text(
                          '₹${provider.walletBalance.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: vendingItems.length,
        itemBuilder: (context, index) {
          final item = vendingItems[index];
          final quantity = provider.selectedItems[item.id] ?? 0;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(item.icon,
                          size: 48,
                          color: isDark
                              ? Colors.white
                              : Theme.of(context).primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '₹${item.price}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: quantity > 0
                            ? () => provider.updateQuantity(item.id, -1)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () => provider.updateQuantity(item.id, 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const VendingMachineBottomBar(),
    );
  }
}

class VendingMachineBottomBar extends StatelessWidget {
  const VendingMachineBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendingProvider>();
    final hasItems = provider.selectedItems.isNotEmpty;

    return BottomAppBar(
      height: 95,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Text(
                        'Total Items: ${provider.selectedItems.values.fold(0, (a, b) => a + b)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Text(
                        '₹${provider.totalCost.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: hasItems ? () => _showConfirmDialog(context) : null,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    final provider = context.read<VendingProvider>();

    // Check balance before showing confirmation
    if (provider.totalCost > provider.walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. You need ₹${(provider.totalCost - provider.walletBalance).toStringAsFixed(2)} more to place this order.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Add Money',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to add money screen if you have one
              // Navigator.pushNamed(context, '/add-money');
            },
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm Order',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...provider.selectedItems.entries.map((entry) {
              final item = vendingItems.firstWhere((i) => i.id == entry.key);
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.name),
                trailing: Text('${entry.value}x ₹${item.price * entry.value}'),
              );
            }),
            const Divider(),
            ListTile(
              title: const Text('Total'),
              trailing: Text(
                '₹${provider.totalCost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(bottomSheetContext); // Close bottom sheet
                    try {
                      await provider.processPurchase();
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SuccessAnimationScreen(
                              title: 'Order Placed Successfully',
                              message: 'Your order has been confirmed',
                              onBackPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/vending-machine');
                              },
                            ),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
