# Media Upload Feature Implementation Guide

## Overview
I have successfully implemented a comprehensive image/video upload feature in your Flutter app's Assessment tab. The feature includes:

1. **Camera/Gallery Selection**: Users can choose to take photos/videos or select from gallery
2. **Supabase Storage Integration**: Files are uploaded to the 'content' bucket
3. **Automatic Video Thumbnails**: First frame thumbnails are generated for videos
4. **Media History**: Display of all uploaded content with thumbnails
5. **Database Integration**: Metadata stored in Supabase database

## Files Created/Modified

### New Files Created:
1. **`lib/models/media_item.dart`** - Model for media metadata
2. **`lib/services/media_service.dart`** - Service for handling uploads and database operations
3. **`lib/widgets/media_upload_widget.dart`** - Upload interface widget
4. **`lib/widgets/media_history_widget.dart`** - History display widget
5. **`backend/migrations/create_media_uploads_table.sql`** - Database schema

### Modified Files:
1. **`pubspec.yaml`** - Added video_thumbnail dependency
2. **`lib/screens/home_screen.dart`** - Integrated widgets into Assessment tab

## Setup Instructions

### 1. Database Setup
Run the SQL migration in Supabase:
```sql
-- Execute the contents of backend/migrations/create_media_uploads_table.sql
-- This creates the media_uploads table with proper RLS policies
```

### 2. Storage Bucket Setup
In Supabase dashboard:
1. Go to Storage section
2. Create a bucket named 'content' (if not exists)
3. Set bucket to public access
4. Enable RLS policies for the bucket

### 3. Permissions Setup
The app requests the following permissions:
- Camera access (for taking photos/videos)
- Microphone access (for video recording)
- Storage access (handled automatically by image_picker)

## Features Implemented

### Media Upload Widget
- **Photo Upload**: Camera or gallery selection
- **Video Upload**: Recording or gallery selection with 5-minute limit
- **Progress Indicator**: Shows upload progress
- **Error Handling**: Comprehensive error messages
- **Permission Management**: Automatic permission requests

### Media History Widget
- **Grid Display**: 2-column grid layout of uploaded media
- **Thumbnails**: Auto-generated thumbnails for videos
- **Media Preview**: Full-screen preview in dialog
- **Delete Functionality**: Swipe or tap to delete media
- **Refresh**: Pull-to-refresh or manual refresh button

### Video Thumbnail Generation
- **Automatic**: Generated during upload process
- **First Frame**: Uses 1-second timestamp for thumbnail
- **Storage**: Thumbnails stored in separate folder structure
- **Fallback**: Default video icon if thumbnail generation fails

## Database Schema

### media_uploads Table
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- media_url (TEXT, Required)
- media_type (VARCHAR, 'image' or 'video')
- file_name (TEXT, Required)
- thumbnail_url (TEXT, Optional)
- file_size_bytes (BIGINT, Optional)
- description (TEXT, Optional)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

## Usage Instructions

### For Users:
1. Open the app and go to Assessment tab
2. Scroll down to see "Upload Media" section
3. Choose "Add Photo" or "Add Video"
4. Select source (Camera/Gallery)
5. Media uploads automatically to Supabase
6. View uploaded media in "Media History" section
7. Tap media to preview, tap delete icon to remove

### For Developers:
1. Ensure Supabase is properly configured
2. Run the database migration
3. Set up storage bucket permissions
4. Test on physical device (camera features require real device)

## File Organization
```
lib/
├── models/
│   └── media_item.dart
├── services/
│   └── media_service.dart
├── widgets/
│   ├── media_upload_widget.dart
│   └── media_history_widget.dart
└── screens/
    └── home_screen.dart (modified)
```

## Testing Checklist

### Image Upload:
- [ ] Take photo with camera
- [ ] Select image from gallery
- [ ] View uploaded image in history
- [ ] Preview image in full screen
- [ ] Delete image

### Video Upload:
- [ ] Record video with camera
- [ ] Select video from gallery
- [ ] Verify thumbnail generation
- [ ] View uploaded video in history
- [ ] Preview video with playback controls
- [ ] Delete video

### Error Handling:
- [ ] Permission denied scenarios
- [ ] Network connection issues
- [ ] Invalid file formats
- [ ] Upload failures

### Database Integration:
- [ ] Media metadata saved correctly
- [ ] User-specific media filtering
- [ ] Media deletion from database

## Security Features
- **Row Level Security (RLS)**: Users can only access their own media
- **Authentication Required**: Must be logged in to upload/view media
- **File Type Validation**: Only images and videos allowed
- **Size Limitations**: Configurable file size limits

## Performance Optimizations
- **Cached Network Images**: Uses cached_network_image for better performance
- **Thumbnail Generation**: Reduces storage and bandwidth usage
- **Lazy Loading**: Media history loads on demand
- **Progress Indicators**: User feedback during uploads

## Next Steps
1. Run the database migration in Supabase
2. Test the implementation on a physical device
3. Customize UI colors/styling to match your app theme
4. Add additional metadata fields if needed
5. Implement media sharing features if required

The implementation is complete and ready for testing!