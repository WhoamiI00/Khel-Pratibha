import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_item.dart';
import 'api_service.dart';
import 'supabase_service.dart';

class MediaService {
  static MediaService? _instance;
  static MediaService get instance => _instance ??= MediaService._();
  
  MediaService._();

  final ApiService _apiService = ApiService();

  /// Upload video for exercise analysis - with Supabase storage and fallback
  Future<Map<String, dynamic>?> uploadVideoForAnalysis({
    required File file,
    required String exerciseType,
    double? duration,
  }) async {
    try {
      print('Uploading video for analysis: $exerciseType');
      
      String? publicUrl;
      
      // Step 1: Try to upload video to Supabase 'content' bucket
      try {
        final supabaseService = SupabaseService.instance;
        final fileName = 'exercise_videos/${DateTime.now().millisecondsSinceEpoch}_${exerciseType}.mp4';
        
        print('Attempting upload to Supabase content bucket: $fileName');
        
        final bytes = await file.readAsBytes();
        
        // Try uploading with timeout
        await supabaseService.client.storage
            .from('content')
            .uploadBinary(fileName, bytes)
            .timeout(Duration(seconds: 30));
        
        // Get public URL from Supabase
        publicUrl = supabaseService.client.storage
            .from('content')
            .getPublicUrl(fileName);
        
        print('✅ Video uploaded to Supabase successfully: $publicUrl');
        
      } catch (supabaseError) {
        print('⚠️ Supabase upload failed: $supabaseError');
        print('Falling back to direct Django upload...');
        publicUrl = null;
      }
      
      // Step 2: Send to Django backend (either with Supabase URL or file)
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}/exercise-uploads/upload_video/'),
      );

      // Add headers
      request.headers.addAll(_apiService.authHeaders);

      // Add form fields
      request.fields['exercise_type'] = exerciseType;
      if (duration != null) {
        request.fields['duration'] = duration.toString();
      }
      
      if (publicUrl != null) {
        // Use Supabase URL
        request.fields['video_url'] = publicUrl;
        print('Sending Supabase video URL to Django backend...');
      } else {
        // Fallback: send file directly to Django
        final videoFile = await http.MultipartFile.fromPath(
          'video_file',
          file.path,
        );
        request.files.add(videoFile);
        print('Sending video file directly to Django backend...');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        final result = json.decode(responseBody);
        print('✅ Video uploaded and analyzed successfully');
        return result;
      } else {
        print('❌ Django upload failed with status: ${response.statusCode}');
        print('Error: $responseBody');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading video: $e');
      return null;
    }
  }

  /// Upload image for exercise analysis - with Supabase storage and fallback
  Future<Map<String, dynamic>?> uploadImageForAnalysis({
    required File file,
    required String exerciseType,
  }) async {
    try {
      print('Uploading image for analysis: $exerciseType');
      
      String? publicUrl;
      
      // Step 1: Try to upload image to Supabase 'content' bucket
      try {
        final supabaseService = SupabaseService.instance;
        final fileName = 'exercise_images/${DateTime.now().millisecondsSinceEpoch}_${exerciseType}.jpg';
        
        print('Attempting upload to Supabase content bucket: $fileName');
        
        final bytes = await file.readAsBytes();
        
        // Try uploading with timeout
        await supabaseService.client.storage
            .from('content')
            .uploadBinary(fileName, bytes)
            .timeout(Duration(seconds: 30));
        
        // Get public URL from Supabase
        publicUrl = supabaseService.client.storage
            .from('content')
            .getPublicUrl(fileName);
        
        print('✅ Image uploaded to Supabase successfully: $publicUrl');
        
      } catch (supabaseError) {
        print('⚠️ Supabase upload failed: $supabaseError');
        print('Falling back to direct Django upload...');
        publicUrl = null;
      }
      
      // Step 2: Send to Django backend (either with Supabase URL or file)
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}/exercise-uploads/upload_image/'),
      );

      // Add headers
      request.headers.addAll(_apiService.authHeaders);

      // Add form fields
      request.fields['exercise_type'] = exerciseType;
      
      if (publicUrl != null) {
        // Use Supabase URL
        request.fields['image_url'] = publicUrl;
        print('Sending Supabase image URL to Django backend...');
      } else {
        // Fallback: send file directly to Django
        final imageFile = await http.MultipartFile.fromPath(
          'image_file',
          file.path,
        );
        request.files.add(imageFile);
        print('Sending image file directly to Django backend...');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        final result = json.decode(responseBody);
        print('✅ Image uploaded and analyzed successfully');
        return result;
      } else {
        print('❌ Django upload failed with status: ${response.statusCode}');
        print('Error: $responseBody');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image: $e');      
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

  /// Get analysis results for a specific upload
  Future<Map<String, dynamic>?> getAnalysisResults(int uploadId) async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/exercise-uploads/$uploadId/get_analysis/'),
        headers: _apiService.authHeaders,
      );

      print('Analysis results response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get analysis results: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting analysis results: $e');
      return null;
    }
  }

  /// Get all uploads for the current user
  Future<List<Map<String, dynamic>>> getMyUploads() async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/exercise-uploads/my_uploads/'),
        headers: _apiService.authHeaders,
      );

      print('My uploads response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['uploads'] ?? []);
      } else {
        print('Failed to get uploads: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting uploads: $e');
      return [];
    }
  }

  /// Get user's media history from Django backend
  Future<List<MediaItem>> getUserMediaHistory(String? userId) async {
    try {
      final uploads = await getMyUploads();
      
      // Convert Django upload format to MediaItem format
      List<MediaItem> mediaItems = [];
      for (final upload in uploads) {
        final mediaItem = MediaItem(
          id: upload['id'].toString(),
          userId: userId,
          mediaUrl: 'exercise_upload_${upload['id']}', // Placeholder URL
          mediaType: upload['video_duration'] != null && upload['video_duration'] > 0 ? 'video' : 'image',
          fileName: '${upload['exercise_type']}_${upload['id']}.${upload['video_duration'] != null ? 'mp4' : 'jpg'}',
          thumbnailUrl: null,
          createdAt: DateTime.parse(upload['uploaded_at']),
          fileSizeBytes: upload['file_size_mb'] != null 
              ? (upload['file_size_mb'] * 1024 * 1024).round() 
              : null,
          description: 'Exercise: ${upload['exercise_type']}',
        );
        mediaItems.add(mediaItem);
      }
      
      return mediaItems;
    } catch (e) {
      print('Error fetching media history: $e');
      return [];
    }
  }

  /// Delete media from Django backend
  Future<bool> deleteMedia({
    required String mediaId,
    required String mediaUrl,
    String? userId,
  }) async {
    try {
      // Extract upload ID from mediaUrl or mediaId
      String uploadId = mediaId;
      if (mediaUrl.startsWith('exercise_upload_')) {
        uploadId = mediaUrl.replaceFirst('exercise_upload_', '');
      }

      final response = await http.delete(
        Uri.parse('${_apiService.baseUrl}/exercise-uploads/$uploadId/'),
        headers: _apiService.authHeaders,
      );

      print('Delete response: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('Media deleted successfully');
        return true;
      } else {
        print('Failed to delete media: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting media: $e');
      return false;
    }
  }

  /// Check if backend connection is working
  Future<bool> checkBackendConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/health/'),
        headers: _apiService.headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Backend connection check failed: $e');
      return false;
    }
  }
}