import 'package:bson/bson.dart';

class PrintRequest {
  final String processName;
  final String fileName;
  final List<int> fileBytes;
  final int numberOfPages;
  final int numberOfCopies;
  final bool isColorPrint;
  final bool isDoubleSided;
  final double totalCost;
  final DateTime createdAt;
  final String status;

  PrintRequest({
    required this.processName,
    required this.fileName,
    required this.fileBytes,
    required this.numberOfPages,
    required this.numberOfCopies,
    required this.isColorPrint,
    required this.isDoubleSided,
    required this.totalCost,
    required this.createdAt,
    this.status = 'pending',
  });

  factory PrintRequest.fromJson(Map<String, dynamic> json) {
    // Handle the case where the request is nested in a document
    final requestData =
        json.containsKey('requests') ? (json['requests'] as List).first : json;

    return PrintRequest(
      processName: requestData['processName'] as String,
      fileName: requestData['fileName'] as String,
      fileBytes: (requestData['fileBytes'] as BsonBinary).byteList,
      numberOfPages: requestData['numberOfPages'] as int,
      numberOfCopies: requestData['numberOfCopies'] as int,
      isColorPrint: requestData['isColorPrint'] as bool,
      isDoubleSided: requestData['isDoubleSided'] as bool,
      totalCost: requestData['totalCost'] as double,
      createdAt: DateTime.parse(requestData['createdAt'] as String),
      status: requestData['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'processName': processName,
        'fileName': fileName,
        'fileBytes': BsonBinary.from(fileBytes),
        'numberOfPages': numberOfPages,
        'numberOfCopies': numberOfCopies,
        'isColorPrint': isColorPrint,
        'isDoubleSided': isDoubleSided,
        'totalCost': totalCost,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };
}
