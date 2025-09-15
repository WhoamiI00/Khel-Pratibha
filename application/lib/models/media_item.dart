class MediaItem {
  final String id;
  final String? userId;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String fileName;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int? fileSizeBytes;
  final String? description;

  MediaItem({
    required this.id,
    this.userId,
    required this.mediaUrl,
    required this.mediaType,
    required this.fileName,
    this.thumbnailUrl,
    required this.createdAt,
    this.fileSizeBytes,
    this.description,
  });

  /// Create MediaItem from JSON
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      fileName: json['file_name'] ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      fileSizeBytes: json['file_size_bytes']?.toInt(),
      description: json['description']?.toString(),
    );
  }

  /// Convert MediaItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'file_name': fileName,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'file_size_bytes': fileSizeBytes,
      'description': description,
    };
  }

  /// Check if this is an image
  bool get isImage => mediaType.toLowerCase() == 'image';

  /// Check if this is a video
  bool get isVideo => mediaType.toLowerCase() == 'video';

  /// Get file extension from filename
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : '';
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSizeBytes == null) return 'Unknown size';
    
    const List<String> units = ['B', 'KB', 'MB', 'GB'];
    double size = fileSizeBytes!.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Get formatted creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Copy with updated fields
  MediaItem copyWith({
    String? id,
    String? userId,
    String? mediaUrl,
    String? mediaType,
    String? fileName,
    String? thumbnailUrl,
    DateTime? createdAt,
    int? fileSizeBytes,
    String? description,
  }) {
    return MediaItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      fileName: fileName ?? this.fileName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'MediaItem(id: $id, mediaType: $mediaType, fileName: $fileName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}