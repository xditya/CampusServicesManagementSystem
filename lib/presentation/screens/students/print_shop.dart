import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:pdf_render/pdf_render.dart';
import '../../../models/print_request.dart';
import '../../../services/print_service.dart';
import '../../../helper/config.dart';

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

  final PrintService _printService = PrintService();

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

          return Scaffold(
            appBar: AppBar(
              title: const Text('Print Shop Upload'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/my-prints'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.print),
                            const SizedBox(width: 8),
                            Text(
                              'My Print Requests',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                          onPressed: () => _submitPrintRequest(session.email),
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
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

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
        setState(() {
          isLoading = true;
        });

        int pageCount;
        if (extension == 'pdf') {
          // Use pdf_render to get page count for PDFs
          final pdfDocument = await PdfDocument.openFile(file.path);
          pageCount = pdfDocument.pageCount;
          await pdfDocument.dispose();
        } else if (['jpg', 'jpeg'].contains(extension)) {
          // Image files count as 1 page
          pageCount = 1;
        } else if (extension == 'pptx') {
          // For PPTX files, we'll need to implement a proper page counter
          // For now, we'll show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PPTX page counting not yet supported'),
              backgroundColor: Colors.orange,
            ),
          );
          pageCount = 1; // Default to 1 for now
        } else {
          pageCount = 1; // Default for unsupported files
        }

        if (pageCount > 0) {
          setState(() {
            selectedFile = file;
            fileName = path.basename(file.path);
            numberOfPages = pageCount;
            calculateCost();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Invalid page count detected'),
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
      } finally {
        setState(() {
          isLoading = false;
        });
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

  Future<void> _submitPrintRequest(String email) async {
    if (_formKey.currentState!.validate() && selectedFile != null) {
      try {
        setState(() {
          isLoading = true;
        });

        final fileBytes = await selectedFile!.readAsBytes();

        final printRequest = PrintRequest(
          processName: processName!,
          fileName: fileName!,
          fileBytes: fileBytes,
          numberOfPages: numberOfPages,
          numberOfCopies: numberOfCopies,
          isColorPrint: _printType == PrintType.color,
          isDoubleSided: _printSide == PrintSide.double,
          totalCost: totalCost,
          createdAt: DateTime.now(),
        );

        await _printService.savePrintRequest(email, printRequest);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Print request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          selectedFile = null;
          fileName = null;
          processName = null;
          numberOfCopies = 1;
          _printType = PrintType.blackAndWhite;
          _printSide = PrintSide.single;
          costBreakdown = null;
        });
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit print request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
