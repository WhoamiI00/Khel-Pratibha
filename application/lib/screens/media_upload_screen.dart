import 'package:flutter/material.dart';
import '../widgets/media_upload_widget.dart';
import '../widgets/media_history_widget.dart';

class MediaUploadScreen extends StatefulWidget {
  const MediaUploadScreen({super.key});

  @override
  State<MediaUploadScreen> createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends State<MediaUploadScreen> {
  final GlobalKey _historyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Upload'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Assessment Media',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture or upload photos and videos for your fitness assessment',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Media Upload Widget
            MediaUploadWidget(
              onMediaUploaded: (mediaUrl, mediaType) {
                // Refresh media history when new media is uploaded
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${mediaType == 'image' ? 'Image' : 'Video'} uploaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onUploadStarted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upload started...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onUploadError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Upload error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Media History Widget
            MediaHistoryWidget(
              key: _historyKey,
              onMediaDeleted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Media deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Instructions Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      Icons.camera_alt,
                      'Photos',
                      'Take clear photos showing your form during exercises',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      Icons.videocam,
                      'Videos',
                      'Record videos up to 5 minutes showing your performance',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      Icons.storage,
                      'Storage',
                      'All media is securely stored and can be accessed anytime',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      Icons.delete,
                      'Management',
                      'Tap the delete icon on any media to remove it',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.orange,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}