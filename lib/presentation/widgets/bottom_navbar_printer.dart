import 'package:flutter/material.dart';

class BottomNavBarPrinter extends StatelessWidget {
  const BottomNavBarPrinter({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return NavigationBar(
      selectedIndex: _getSelectedIndex(currentRoute),
      onDestinationSelected: (index) {
        if (index != _getSelectedIndex(currentRoute)) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/printer-orders');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.print),
          label: 'Print Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _getSelectedIndex(String currentRoute) {
    switch (currentRoute) {
      case '/printer-orders':
        return 0;
      case '/profile':
        return 1;
      default:
        return 0;
    }
  }
}
