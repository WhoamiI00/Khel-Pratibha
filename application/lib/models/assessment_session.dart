class AssessmentSession {
  final String id;
  final String? athleteId;
  final String sessionName;
  final String status;
  final int totalTests;
  final int completedTests;
  final double? overallScore;
  final String? overallGrade;
  final double? percentileRank;
  final String? saiSubmissionId;
  final String? saiOfficerNotes;
  final String? saiVerificationStatus;
  final Map<String, dynamic>? deviceInfo;
  final String? networkQuality;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? submittedAt;
  final String? athleteName;
  final double progressPercentage;

  AssessmentSession({
    required this.id,
    this.athleteId,
    required this.sessionName,
    required this.status,
    required this.totalTests,
    required this.completedTests,
    this.overallScore,
    this.overallGrade,
    this.percentileRank,
    this.saiSubmissionId,
    this.saiOfficerNotes,
    this.saiVerificationStatus,
    this.deviceInfo,
    this.networkQuality,
    required this.createdAt,
    this.completedAt,
    this.submittedAt,
    this.athleteName,
    required this.progressPercentage,
  });

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    return AssessmentSession(
      id: json['id']?.toString() ?? '',
      athleteId: json['athlete']?.toString(),
      sessionName: json['session_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalTests: _parseInt(json['total_tests']) ?? 0,
      completedTests: _parseInt(json['completed_tests']) ?? 0,
      overallScore: _parseDouble(json['overall_score']),
      overallGrade: json['overall_grade']?.toString(),
      percentileRank: _parseDouble(json['percentile_rank']),
      saiSubmissionId: json['sai_submission_id']?.toString(),
      saiOfficerNotes: json['sai_officer_notes']?.toString(),
      saiVerificationStatus: json['sai_verification_status']?.toString(),
      deviceInfo: _parseDeviceInfo(json['device_info']),
      networkQuality: json['network_quality']?.toString(),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      completedAt: _parseDateTime(json['completed_at']),
      submittedAt: _parseDateTime(json['submitted_at']),
      athleteName: json['athlete_name']?.toString(),
      progressPercentage: _parseDouble(json['progress_percentage']) ?? 0.0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static Map<String, dynamic>? _parseDeviceInfo(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}