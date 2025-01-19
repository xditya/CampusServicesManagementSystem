import 'package:flutter/material.dart';
import '../../services/print_service.dart';
import '../../models/print_request.dart';
import '../../helper/config.dart';

class MyPrintsScreen extends StatelessWidget {
  const MyPrintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Print Requests'),
      ),
      body: FutureBuilder(
        future: account.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final session = snapshot.data;
            if (session == null) {
              return const Center(
                child: Text('Please login to view your print requests'),
              );
            }

            return FutureBuilder<List<PrintRequest>>(
              future: PrintService().getUserPrintRequests(session.email),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return const Center(
                    child: Text('No print requests yet'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final isActive = request.status == 'pending';
                    final isCompleted = request.status == 'completed';

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isActive
                              ? Colors.blue
                              : isCompleted
                                  ? Colors.green
                                  : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _showPrintDetails(context, request),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${request.totalCost.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? Colors.blue
                                              : isCompleted
                                                  ? Colors.green
                                                  : Colors.grey,
                                        ),
                                  ),
                                  Chip(
                                    label: Text(request.status),
                                    backgroundColor: isActive
                                        ? Colors.blue.withOpacity(0.1)
                                        : isCompleted
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                    side: BorderSide(
                                      color: isActive
                                          ? Colors.blue
                                          : isCompleted
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                request.processName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                request.fileName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showPrintDetails(BuildContext context, PrintRequest request) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Print Request Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Process Name'),
              subtitle: Text(request.processName),
            ),
            ListTile(
              title: const Text('File Name'),
              subtitle: Text(request.fileName),
            ),
            ListTile(
              title: const Text('Pages'),
              trailing: Text('${request.numberOfPages}'),
            ),
            ListTile(
              title: const Text('Copies'),
              trailing: Text('${request.numberOfCopies}'),
            ),
            ListTile(
              title: const Text('Print Type'),
              trailing: Text(request.isColorPrint ? 'Color' : 'Black & White'),
            ),
            ListTile(
              title: const Text('Print Side'),
              trailing:
                  Text(request.isDoubleSided ? 'Double Sided' : 'Single Sided'),
            ),
            ListTile(
              title: const Text('Total Cost'),
              trailing: Text('₹${request.totalCost.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Status'),
              trailing: Chip(
                label: Text(request.status),
                backgroundColor: request.status == 'pending'
                    ? Colors.blue.withOpacity(0.1)
                    : request.status == 'completed'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
