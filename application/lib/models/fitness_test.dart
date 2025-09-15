class FitnessTest {
  final int id;
  final String name;
  final String displayName;
  final String description;
  final String instructions;
  final String? videoDemoUrl;
  final int? durationSeconds;
  final bool requiresVideo;
  final String measurementUnit;
  final Map<String, dynamic> aiModelConfig;
  final bool cheatDetectionEnabled;
  final bool isActive;
  final DateTime createdAt;

  FitnessTest({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.instructions,
    this.videoDemoUrl,
    this.durationSeconds,
    required this.requiresVideo,
    required this.measurementUnit,
    required this.aiModelConfig,
    required this.cheatDetectionEnabled,
    required this.isActive,
    required this.createdAt,
  });

  factory FitnessTest.fromJson(Map<String, dynamic> json) {
    return FitnessTest(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'],
      name: json['name']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      instructions: json['instructions']?.toString() ?? '',
      videoDemoUrl: json['video_demo_url']?.toString(),
      durationSeconds: json['duration_seconds'] != null 
          ? (json['duration_seconds'] is String 
              ? int.tryParse(json['duration_seconds']) 
              : json['duration_seconds'] as int?)
          : null,
      requiresVideo: json['requires_video'] ?? true,
      measurementUnit: json['measurement_unit']?.toString() ?? '',
      aiModelConfig: Map<String, dynamic>.from(json['ai_model_config'] ?? {}),
      cheatDetectionEnabled: json['cheat_detection_enabled'] ?? true,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}