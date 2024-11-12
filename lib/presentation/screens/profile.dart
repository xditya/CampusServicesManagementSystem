import 'package:csms/helper/config.dart';
import 'package:csms/helper/getRegisterId.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget buildProfilePicture(session) {
    final firstNameInitial = session.name.split(' ').first[0];
    final lastNameInitial = session.name.split(' ').last[0];
    return CircleAvatar(
      radius: 50,
      backgroundColor: const Color.fromARGB(255, 168, 169, 169),
      child: Text(
        '$firstNameInitial$lastNameInitial',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    // return CircleAvatar(
    //   radius: 50,
    //   backgroundImage: NetworkImage(userAvatarUrl),
    //   backgroundColor: Colors.transparent,
    // );
  }

  Widget buildProfileCard(session) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            buildProfilePicture(session),
            const SizedBox(height: 16),
            Text(
              session.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.email, color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text(
                session.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              )
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_ind, color: Colors.grey, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Registration Number: ${getRegisterIdFromEmail(session.email)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(Icons.settings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: account.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildProfileCard(snapshot.data),
                    const SizedBox(height: 24),
                    buildSettingsButton(context),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavBar(),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
