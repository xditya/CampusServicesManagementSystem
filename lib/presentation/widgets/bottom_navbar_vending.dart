import 'package:flutter/material.dart';

class BottomNavBarVending extends StatefulWidget {
  const BottomNavBarVending({super.key});

  @override
  BottomNavBarVendingState createState() => BottomNavBarVendingState();
}

class BottomNavBarVendingState extends State<BottomNavBarVending> {
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
      case '/vending-dashboard':
        currentPageIndex = 0;
        break;
      case '/vending-orders':
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
        label: 'Vending Dashboard',
      ),
      NavigationDestination(
          icon: Icon(Icons.list_outlined),
          selectedIcon: Icon(Icons.list),
          label: "Orders"),
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/vending-dashboard', (route) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
            context, '/vending-orders', (route) => false);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(
            context, '/vending-dashboard', (route) => false);
    }
  }
}
