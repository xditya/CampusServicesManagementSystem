import 'package:csms/helper/config.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                      const Text('You are not logged in'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final sections = [
              {
                'title': 'Printer Automation',
                'cards': [
                  {
                    'title': 'Printer',
                    'icon': Icons.print,
                    'route': '/printer',
                    'description':
                        'Access and manage printer settings and queue',
                  },
                ],
              },
              {
                'title': 'College Slips',
                'cards': [
                  {
                    'title': 'Pink Slip',
                    'icon': Icons.description,
                    'route': '/pink-slip',
                    'description':
                        'Generate and manage pink slips for various purposes',
                  },
                  {
                    'title': 'Gate Pass',
                    'icon': Icons.door_sliding,
                    'route': '/gate-pass',
                    'description': 'Create and view gate passes for entry/exit',
                  },
                  {
                    'title': '3D Printing',
                    'icon': Icons.print,
                    'route': '/3d-printing',
                    'description': 'Submit and track 3D printing requests',
                  },
                  {
                    'title': 'Vehicle Pass',
                    'icon': Icons.directions_car,
                    'route': '/vehicle-pass',
                    'description':
                        'Apply for and manage vehicle parking passes',
                  },
                  {
                    'title': 'Lost ID Card',
                    'icon': Icons.credit_card,
                    'route': '/lost-id-card',
                    'description':
                        'Report lost ID cards and request replacements',
                  },
                  {
                    'title': 'Lab Permission',
                    'icon': Icons.science,
                    'route': '/lab-permission',
                    'description': 'Request and view lab access permissions',
                  },
                  {
                    'title': 'Leave Form',
                    'icon': Icons.book,
                    'route': '/leave-form',
                    'description': 'Leave Form for students',
                  },
                ],
              },
              {
                'title': 'Vending Machine',
                'cards': [
                  {
                    'title': 'Buy',
                    'icon': Icons.local_cafe,
                    'route': '/vending-machine',
                    'description': 'Purchase items from the vending machine',
                  },
                ],
              },
            ];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Dashboard'),
                centerTitle: true,
              ),
              bottomNavigationBar: const BottomNavBar(),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections.map((section) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: (section['cards'] as List).length,
                              itemBuilder: (context, index) {
                                final card = (section['cards'] as List)[index];
                                return Card(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, card['route'] as String);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            card['icon'] as IconData,
                                            size: 48,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(height: 16),
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
                                          const SizedBox(height: 8),
                                          Text(
                                            card['description'] as String,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        });
  }
}
