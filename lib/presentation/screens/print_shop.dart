import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:pdf_render/pdf_render.dart';

class PrintShopScreen extends StatefulWidget {
  const PrintShopScreen({super.key});

  @override
  PrintShopScreenState createState() => PrintShopScreenState();
}

enum PrintType { color, blackAndWhite }

enum PrintSide { single, double }

class CostBreakdown {
  final int numberOfPages;
  final int numberOfCopies;
  final bool isColorPrint;
  final bool isDoubleSided;
  final double baseRate;
  final double totalCost;

  CostBreakdown({
    required this.numberOfPages,
    required this.numberOfCopies,
    required this.isColorPrint,
    required this.isDoubleSided,
    required this.baseRate,
  }) : totalCost = _calculateTotalCost(
            numberOfPages, numberOfCopies, isDoubleSided, baseRate);

  static double _calculateTotalCost(int numberOfPages, int numberOfCopies,
      bool isDoubleSided, double baseRate) {
    double effectiveRate = isDoubleSided ? baseRate * 0.7 : baseRate;
    return numberOfPages * numberOfCopies * effectiveRate;
  }

  String get printType => isColorPrint ? 'Color' : 'Black & White';
  String get printSide => isDoubleSided ? 'Double Sided' : 'Single Sided';
  double get costPerPage => isDoubleSided ? baseRate * 0.7 : baseRate;
  double get subtotal => numberOfPages * costPerPage;
  double get finalTotal => totalCost;
}

class CostBreakdownCard extends StatelessWidget {
  final CostBreakdown breakdown;

  const CostBreakdownCard({super.key, required this.breakdown});

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow('Print Type:', breakdown.printType),
                  _buildRow('Print Side:', breakdown.printSide),
                  _buildRow(
                      'Number of Pages:', breakdown.numberOfPages.toString()),
                  _buildRow(
                      'Number of Copies:', breakdown.numberOfCopies.toString()),
                  _buildRow('Rate per Page:',
                      '₹${breakdown.costPerPage.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const Divider(height: 32),
            _buildRow(
              'Base Cost per Page:',
              '₹${breakdown.costPerPage.toStringAsFixed(2)}',
            ),
            _buildRow(
              'Subtotal (${breakdown.numberOfPages} pages):',
              '₹${breakdown.subtotal.toStringAsFixed(2)}',
            ),
            _buildRow(
              'Total for ${breakdown.numberOfCopies} copies:',
              '₹${breakdown.totalCost.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }
}

class PrintShopScreenState extends State<PrintShopScreen> {
  final _formKey = GlobalKey<FormState>();
  String? processName;
  File? selectedFile;
  String? fileName;
  int numberOfCopies = 1;
  bool isColorPrint = false;
  bool isDoubleSided = false;
  int numberOfPages = 0;
  double totalCost = 0.0;
  bool isLoading = false;
  CostBreakdown? costBreakdown;

  PrintType _printType = PrintType.blackAndWhite;
  PrintSide _printSide = PrintSide.single;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf', 'pptx'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final extension =
          path.extension(file.path).replaceAll('.', '').toLowerCase();

      try {
        int pageCount = 1; // Default for non-PDF files
        if (extension == 'pdf') {
          // Use pdf_render to get page count
          final pdfDocument = await PdfDocument.openFile(file.path);
          pageCount = pdfDocument.pageCount;
          await pdfDocument.dispose();
        }

        setState(() {
          selectedFile = file;
          fileName = path.basename(file.path);
          numberOfPages = pageCount;
          calculateCost();
        });

        if (pageCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Could not determine page count'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Error processing file: $e');
      }
    }
  }

  void calculateCost() {
    double baseRate = _printType == PrintType.color ? 10.0 : 1.5;
    costBreakdown = CostBreakdown(
      numberOfPages: numberOfPages,
      numberOfCopies: numberOfCopies,
      isColorPrint: _printType == PrintType.color,
      isDoubleSided: _printSide == PrintSide.double,
      baseRate: baseRate,
    );

    setState(() {
      totalCost = costBreakdown!.totalCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Shop Upload'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (costBreakdown != null)
                    CostBreakdownCard(breakdown: costBreakdown!),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Process Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a process name';
                      }
                      return null;
                    },
                    onChanged: (value) => processName = value,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload File'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  if (fileName != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Selected file: $fileName'),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Number of Copies',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of copies';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        numberOfCopies = int.tryParse(value) ?? 1;
                        calculateCost();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Print Options',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Print Type:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          RadioListTile<PrintType>(
                            title: const Text('Color Print'),
                            subtitle: const Text('Cost per page: ₹10.0'),
                            value: PrintType.color,
                            groupValue: _printType,
                            onChanged: (PrintType? value) {
                              if (value != null) {
                                setState(() {
                                  _printType = value;
                                  calculateCost();
                                });
                              }
                            },
                          ),
                          RadioListTile<PrintType>(
                            title: const Text('Black & White'),
                            subtitle: const Text('Cost per page: ₹1.5'),
                            value: PrintType.blackAndWhite,
                            groupValue: _printType,
                            onChanged: (PrintType? value) {
                              if (value != null) {
                                setState(() {
                                  _printType = value;
                                  calculateCost();
                                });
                              }
                            },
                          ),
                          const Divider(height: 24),
                          const Text(
                            'Print Side:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          RadioListTile<PrintSide>(
                            title: const Text('Single Sided'),
                            value: PrintSide.single,
                            groupValue: _printSide,
                            onChanged: (PrintSide? value) {
                              if (value != null) {
                                setState(() {
                                  _printSide = value;
                                  calculateCost();
                                });
                              }
                            },
                          ),
                          RadioListTile<PrintSide>(
                            title: const Text('Double Sided'),
                            value: PrintSide.double,
                            groupValue: _printSide,
                            onChanged: (PrintSide? value) {
                              if (value != null) {
                                setState(() {
                                  _printSide = value;
                                  calculateCost();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          selectedFile != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Processing Print Request...'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Submit Print Request',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
