import 'package:flutter/material.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/database/gate_pass_db.dart' as gate_pass_db;
import 'package:intl/intl.dart';

class MyPassesSheet extends StatefulWidget {
  const MyPassesSheet({super.key});

  @override
  State<MyPassesSheet> createState() => _MyPassesSheetState();
}

class _MyPassesSheetState extends State<MyPassesSheet> {
  List<Map<String, dynamic>> _passes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPasses();
  }

  Future<void> _loadPasses() async {
    try {
      final session = await account.get();
      final passes = await gate_pass_db.getPassesByEmail(session.email);

      // Sort by request date, newest first
      passes.sort((a, b) => DateTime.parse(b['requestDate'])
          .compareTo(DateTime.parse(a['requestDate'])));

      setState(() {
        _passes = passes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading passes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  DateTime parseFlexibleDate(String dateStr) {
    // Try parsing as yyyy-MM-dd
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      // Try parsing as dd/MM/yyyy
      try {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
        }
      } catch (_) {
        // If all parsing fails, return current date
        return DateTime.now();
      }
    }
    return DateTime.now(); // Fallback
  }

  String formatDisplayDate(String dateStr) {
    try {
      final date = parseFlexibleDate(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr; // Return original string if formatting fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'My Gate Passes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _passes.length,
                      itemBuilder: (context, index) {
                        final pass = _passes[index];
                        final status = pass['status'] as String;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: status == 'approved'
                                  ? Colors.green
                                  : status == 'rejected'
                                      ? Colors.red
                                      : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      formatDisplayDate(pass['date']),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == 'approved'
                                            ? Colors.green.withOpacity(0.1)
                                            : status == 'rejected'
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.orange
                                                    .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: status == 'approved'
                                              ? Colors.green
                                              : status == 'rejected'
                                                  ? Colors.red
                                                  : Colors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pass['reason'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${pass['timeFrom']} - ${pass['timeTo']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (status == 'rejected' &&
                                    pass['rejectedBy'] != null &&
                                    (pass['rejectedBy'] as List)
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rejected by: ${(pass['rejectedBy'] as List).first}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (status == 'pending' &&
                                    pass['approvalsRequired'] != null) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Waiting for approval from: ${(pass['approvalsRequired'] as List).join(", ")}',
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
