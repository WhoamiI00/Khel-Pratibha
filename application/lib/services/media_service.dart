import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_item.dart';
import 'supabase_service.dart';

class MediaService {
  static MediaService? _instance;
  static MediaService get instance => _instance ??= MediaService._();
  
  MediaService._();

  SupabaseClient get _client => SupabaseService.instance.client;
  final String _bucketName = 'content';

  /// Upload image or video to Supabase storage
  Future<Map<String, String>?> uploadMedia({
    required File file,
    required String mediaType, // 'image' or 'video'
    String? userId,
  }) async {
    try {
      final String fileName = _generateFileName(file.path, mediaType);
      final String filePath = '${userId ?? 'anonymous'}/$fileName';

      // Upload file to Supabase storage
      await _client.storage
          .from(_bucketName)
          .upload(filePath, file);

      // Get public URL
      final String publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      String? thumbnailUrl;
      
      // Generate and upload thumbnail for videos
      if (mediaType == 'video') {
        final File? thumbnailFile = await generateVideoThumbnail(file);
        if (thumbnailFile != null) {
          final String thumbnailFileName = _generateFileName(thumbnailFile.path, 'thumbnail');
          final String thumbnailFilePath = '${userId ?? 'anonymous'}/thumbnails/$thumbnailFileName';
          
          await _client.storage
              .from(_bucketName)
              .upload(thumbnailFilePath, thumbnailFile);
              
          thumbnailUrl = _client.storage
              .from(_bucketName)
              .getPublicUrl(thumbnailFilePath);
              
          // Clean up temporary thumbnail file
          await thumbnailFile.delete();
        }
      }

      print('Media uploaded successfully: $publicUrl');
      return {
        'mediaUrl': publicUrl,
        'thumbnailUrl': thumbnailUrl ?? '',
      };
    } catch (e) {
      print('Error uploading media: $e');
      return null;
    }
  }

  /// Generate video thumbnail from first frame
  Future<File?> generateVideoThumbnail(File videoFile) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String thumbnailPath = '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final String? thumbnailPathResult = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 300,
        maxWidth: 300,
        timeMs: 1000, // Get thumbnail at 1 second
        quality: 75,
      );
      
      if (thumbnailPathResult != null) {
        return File(thumbnailPathResult);
      }
      
      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Save media record to database
  Future<bool> saveMediaRecord({
    required String url,
    required String mediaType,
    required String fileName,
    String? thumbnailUrl,
    String? userId,
  }) async {
    try {
      await _client.from('media_uploads').insert({
        'user_id': userId,
        'media_url': url,
        'media_type': mediaType,
        'file_name': fileName,
        'thumbnail_url': thumbnailUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('Media record saved successfully');
      return true;
    } catch (e) {
      print('Error saving media record: $e');
      return false;
    }
  }

  /// Get user's media history
  Future<List<MediaItem>> getUserMediaHistory(String? userId) async {
    try {
      final response = await _client
          .from('media_uploads')
          .select()
          .eq('user_id', userId ?? 'anonymous')
          .order('created_at', ascending: false);

      final List<MediaItem> mediaItems = [];
      for (final item in response) {
        mediaItems.add(MediaItem.fromJson(item));
      }

      return mediaItems;
    } catch (e) {
      print('Error fetching media history: $e');
      return [];
    }
  }

  /// Delete media from storage and database
  Future<bool> deleteMedia({
    required String mediaId,
    required String mediaUrl,
    String? userId,
  }) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(mediaUrl);
      final String filePath = uri.pathSegments.skip(5).join('/'); // Skip /storage/v1/object/public/{bucket}/

      // Delete from storage
      await _client.storage
          .from(_bucketName)
          .remove([filePath]);

      // Delete from database
      await _client
          .from('media_uploads')
          .delete()
          .eq('id', mediaId);

      print('Media deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting media: $e');
      return false;
    }
  }

  /// Generate unique filename
  String _generateFileName(String originalPath, String mediaType) {
    final String extension = originalPath.split('.').last;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${mediaType}_$timestamp.$extension';
  }

  /// Check if storage bucket exists and is accessible
  Future<bool> checkStorageAccess() async {
    try {
      await _client.storage.listBuckets();
      return true;
    } catch (e) {
      print('Storage access check failed: $e');
      return false;
    }
  }
}