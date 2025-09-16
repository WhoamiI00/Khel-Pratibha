class AthleteProfile {
  final String id;
  final String authUserId;
  final String fullName;
  final DateTime dateOfBirth;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String phoneNumber;
  final String? email;
  final String address;
  final String state;
  final String district;
  final String pinCode;
  final String locationCategory;
  final String aadhaarNumber;
  final List<String> sportsInterests;
  final String? previousSportsExperience;
  final String? profilePictureUrl;
  final bool isVerified;
  final String verificationStatus;
  final double? overallTalentScore;
  final String? talentGrade;
  final int? nationalRanking;
  final int? stateRanking;
  final int totalPoints;
  final List<String> badgesEarned;
  final int level;
  final DateTime createdAt;
  final DateTime updatedAt;

  AthleteProfile({
    required this.id,
    required this.authUserId,
    required this.fullName,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.phoneNumber,
    this.email,
    required this.address,
    required this.state,
    required this.district,
    required this.pinCode,
    required this.locationCategory,
    required this.aadhaarNumber,
    required this.sportsInterests,
    this.previousSportsExperience,
    this.profilePictureUrl,
    required this.isVerified,
    required this.verificationStatus,
    this.overallTalentScore,
    this.talentGrade,
    this.nationalRanking,
    this.stateRanking,
    required this.totalPoints,
    required this.badgesEarned,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AthleteProfile.fromJson(Map<String, dynamic> json) {
    return AthleteProfile(
      id: json['id']?.toString() ?? '',
      authUserId: json['auth_user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      dateOfBirth: _parseDateTime(json['date_of_birth']) ?? DateTime.now(),
      age: _parseInt(json['age']) ?? 0,
      gender: json['gender']?.toString() ?? '',
      height: _parseDouble(json['height']) ?? 0.0,
      weight: _parseDouble(json['weight']) ?? 0.0,
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      pinCode: json['pin_code']?.toString() ?? '',
      locationCategory: json['location_category']?.toString() ?? '',
      aadhaarNumber: json['aadhaar_number']?.toString() ?? '',
      sportsInterests: _parseStringList(json['sports_interests']),
      previousSportsExperience: json['previous_sports_experience']?.toString(),
      profilePictureUrl: json['profile_picture_url']?.toString(),
      isVerified: json['is_verified'] ?? false,
      verificationStatus: json['verification_status']?.toString() ?? 'pending',
      overallTalentScore: _parseDouble(json['overall_talent_score']),
      talentGrade: json['talent_grade']?.toString(),
      nationalRanking: _parseInt(json['national_ranking']),
      stateRanking: _parseInt(json['state_ranking']),
      totalPoints: _parseInt(json['total_points']) ?? 0,
      badgesEarned: _parseStringList(json['badges_earned']),
      level: _parseInt(json['level']) ?? 1,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
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

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'state': state,
      'district': district,
      'pin_code': pinCode,
      'location_category': locationCategory,
      'aadhaar_number': aadhaarNumber,
      'sports_interests': sportsInterests,
      'previous_sports_experience': previousSportsExperience,
      'profile_picture_url': profilePictureUrl,
      'is_verified': isVerified,
      'verification_status': verificationStatus,
      'overall_talent_score': overallTalentScore,
      'talent_grade': talentGrade,
      'national_ranking': nationalRanking,
      'state_ranking': stateRanking,
      'total_points': totalPoints,
      'badges_earned': badgesEarned,
      'level': level,
    };
  }
}