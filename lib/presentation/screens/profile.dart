import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/getRegisterId.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildHeader(BuildContext context, dynamic session) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'profile_picture',
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    '${session.name.split(' ').first[0]}${session.name.split(' ').last[0]}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              session.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required BuildContext context,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: account.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final session = snapshot.data;
          return Scaffold(
            body: Column(
              children: [
                _buildHeader(context, session),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildInfoCard(
                        title: 'Email',
                        value: session!.email,
                        icon: Icons.email,
                        context: context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        title: 'Registration Number',
                        value: getRegisterIdFromEmail(session.email),
                        icon: Icons.assignment_ind,
                        context: context,
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ],
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
