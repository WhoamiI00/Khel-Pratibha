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
    try {
      print('DEBUG: Parsing FitnessTest with JSON: $json');
      
      final id = _parseId(json['id']);
      print('DEBUG: Parsed id: $id');
      
      final name = json['name'] ?? '';
      print('DEBUG: Parsed name: $name');
      
      final displayName = json['display_name'] ?? json['name'] ?? '';
      print('DEBUG: Parsed displayName: $displayName');
      
      final description = json['description'] ?? '';
      print('DEBUG: Parsed description: $description');
      
      final instructions = json['instructions'] ?? '';
      print('DEBUG: Parsed instructions: $instructions');
      
      final videoDemoUrl = json['video_demo_url'] ?? json['media_url'];
      print('DEBUG: Parsed videoDemoUrl: $videoDemoUrl');
      
      final durationSeconds = _parseDuration(json['duration_seconds'] ?? json['duration']);
      print('DEBUG: Parsed durationSeconds: $durationSeconds');
      
      final requiresVideo = json['requires_video'] ?? false;
      print('DEBUG: Parsed requiresVideo: $requiresVideo');
      
      final measurementUnit = json['measurement_unit'] ?? 'count';
      print('DEBUG: Parsed measurementUnit: $measurementUnit');
      
      final aiModelConfig = json['ai_model_config'] ?? <String, dynamic>{};
      print('DEBUG: Parsed aiModelConfig: $aiModelConfig');
      
      final cheatDetectionEnabled = json['cheat_detection_enabled'] ?? false;
      print('DEBUG: Parsed cheatDetectionEnabled: $cheatDetectionEnabled');
      
      final isActive = json['is_active'] ?? true;
      print('DEBUG: Parsed isActive: $isActive');
      
      final createdAt = json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now();
      print('DEBUG: Parsed createdAt: $createdAt');
      
      return FitnessTest(
        id: id,
        name: name,
        displayName: displayName,
        description: description,
        instructions: instructions,
        videoDemoUrl: videoDemoUrl,
        durationSeconds: durationSeconds,
        requiresVideo: requiresVideo,
        measurementUnit: measurementUnit,
        aiModelConfig: aiModelConfig,
        cheatDetectionEnabled: cheatDetectionEnabled,
        isActive: isActive,
        createdAt: createdAt,
      );
    } catch (e) {
      print('ERROR: Failed to parse FitnessTest: $e');
      print('ERROR: JSON data: $json');
      rethrow;
    }
  }

  static int _parseId(dynamic value) {
    print('DEBUG: Parsing ID from value: $value (type: ${value.runtimeType})');
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw ArgumentError('Cannot parse id from $value');
  }

  static int? _parseDuration(dynamic value) {
    print('DEBUG: Parsing duration from value: $value (type: ${value.runtimeType})');
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}