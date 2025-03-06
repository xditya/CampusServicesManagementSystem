import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showPassDetails(BuildContext context, Map<String, dynamic> pass) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            pass['name'] ?? pass['studentName'] ?? 'Student',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (pass["rollNo"] != null) _buildInfoRow('Roll No', pass['rollNo']),
          if (pass['branch'] != null && pass['class'] != null)
            _buildInfoRow(
                'Branch & Class', '${pass['branch']} - ${pass['class']}'),
          if (pass['batch'] != null) _buildInfoRow('Batch', pass['batch']),
          if (pass['date'] != null) _buildInfoRow('Date', pass['date']),
          if (pass['dateFrom'] != null && pass['dateTo'] != null)
            _buildInfoRow(
                'Date Range', '${pass['dateFrom']} to ${pass['dateTo']}'),
          if (pass["lab"] != null) _buildInfoRow('Lab', pass['lab']),
          if (pass["timeFrom"] != null && pass["timeTo"] != null)
            _buildInfoRow('Time', '${pass['timeFrom']} - ${pass['timeTo']}'),
          if (pass["reason"] != null) _buildInfoRow('Reason', pass['reason']),
          if (pass["purpose"] != null)
            _buildInfoRow('Purpose', pass['purpose']),
          if (pass["requestDate"] != null)
            _buildInfoRow(
              'Request Date',
              DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(pass['requestDate'])),
            ),
          if (pass['createdAt'] != null)
            _buildInfoRow(
              'Created At',
              DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(pass['createdAt'])),
            ),
          const Divider(height: 32),
          if ((pass['approvedBy'] as List).isNotEmpty) ...[
            const Text(
              'Approved by:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(pass['approvedBy'] as List).map(
              (email) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(email),
                  ],
                ),
              ),
            ),
          ],
          if ((pass['rejectedBy'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Rejected by:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(pass['rejectedBy'] as List).map(
              (email) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(email),
                  ],
                ),
              ),
            ),
          ],
          if ((pass['approvalsRequired'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Pending approvals from:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(pass['approvalsRequired'] as List).map(
              (email) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(email),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
