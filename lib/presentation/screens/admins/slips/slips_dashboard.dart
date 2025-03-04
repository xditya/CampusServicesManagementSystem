import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/gate_pass_db.dart' as gate_pass_db;
import 'package:csms/helper/database/pink_slip_db.dart' as pink_slip_db;
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:flutter/material.dart';

class SlipsDashboardScreen extends StatefulWidget {
  const SlipsDashboardScreen({super.key});

  @override
  State<SlipsDashboardScreen> createState() => _SlipsDashboardScreenState();
}

class _SlipsDashboardScreenState extends State<SlipsDashboardScreen> {
  bool _isLoading = true;
  int _pendingGatePasses = 0;
  int _pendingPinkSlips = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      setState(() => _isLoading = true);
      final session = await account.get();

      // Get gate pass counts
      final passes = await gate_pass_db.getPassesForApproval(session.email);
      final pendingPassCount = passes
          .where((pass) =>
              pass['status'] == 'pending' &&
              !(pass['approvedBy'] as List).contains(session.email) &&
              !(pass['rejectedBy'] as List).contains(session.email))
          .length;

      // Get pink slip counts
      final slips = await pink_slip_db.getSlipsForApproval(session.email);
      final pendingSlipCount = slips
          .where((slip) =>
              slip['status'] == 'pending' &&
              !(slip['approvedBy'] as List).contains(session.email) &&
              !(slip['rejectedBy'] as List).contains(session.email))
          .length;

      setState(() {
        _pendingGatePasses = pendingPassCount;
        _pendingPinkSlips = pendingSlipCount;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading counts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

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
                child: const Text('View Requests'),
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
    final sections = [
      {
        'title': 'Permission Slips',
        'icon': Icons.description,
        'cards': [
          {
            'title': 'Pink Slips',
            'icon': Icons.description,
            'route': '/admin/pink-slips',
            'description':
                'View and manage pink slip requests. Approve or reject requests, add comments, and track request history.',
            'color': Colors.pink,
            'count': _pendingPinkSlips,
          },
          {
            'title': 'Gate Passes',
            'icon': Icons.door_sliding,
            'route': '/admin/gate-passes',
            'description':
                'Review gate pass applications. Monitor entry/exit requests and manage approvals.',
            'color': Colors.green,
            'count': _pendingGatePasses,
          },
          {
            'title': 'Lab Access',
            'icon': Icons.science,
            'route': '/admin/lab-permissions',
            'description':
                'Handle lab access permission requests. Review and grant access to department labs.',
            'color': Colors.teal,
            'count': 2,
          },
        ],
      },
      {
        'title': 'Leave Management',
        'icon': Icons.event_busy,
        'cards': [
          {
            'title': 'Leave Forms',
            'icon': Icons.book,
            'route': '/admin/leave-forms',
            'description':
                'Process student leave applications. Review reasons, dates, and manage approvals.',
            'color': Colors.amber,
            'count': 8,
          },
        ],
      },
      {
        'title': 'ID Card Requests',
        'icon': Icons.badge,
        'cards': [
          {
            'title': 'Lost ID Cards',
            'icon': Icons.credit_card,
            'route': '/admin/id-requests',
            'description':
                'Process new ID card requests. Verify payments and manage card issuance.',
            'color': Colors.red,
            'count': 4,
          },
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slips Dashboard'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      bottomNavigationBar: const BottomNavBarAdmin(),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          onLongPress: () => _showDescription(context, card),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: (card['color'] as Color)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
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
                              if (card['count'] != null && card['count'] > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      card['count'].toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onError,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (sectionIndex < sections.length - 1) const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
