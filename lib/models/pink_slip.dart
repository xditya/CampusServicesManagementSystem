class PinkSlip {
  final String email;
  final String name;
  final String rollNo;
  final String branch;
  final String className;
  final String batch;
  final String reason;
  final String date;
  final String timeFrom;
  final String timeTo;
  final String advisor;
  final String? faculty;
  final bool includePrincipal;
  final List<String> approvalsRequired;
  final List<String> approvedBy;
  final List<String> rejectedBy;
  final String status;
  final DateTime requestDate;

  PinkSlip({
    required this.email,
    required this.name,
    required this.rollNo,
    required this.branch,
    required this.className,
    required this.batch,
    required this.reason,
    required this.date,
    required this.timeFrom,
    required this.timeTo,
    required this.advisor,
    this.faculty,
    required this.includePrincipal,
    required this.approvalsRequired,
    required this.approvedBy,
    required this.rejectedBy,
    required this.status,
    required this.requestDate,
  });

  factory PinkSlip.fromJson(Map<String, dynamic> json) {
    return PinkSlip(
      email: json['email'] as String,
      name: json['name'] as String,
      rollNo: json['rollNo'] as String,
      branch: json['branch'] as String,
      className: json['class'] as String,
      batch: json['batch'] as String,
      reason: json['reason'] as String,
      date: json['date'] as String,
      timeFrom: json['timeFrom'] as String,
      timeTo: json['timeTo'] as String,
      advisor: json['advisor'] as String,
      faculty: json['faculty'] as String?,
      includePrincipal: json['includePrincipal'] as bool,
      approvalsRequired: List<String>.from(json['approvalsRequired'] ?? []),
      approvedBy: List<String>.from(json['approvedBy'] ?? []),
      rejectedBy: List<String>.from(json['rejectedBy'] ?? []),
      status: json['status'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'rollNo': rollNo,
        'branch': branch,
        'class': className,
        'batch': batch,
        'reason': reason,
        'date': date,
        'timeFrom': timeFrom,
        'timeTo': timeTo,
        'advisor': advisor,
        'faculty': faculty,
        'includePrincipal': includePrincipal,
        'approvalsRequired': approvalsRequired,
        'approvedBy': approvedBy,
        'rejectedBy': rejectedBy,
        'status': status,
        'requestDate': requestDate.toIso8601String(),
      };
}
