import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setCurrentPageIndex();
  }

  void _setCurrentPageIndex() {
    final routeName = ModalRoute.of(context)?.settings.name;
    switch (routeName) {
      case '/':
        currentPageIndex = 0;
        break;
      case '/wallet':
        currentPageIndex = 1;
        break;
      case '/profile':
        currentPageIndex = 2;
        break;
      default:
        currentPageIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const items = <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: 'Wallet',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
    return NavigationBar(
        destinations: items,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) {
          _navigateToPage(context, index);
        });
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/wallet');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }
}
