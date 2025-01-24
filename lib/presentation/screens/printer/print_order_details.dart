import 'package:csms/services/websocket_service.dart';
import 'package:flutter/material.dart';
import '../../../models/print_request.dart';
import '../../../services/print_service.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:bson/bson.dart';
import 'dart:convert';

class PrintOrderDetails extends StatelessWidget {
  final String orderId;
  final String userEmail;
  final PrintRequest request;

  const PrintOrderDetails({
    super.key,
    required this.orderId,
    required this.userEmail,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${orderId.substring(0, 8)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildInfoRow('User Email:', userEmail),
            _buildInfoRow('Process Name:', request.processName),
            _buildInfoRow('File Name:', request.fileName),
            _buildInfoRow('Date:',
                DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt)),
            _buildInfoRow('Pages:', request.numberOfPages.toString()),
            _buildInfoRow('Copies:', request.numberOfCopies.toString()),
            _buildInfoRow('Print Type:',
                request.isColorPrint ? 'Color' : 'Black & White'),
            _buildInfoRow('Print Side:',
                request.isDoubleSided ? 'Double Sided' : 'Single Sided'),
            _buildInfoRow(
                'Total Cost:', '₹${request.totalCost.toStringAsFixed(2)}'),
            _buildInfoRow('Status:', request.status.toUpperCase()),
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _downloadFile(context),
          icon: const Icon(Icons.file_download),
          label: const Text('Download File'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        if (request.status == 'pending')
          ElevatedButton.icon(
            onPressed: () => _showCompleteConfirmation(context),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'Mark as Completed',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final printService = PrintService();

      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 16),
                Text('Downloading file...'),
              ],
            ),
            duration: Duration(seconds: 15), // Longer duration for large files
            backgroundColor: Colors.blue,
          ),
        );
      }

      // Get the pending request to access file data
      final pendingRequest = await printService.getPendingRequest(userEmail);
      final fileBytes = (pendingRequest['fileBytes'] as BsonBinary).byteList;
      final fileName = pendingRequest['fileName'] as String;

      // Get file extension
      final extension = fileName.split('.').last.toLowerCase();

      // Determine mime type
      MimeType mimeType;
      switch (extension) {
        case 'pdf':
          mimeType = MimeType.pdf;
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = MimeType.jpeg;
          break;
        case 'png':
          mimeType = MimeType.png;
          break;
        default:
          mimeType = MimeType.other;
      }

      // Save file
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(fileBytes),
        mimeType: mimeType,
        ext: extension,
      );

      if (context.mounted) {
        // Clear the loading snackbar
        ScaffoldMessenger.of(context).clearSnackBars();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Clear the loading snackbar
        ScaffoldMessenger.of(context).clearSnackBars();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCompleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: const Text(
            'Are you sure you want to mark this order as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _completeOrder(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOrder(BuildContext context) async {
    try {
      final printService = PrintService();
      await printService.updatePrintRequestStatus(orderId, 'completed');

      // Send WebSocket notification with process name
      WebSocketService().sendMessage(
        json.encode({
          'type': 'print_completed',
          'userEmail': userEmail,
          'message':
              'Your print request "${request.processName}" has been completed',
        }),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to orders list
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
