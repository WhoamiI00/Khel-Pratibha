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
      totalTests: json['total_tests'] is String 
          ? int.tryParse(json['total_tests']) ?? 0 
          : json['total_tests'] ?? 0,
      completedTests: json['completed_tests'] is String 
          ? int.tryParse(json['completed_tests']) ?? 0 
          : json['completed_tests'] ?? 0,
      overallScore: json['overall_score'] != null 
          ? double.tryParse(json['overall_score'].toString()) 
          : null,
      overallGrade: json['overall_grade']?.toString(),
      percentileRank: json['percentile_rank'] != null 
          ? double.tryParse(json['percentile_rank'].toString()) 
          : null,
      saiSubmissionId: json['sai_submission_id']?.toString(),
      saiOfficerNotes: json['sai_officer_notes']?.toString(),
      saiVerificationStatus: json['sai_verification_status']?.toString(),
      deviceInfo: json['device_info'] != null 
          ? Map<String, dynamic>.from(json['device_info']) 
          : null,
      networkQuality: json['network_quality']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.tryParse(json['completed_at'].toString()) 
          : null,
      submittedAt: json['submitted_at'] != null 
          ? DateTime.tryParse(json['submitted_at'].toString()) 
          : null,
      athleteName: json['athlete_name']?.toString(),
      progressPercentage: double.tryParse(json['progress_percentage']?.toString() ?? '0') ?? 0.0,
    );
  }
}