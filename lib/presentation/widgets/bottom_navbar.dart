import 'package:csms/presentation/screens/dashboard.dart';
import 'package:csms/presentation/screens/profile.dart';
import 'package:csms/presentation/screens/wallet.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          if (index == 0 && currentPageIndex != 0) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const DashboardScreen()));
          } else if (index == 1 && currentPageIndex != 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const WalletScreen()));
          } else if (index == 2 && currentPageIndex != 2) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
          } else {
            currentPageIndex = index;
          }
        });
      },
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.account_balance_wallet),
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Wallet',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.person),
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }
}
