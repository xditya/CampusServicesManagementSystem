import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/balance_db.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: account.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final session = snapshot.data;
            if (session == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('You are not logged in'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return FutureBuilder(
                future: getBalance(session.email),
                builder: (context, balanceSnapshot) {
                  if (balanceSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return FutureBuilder(
                      future: getTransactions(session.email),
                      builder: (context, transactionsSnapshot) {
                        if (transactionsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final bal = balanceSnapshot.data ?? 0;
                        final transactions = transactionsSnapshot.data;

                        return Scaffold(
                          appBar: AppBar(
                            title: const Text('Wallet'),
                            centerTitle: true,
                          ),
                          bottomNavigationBar: const BottomNavBar(),
                          body: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.account_balance_wallet,
                                                size: 32),
                                            SizedBox(width: 12),
                                            Text(
                                              'Wallet Balance',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "₹$bal",
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(16),
                                            ),
                                            icon: const Icon(Icons.add),
                                            label: const Text(
                                              'Add Balance',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/add-balance');
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.history),
                                            SizedBox(width: 8),
                                            Text(
                                              'Transaction History',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (transactions == null ||
                                            transactions.isEmpty)
                                          const Center(
                                            child:
                                                Text('No transactions found'),
                                          ),
                                        for (var transaction
                                            in transactions ?? [])
                                          _buildTransactionItem(
                                            icon: getIcon(transaction['type']),
                                            type: transaction['type'],
                                            time: transaction['date'],
                                            amount: transaction['amount'] > 0
                                                ? '₹${transaction['amount'].abs()}'
                                                : '-₹${transaction['amount'].abs()}',
                                            isCredit: transaction['amount'] > 0,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                });
          }
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        });
  }
}

IconData getIcon(String type) {
  if (type == "print") {
    return Icons.print;
  } else if (type == "slip") {
    return Icons.card_giftcard;
  }
  return Icons.add_circle;
}

Widget _buildTransactionItem({
  required IconData icon,
  required String type,
  required String time,
  required String amount,
  required bool isCredit,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCredit
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
      ],
    ),
  );
}
