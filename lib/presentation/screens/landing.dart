import 'package:csms/helper/config.dart';
import 'package:csms/helper/navigate_users.dart';
import 'package:csms/presentation/screens/login.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: account.get().then((snapshot) => snapshot),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || (snapshot.data != null)) {
          return const LoginScreen();
        }
        naviagateUsers(context, snapshot.data!);
        return Container();
      },
    );
  }
}
