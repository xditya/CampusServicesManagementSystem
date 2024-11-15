import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: BottomNavBarAdmin(),
      body: Center(
        child: Text('Admin Dashboard'),
      ),
    );
  }
}
