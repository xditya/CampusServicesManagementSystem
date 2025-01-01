import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showDescription(BuildContext context, Map<String, dynamic> card) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  card['icon'] as IconData,
                  color: card['color'] as Color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    card['title'] as String,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              card['description'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, card['route'] as String);
                },
                child: const Text('Open'),
              ),
            ),
          ],
        ),
      ),
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: account.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final session = snapshot.data;

          if (session == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to CSMS',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please login to continue',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sections = [
            {
              'title': 'Quick Actions',
              'icon': Icons.flash_on,
              'cards': [
                {
                  'title': 'Printer',
                  'icon': Icons.print,
                  'route': '/printer',
                  'description':
                      'Access and manage printer settings and queue. Submit print jobs, check status, and manage your printing credits all in one place.',
                  'color': Colors.blue,
                },
                {
                  'title': 'Order Food',
                  'icon': Icons.local_cafe,
                  'route': '/vending-machine',
                  'description':
                      'Purchase lunch from the vending machine. View available items, check prices, and make quick purchases using your account balance.',
                  'color': Colors.orange,
                },
              ],
            },
            {
              'title': 'College Services',
              'icon': Icons.school,
              'cards': [
                {
                  'title': 'Pink Slip',
                  'icon': Icons.description,
                  'route': '/pink-slip',
                  'description':
                      'Generate and manage pink slips for various purposes. Track your submissions and view approval status in real-time.',
                  'color': Colors.pink,
                },
                {
                  'title': 'Gate Pass',
                  'icon': Icons.door_sliding,
                  'route': '/gate-pass',
                  'description':
                      'Create and manage gate passes for entry/exit. Get quick approval for leaving campus during college hours.',
                  'color': Colors.green,
                },
                {
                  'title': '3D Printing',
                  'icon': Icons.print,
                  'route': '/3d-printing',
                  'description':
                      'Submit and track 3D printing requests. Upload your designs, choose materials, and monitor printing progress.',
                  'color': Colors.purple,
                },
                {
                  'title': 'Vehicle Pass',
                  'icon': Icons.directions_car,
                  'route': '/vehicle-pass',
                  'description':
                      'Apply for and manage vehicle parking passes. Register your vehicle and get authorized parking access on campus.',
                  'color': Colors.indigo,
                },
              ],
            },
            {
              'title': 'Student Support',
              'icon': Icons.support_agent,
              'cards': [
                {
                  'title': 'Lost ID Card',
                  'icon': Icons.credit_card,
                  'route': '/lost-id-card',
                  'description':
                      'Report lost ID cards and request replacements. Get temporary passes while your new card is being processed.',
                  'color': Colors.red,
                },
                {
                  'title': 'Lab Permission',
                  'icon': Icons.science,
                  'route': '/lab-permission',
                  'description':
                      'Request and track lab access permissions. Get authorized access to specialized labs and equipment.',
                  'color': Colors.teal,
                },
                {
                  'title': 'Leave Form',
                  'icon': Icons.book,
                  'route': '/leave-form',
                  'description':
                      'Submit and track leave applications. Apply for different types of leaves and check approval status.',
                  'color': Colors.amber,
                },
              ],
            },
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 2,
            ),
            bottomNavigationBar: const BottomNavBar(),
            body: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = sections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            section['icon'] as IconData,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            section['title'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: (section['cards'] as List).length,
                        itemBuilder: (context, cardIndex) {
                          final card = (section['cards'] as List)[cardIndex];
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.all(8),
                            child: Card(
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  card['route'] as String,
                                ),
                                onLongPress: () =>
                                    _showDescription(context, card),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: (card['color'] as Color)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          card['icon'] as IconData,
                                          color: card['color'] as Color,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        card['title'] as String,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Hold to learn more',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                              fontSize: 10,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (sectionIndex < sections.length - 1)
                      const SizedBox(height: 8),
                  ],
                );
              },
            ),
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
