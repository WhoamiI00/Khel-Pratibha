import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/media_service.dart';
import '../services/supabase_service.dart';

class MediaUploadWidget extends StatefulWidget {
  final Function(String mediaUrl, String mediaType)? onMediaUploaded;
  final Function()? onUploadStarted;
  final Function(String error)? onUploadError;

  const MediaUploadWidget({
    super.key,
    this.onMediaUploaded,
    this.onUploadStarted,
    this.onUploadError,
  });

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final MediaService _mediaService = MediaService.instance;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isUploading) ...[
              const Text('Uploading...'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : () => _showMediaSourceDialog(),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : () => _showVideoSourceDialog(),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Add Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Choose from gallery or capture new media for your assessment',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check and request permissions
      if (source == ImageSource.camera) {
        final cameraPermission = await Permission.camera.request();
        if (cameraPermission.isDenied) {
          _showPermissionDeniedDialog('Camera');
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        await _uploadMedia(imageFile, 'image');
      }
    } catch (e) {
      print('Error picking image: $e');
      widget.onUploadError?.call('Failed to pick image: $e');
      _showErrorSnackBar('Failed to pick image');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      // Check and request permissions
      if (source == ImageSource.camera) {
        final cameraPermission = await Permission.camera.request();
        final microphonePermission = await Permission.microphone.request();
        
        if (cameraPermission.isDenied || microphonePermission.isDenied) {
          _showPermissionDeniedDialog('Camera and Microphone');
          return;
        }
      }

      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
      );

      if (video != null) {
        final File videoFile = File(video.path);
        await _uploadMedia(videoFile, 'video');
      }
    } catch (e) {
      print('Error picking video: $e');
      widget.onUploadError?.call('Failed to pick video: $e');
      _showErrorSnackBar('Failed to pick video');
    }
  }

  Future<void> _uploadMedia(File file, String mediaType) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    widget.onUploadStarted?.call();

    try {
      // Simulate progress updates
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      // Get current user ID
      final String? userId = SupabaseService.instance.currentUser?.id;

      // Upload to Supabase storage
      final Map<String, String>? uploadResult = await _mediaService.uploadMedia(
        file: file,
        mediaType: mediaType,
        userId: userId,
      );

      if (uploadResult != null && uploadResult['mediaUrl'] != null) {
        final String mediaUrl = uploadResult['mediaUrl']!;
        final String? thumbnailUrl = uploadResult['thumbnailUrl']!.isNotEmpty 
            ? uploadResult['thumbnailUrl'] 
            : null;
        
        // Save media record to database
        final fileName = file.path.split('/').last;
        await _mediaService.saveMediaRecord(
          url: mediaUrl,
          mediaType: mediaType,
          fileName: fileName,
          thumbnailUrl: thumbnailUrl,
          userId: userId,
        );

        widget.onMediaUploaded?.call(mediaUrl, mediaType);
        _showSuccessSnackBar('${mediaType == 'image' ? 'Image' : 'Video'} uploaded successfully!');
      } else {
        throw Exception('Failed to upload media');
      }
    } catch (e) {
      print('Error uploading media: $e');
      widget.onUploadError?.call('Upload failed: $e');
      _showErrorSnackBar('Upload failed. Please try again.');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: Text('$permission permission is required to use this feature. Please enable it in your device settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}