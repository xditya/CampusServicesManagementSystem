import 'package:csms/helper/choose_navbar.dart';
import 'package:csms/helper/config.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            return Scaffold(
              bottomNavigationBar: chooseNavBar(session),
              body: const Center(
                child: Text('Dashboard'),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        });
  }
}
