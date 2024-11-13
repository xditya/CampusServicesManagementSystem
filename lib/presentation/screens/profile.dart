import 'package:csms/helper/config.dart';
import 'package:csms/helper/getRegisterId.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget buildProfilePicture(BuildContext context, session) {
    final firstNameInitial = session.name.split(' ').first[0];
    final lastNameInitial = session.name.split(' ').last[0];
    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: Text(
        '$firstNameInitial$lastNameInitial',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget buildProfileCard(session, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            buildProfilePicture(context, session),
            const SizedBox(height: 16),
            Text(
              session.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.email, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 4),
              Text(
                session.email,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_ind,
                    color: colorScheme.secondary, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Registration Number: ${getRegisterIdFromEmail(session.email)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
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
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildProfileCard(snapshot.data, context),
                    const SizedBox(height: 24),
                    buildSettingsButton(context),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavBar(),
          );
        }

        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
