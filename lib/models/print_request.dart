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
    return PrintRequest(
      processName: json['processName'] as String,
      fileName: json['fileName'] as String,
      fileBytes: (json['fileBytes'] as BsonBinary).byteList,
      numberOfPages: json['numberOfPages'] as int,
      numberOfCopies: json['numberOfCopies'] as int,
      isColorPrint: json['isColorPrint'] as bool,
      isDoubleSided: json['isDoubleSided'] as bool,
      totalCost: json['totalCost'] as double,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
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
