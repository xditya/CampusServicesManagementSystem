import 'package:csms/presentation/widgets/bottom_navbar_vending.dart';
import 'package:flutter/material.dart';

class VendingDashboard extends StatefulWidget {
  const VendingDashboard({super.key});

  @override
  State<VendingDashboard> createState() => _VendingDashboardState();
}

class _VendingDashboardState extends State<VendingDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: BottomNavBarVending(),
      body: Center(
        child: Text('Vending Dashboard'),
      ),
    );
  }
}
