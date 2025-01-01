import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/balance_db.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final TextEditingController _amountController = TextEditingController();
  double currentBalance = 0.0;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout(double amount, String email) {
    var options = {
      'key': RAZORPAY_API_KEY,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Add Balance',
      'description': 'Adding balance to wallet',
      'prefill': {'email': email},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final amount = double.tryParse(_amountController.text) ?? 0;

    setState(() {
      currentBalance += amount;
      _amountController.clear();
    });

    var session = await account.get();
    await updateBalance(session.email, amount, 'credit');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popAndPushNamed(context, '/wallet');
    }
    debugPrint('Payment Success: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

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
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final balance = snapshot.data;
                    if (balance == null) {
                      return Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Failed to fetch balance'),
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
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Add Balance'),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Current Balance: ₹${balance.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Enter Amount',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.money),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                final amount =
                                    double.tryParse(_amountController.text) ??
                                        0;
                                if (amount > 0) {
                                  openCheckout(amount, session.email);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please enter a valid amount'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.navigate_next_outlined),
                              label: const Text('Proceed to payment'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                });
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
