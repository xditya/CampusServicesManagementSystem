import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/balance_db.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Future<Map<String, dynamic>> _loadWalletData() async {
    final session = await account.get();

    final results = await Future.wait([
      getBalance(session.email),
      getTransactions(session.email),
    ]);

    return {
      'session': session,
      'balance': results[0],
      'transactions': results[1],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNavBar(),
      body: FutureBuilder(
        future: _loadWalletData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          final data = snapshot.data!;
          final session = data['session'];

          if (session == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You are not logged in'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          return _buildLoadedState(context, data);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet, size: 32),
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
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 40,
                      width: 150,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add Balance',
                        style: TextStyle(fontSize: 16),
                      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        for (var i = 0; i < 5; i++) ...[
                          _buildShimmerTransactionItem(),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTransactionItem() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 80,
                color: Colors.white,
              ),
            ],
          ),
        ),
        Container(
          height: 16,
          width: 60,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildLoadedState(BuildContext context, Map<String, dynamic> data) {
    final balance = data['balance'] ?? 0;
    final transactions = data['transactions'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildBalanceCard(context, balance),
          const SizedBox(height: 16),
          _buildTransactionsCard(transactions),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 32),
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
              "₹$balance",
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
                onPressed: () => Navigator.pushNamed(context, '/add-balance'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard(List<dynamic>? transactions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            if (transactions == null || transactions.isEmpty)
              const Center(child: Text('No transactions found')),
            for (var transaction in transactions ?? [])
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
    );
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
