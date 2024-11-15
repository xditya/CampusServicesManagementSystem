import 'package:flutter/material.dart';

class BottomNavBarAdmin extends StatefulWidget {
  const BottomNavBarAdmin({super.key});

  @override
  BottomNavBarAdminState createState() => BottomNavBarAdminState();
}

class BottomNavBarAdminState extends State<BottomNavBarAdmin> {
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
      case '/admin':
        currentPageIndex = 0;
        break;
      case '/profile':
        currentPageIndex = 1;
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
        label: 'Admin Dashboard',
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (route) => false);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
    }
  }
}
