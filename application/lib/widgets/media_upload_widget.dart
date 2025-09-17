import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/media_service.dart';

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
      // First, show exercise type selection dialog
      final String? exerciseType = await _showExerciseTypeDialog();
      if (exerciseType == null) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
        return; // User cancelled
      }

      // Simulate progress updates
      for (int i = 0; i <= 50; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      Map<String, dynamic>? uploadResult;
      
      if (mediaType == 'video') {
        // Upload video for analysis using Django backend
        uploadResult = await _mediaService.uploadVideoForAnalysis(
          file: file,
          exerciseType: exerciseType,
          duration: null, // Duration will be calculated by backend
        );
      } else {
        // Upload image for analysis using Django backend
        uploadResult = await _mediaService.uploadImageForAnalysis(
          file: file,
          exerciseType: exerciseType,
        );
      }

      // Complete progress
      setState(() {
        _uploadProgress = 1.0;
      });

      if (uploadResult != null && uploadResult['success'] == true) {
        // Show analysis results in a dialog
        await _showAnalysisResultsDialog(uploadResult);
        
        widget.onMediaUploaded?.call(
          'upload_${uploadResult['upload_id']}', 
          mediaType
        );
        _showSuccessSnackBar('${mediaType == 'image' ? 'Image' : 'Video'} uploaded and analyzed successfully!');
      } else {
        final errorMessage = uploadResult?['error'] ?? 'Unknown error occurred';
        throw Exception(errorMessage);
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

  Future<String?> _showExerciseTypeDialog() async {
    final exercises = [
      {'value': 'pushup', 'display': 'Push-up'},
      {'value': 'squat', 'display': 'Squat'},
      {'value': 'plank', 'display': 'Plank'},
      {'value': 'pull_ups', 'display': 'Pull-ups'},
      {'value': 'sit_ups', 'display': 'Sit-ups'},
      {'value': 'jumping_jacks', 'display': 'Jumping Jacks'},
      {'value': 'lunges', 'display': 'Lunges'},
      {'value': 'burpees', 'display': 'Burpees'},
      {'value': 'mountain_climbers', 'display': 'Mountain Climbers'},
      {'value': 'high_knees', 'display': 'High Knees'},
    ];

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Exercise Type'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise['display']!),
                  onTap: () {
                    Navigator.of(context).pop(exercise['value']);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAnalysisResultsDialog(Map<String, dynamic> results) async {
    final analysisResults = results['analysis_results'] as Map<String, dynamic>?;
    
    if (analysisResults == null) {
      return;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Analysis Results - ${results['exercise_type'] ?? 'Exercise'}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResultItem('Overall Score', '${analysisResults['overall_score']}/100'),
                _buildResultItem('Performance Level', analysisResults['performance_level'] ?? 'N/A'),
                _buildResultItem('Repetitions', '${analysisResults['repetitions_count'] ?? 0}'),
                
                if (analysisResults['form_quality'] != null) ...[
                  const SizedBox(height: 16),
                  const Text('Form Quality:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildResultItem('Overall Rating', analysisResults['form_quality']['overall_rating'] ?? 'N/A'),
                  _buildResultItem('Posture', analysisResults['form_quality']['posture'] ?? 'N/A'),
                  _buildResultItem('Range of Motion', analysisResults['form_quality']['range_of_motion'] ?? 'N/A'),
                ],
                
                if (analysisResults['recommendations'] != null && 
                    (analysisResults['recommendations'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...(analysisResults['recommendations'] as List).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $rec', style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
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